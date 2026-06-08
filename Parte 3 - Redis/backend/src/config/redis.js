require('dotenv').config({ path: require('path').join(__dirname, '../../../.env') });

const Redis = require('ioredis');

let redisAvailable = true;

const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: 1,
  retryStrategy(times) {
    if (times > 3) return null;
    return Math.min(times * 200, 1000);
  },
  lazyConnect: true,
});

redis.on('error', (err) => {
  redisAvailable = false;
  console.error('[Redis] No disponible — fallback a PostgreSQL:', err.message);
});

redis.on('connect', () => {
  redisAvailable = true;
  console.log('[Redis] Conectado');
});

async function connectRedis() {
  try {
    await redis.connect();
    const pong = await redis.ping();
    console.log(`[Redis] PING → ${pong}`);
    redisAvailable = true;
  } catch (err) {
    redisAvailable = false;
    console.error('[Redis] No se pudo conectar — la API usará solo PostgreSQL');
  }
}

function isRedisAvailable() {
  return redisAvailable && redis.status === 'ready';
}

module.exports = { redis, connectRedis, isRedisAvailable };
