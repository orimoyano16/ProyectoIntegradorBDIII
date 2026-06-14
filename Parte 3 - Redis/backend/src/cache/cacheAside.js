const { redis, isRedisAvailable } = require('../config/redis');

/**
 * Patrón Cache-Aside (Lazy Loading):
 * 1. Buscar en Redis
 * 2. HIT → devolver
 * 3. MISS → consultar DB → guardar en Redis con TTL → devolver
 */
async function cacheAside(key, ttlSeconds, fetchFromDb) {
  if (isRedisAvailable()) {
    try {
      const cached = await redis.get(key);
      if (cached) {
        console.log(`[Cache] HIT  → ${key}`);
        return {
          data: JSON.parse(cached),
          source: 'redis',
          cacheKey: key,
        };
      }
      console.log(`[Cache] MISS → ${key}`);
    } catch (err) {
      console.warn(`[Cache] Error leyendo Redis (${key}):`, err.message);
    }
  }

  const data = await fetchFromDb();

  if (isRedisAvailable()) {
    try {
      await redis.set(key, JSON.stringify(data), 'EX', ttlSeconds);
      console.log(`[Cache] SET  → ${key} (TTL ${ttlSeconds}s)`);
    } catch (err) {
      console.warn(`[Cache] Error escribiendo Redis (${key}):`, err.message);
    }
  }

  return {
    data,
    source: 'database',
    cacheKey: key,
  };
}

module.exports = { cacheAside };
