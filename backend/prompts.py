# Ultra-optimized prompts with minimal tokens
PROMPT_TEMPLATES = {
    'success': {
        'first_time': "5 words: first time completing {activity}",
        'streak': "5 words: {streak}-day {activity} streak",
        'milestone': "5 words: reached {streak} days {activity}",
        'return': "5 words: returned to {activity} today"
    },
    'missed': {
        'first_miss': "5 words: first miss, encourage {activity}",
        'multiple': "5 words: missed {activity}, build consistency",
        'return': "5 words: returning to {activity} tomorrow"
    }
}

# Token-efficient context additions
CONTEXT_TEMPLATES = {
    'morning': "morning+",
    'evening': "evening+",
    'weekend': "weekend+",
    'busy_day': "busy+"
} 