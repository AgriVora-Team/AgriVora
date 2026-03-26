

import time

# In-memory cache store
_cache = {}
TTL_SECONDS = 24 * 60 * 60  # 24 hours

def get_cache(key: str):
    entry = _cache.get(key)
    if not entry:
        return None

    value, timestamp = entry
     # Check expiration
    if time.time() - timestamp > TTL_SECONDS:
        del _cache[key]
        return None

    return value

def set_cache(key: str, value):
    # Store value with timestamp
    _cache[key] = (value, time.time())
