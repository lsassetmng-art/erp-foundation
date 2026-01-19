package foundation.cache;

/**
 * CacheStore
 * - Cache ONLY (never source of truth)
 */
public interface CacheStore<T> {

    void put(String key, T value);

    T get(String key);

    void invalidate(String key);

    void clear();
}
