const express = require('express');
const { redis, isRedisAvailable } = require('../config/redis');
const { pool } = require('../config/database');

const router = express.Router();

router.get('/health', async (_req, res) => {
  let postgres = 'disconnected';
  try {
    await pool.query('SELECT 1');
    postgres = 'connected';
  } catch (_) {
    postgres = 'error';
  }

  res.json({
    status: 'ok',
    postgres,
    redis: isRedisAvailable() ? 'connected' : 'unavailable',
  });
});

router.get('/health/redis', async (_req, res) => {
  try {
    const pong = await redis.ping();
    res.json({ redis: 'connected', ping: pong });
  } catch (err) {
    res.status(503).json({
      redis: 'unavailable',
      error: err.message,
      fallback: 'La API sigue funcionando consultando PostgreSQL directamente',
    });
  }
});

module.exports = router;
