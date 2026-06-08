const express = require('express');
const { cacheAside } = require('../cache/cacheAside');
const keys = require('../cache/keys');
const { getUsuarioByDni } = require('../services/usuario.service');

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

module.exports = router;
