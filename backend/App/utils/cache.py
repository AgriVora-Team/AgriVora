import time

_cache = {}
TTL_SECONDS = 24 * 60 * 60


def get_cache(key: str):
    entry = _cache.get(key)

    if not entry:
        return None

    value, timestamp = entry

    if time.time() - timestamp > TTL_SECONDS:
        _cache.pop(key, None)
        return None

    return value


def set_cache(key: str, value):
    _cache[key] = (value, time.time())