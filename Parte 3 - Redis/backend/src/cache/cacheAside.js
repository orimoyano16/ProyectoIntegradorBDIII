const { redis, isRedisAvailable } = require('../config/redis');

/**
 * Autor: Santiago Marranti
 * Invalidamos un dato especifico en Redis. Usado en peticion PUT/PATCH o DELETE
 */
async function invalidateDataKey(key) {
    // Invalidamos el caché del porcentaje de asistencia para que se actualice en la próxima consulta
    if (isRedisAvailable()) {
      try {
        await redis.del(key);
        console.log(`[Cache] DEL  → ${key} (Invalidado por nueva asistencia)`);
      } catch (err) {
        console.warn(`[Cache] Error invalidando Redis (${key}):`, err.message);
      }
    }
}

async function setDataKey(key, data, ttlSeconds) {
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
    cacheKey: key,
  };
}

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

  await setDataKey(key, data, ttlSeconds);

  return {
    data,
    source: 'database',
    cacheKey: key,
  };
}

module.exports = { cacheAside, setDataKey, invalidateDataKey };
