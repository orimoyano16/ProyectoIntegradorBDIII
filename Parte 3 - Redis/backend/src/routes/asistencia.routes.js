const express = require('express');
const { cacheAside } = require('../cache/cacheAside');
const keys = require('../cache/keys');
const { getPorcentajeAsistencia } = require('../services/asistencia.service');

const router = express.Router();

const TTL = Number(process.env.CACHE_TTL_ASISTENCIA) || 120;

router.get('/alumnos/:id/asistencia/:comisionId', async (req, res, next) => {
  try {
    const alumnoId = req.params.id;
    const comisionId = req.params.comisionId;
    const cacheKey = keys.asistencia(alumnoId, comisionId);

    const result = await cacheAside(cacheKey, TTL, () =>
      getPorcentajeAsistencia(alumnoId, comisionId)
    );

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
