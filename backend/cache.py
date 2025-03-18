# Multi-level caching system
class ResponseCache:
    def __init__(self):
        self.cache_levels = {
            'common': {  # Most frequent scenarios
                'ttl': 7 * 24 * 3600,  # 7 days
                'max_entries': 100
            },
            'user': {    # User-specific responses
                'ttl': 24 * 3600,      # 1 day
                'max_entries': 10
            },
            'temp': {    # Temporary storage
                'ttl': 3600,           # 1 hour
                'max_entries': 1000
            }
        }
    
    def get_cache_key(self, context: dict) -> str:
        """Generate deterministic cache key"""
        return f"{context['type']}:{context['streak']}:{context['time_of_day']}"
    
    def should_cache(self, context: dict) -> bool:
        """Determine if response should be cached"""
        return (
            context['streak'] in [1, 7, 30, 100] or  # Milestone streaks
            context['type'] in ['daily', 'weekly'] or # Common frequencies
            context['activity'] in ['gym', 'meditation', 'reading']  # Common activities
        )

    def get_cache_level(self, context: dict) -> str:
        """Determine appropriate cache level"""
        if context['streak'] >= 30:
            return 'common'
        elif context['user_frequency'] > 0.8:  # Active user
            return 'user'
        return 'temp' 