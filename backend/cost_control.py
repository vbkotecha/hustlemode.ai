import time
import boto3
from backend.prompts import PROMPT_TEMPLATES, CONTEXT_TEMPLATES
from backend.cache import ResponseCache

class AIUsageController:
    def __init__(self):
        self.daily_limits = {
            'free_tier': 10,
            'basic': 25,
            'premium': 50
        }
        self.token_budgets = {
            'free_tier': 100,  # tokens per response
            'basic': 150,
            'premium': 200
        }
    
    def optimize_prompt(self, prompt: str, tier: str) -> str:
        """Optimize prompt based on user tier"""
        max_tokens = self.token_budgets[tier]
        if len(prompt.split()) > max_tokens // 4:  # Approximate token count
            return self.truncate_prompt(prompt, max_tokens)
        return prompt
    
    def should_generate_response(self, user_context: dict) -> bool:
        """Smart rate limiting and cost control"""
        # Check daily limit
        if self.get_daily_usage(user_context['user_id']) >= self.daily_limits[user_context['tier']]:
            return False
            
        # Check time-based rules
        last_generation = self.get_last_generation_time(user_context['user_id'])
        if user_context['tier'] == 'free_tier':
            return time.time() - last_generation > 7200  # 2 hours
        elif user_context['tier'] == 'basic':
            return time.time() - last_generation > 3600  # 1 hour
        return True  # Premium users get unlimited generation
    
    def get_fallback_response(self, context: dict) -> str:
        """Smart fallback when AI generation is skipped"""
        return self.template_engine.render(
            template=self.get_appropriate_template(context),
            streak=context['streak'],
            activity=context['activity']
        )

class CostOptimizedAPI:
    def __init__(self):
        self.cache = ResponseCache()
        self.controller = AIUsageController()
        self.bedrock = boto3.client('bedrock-runtime')
        
    async def generate_response(self, context: dict) -> str:
        """Cost-optimized response generation"""
        # Try cache first
        cached_response = self.cache.get(
            self.cache.get_cache_key(context)
        )
        if cached_response:
            return cached_response
            
        # Check if we should use AI
        if not self.controller.should_generate_response(context):
            return self.controller.get_fallback_response(context)
            
        # Generate AI response with optimized prompt
        prompt = self.get_optimized_prompt(context)
        try:
            response = await self.generate_ai_response(prompt, context['tier'])
            
            # Cache if appropriate
            if self.cache.should_cache(context):
                self.cache.store(
                    key=self.cache.get_cache_key(context),
                    value=response,
                    level=self.cache.get_cache_level(context)
                )
            
            return response
        except Exception as e:
            print(f"AI generation failed: {e}")
            return self.controller.get_fallback_response(context)
    
    def get_optimized_prompt(self, context: dict) -> str:
        """Get the most token-efficient prompt"""
        base_prompt = PROMPT_TEMPLATES[
            'success' if context['completed'] else 'missed'
        ][self.get_prompt_type(context)]
        
        # Add minimal but relevant context
        time_context = CONTEXT_TEMPLATES.get(context['time_of_day'], '')
        
        return f"{time_context}{base_prompt.format(**context)}" 