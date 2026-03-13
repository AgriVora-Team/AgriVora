import time

# In-memory cache storage
_cache_store = {}

CACHE_TTL = 24 * 60 * 60  # 24 hours


def _is_expired(timestamp: float) -> bool:
    """Check whether cached item has expired."""
    return (time.time() - timestamp) > CACHE_TTL


def get_cache(key: str):
    entry = _cache_store.get(key)

    if entry is None:
        return None

    value, saved_time = entry

    if _is_expired(saved_time):
        _cache_store.pop(key, None)
        return None

    return value


def set_cache(key: str, value):
    _cache_store[key] = (value, time.time())