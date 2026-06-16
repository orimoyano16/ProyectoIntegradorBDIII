const express = require('express');

const { cacheAside, setDataKey } = require('../cache/cacheAside');
const keys = require('../cache/keys');
const { getUsuarioByDni, bajaDeUsuario } = require('../services/usuario.service');
const { redis, isRedisAvailable } = require('../config/redis');

const router = express.Router();

const TTL = Number(process.env.CACHE_TTL_USUARIO) || 300;

router.get('/usuarios/dni/:dni', async (req, res, next) => {
  try {
    const { dni } = req.params;
    const cacheKey = keys.usuarioDni(dni);

    const result = await cacheAside(cacheKey, TTL, () => getUsuarioByDni(dni));

    res.json({
      ...result.data,
      cached: result.source === 'redis',
      source: result.source,
      cacheKey: result.cacheKey,
      ttlSeconds: TTL,
    });
  } catch (err) {
    next(err);
  }
});

router.delete('/usuarios/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const usuarioDadoDeBaja = await bajaDeUsuario(id);

    if (isRedisAvailable()) {
      const cacheKey = keys.usuarioDni(usuarioDadoDeBaja.dni);
      await redis.del(cacheKey);
      console.log(`[Cache] DEL → ${cacheKey}`);
    }

    res.json({
      mensaje: 'Usuario dado de baja correctamente',
      usuario: usuarioDadoDeBaja,
    });
  } catch (err) {
    next(err);
  }
});


module.exports = router;
