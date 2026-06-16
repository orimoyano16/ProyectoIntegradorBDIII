const express = require('express');

const { cacheAside, setDataKey, invalidateDataKey } = require('../cache/cacheAside');
const keys = require('../cache/keys');

const { getPorcentajeAsistencia, setAlumnoAsistencia, 
        updateAlumnoAsistencia } = require('../services/asistencia.service');

const router = express.Router();

const TTL = Number(process.env.CACHE_TTL_ASISTENCIA) || 120;

/**
 * Autor: Santiago Marranti
 * Actualizar la asistencia de un alumno en determinada comisión y fecha. Si el registro no existe, se muestra un error.
 */
router.put('/asistencia/:alumnoId/:comisionId/:fecha', async (req, res, next) => {
  try {
    const { alumnoId, comisionId, fecha } = req.params;
    const { estado, observacion } = req.body;
    
    // Si los parametros del cuerpo de la solicitud vienen vacios, mostramos error.
    if (estado === undefined || observacion === undefined) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Faltan campos requeridos en el cuerpo de la peticion. Se requieren los siguientes campos: estado, observacion.'
      })
    }

    // Si los parametros de ruta vienen vacios, mostramos error.
    if(alumnoId === undefined || comisionId === undefined || fecha === undefined) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Faltan parámetros requeridos. Se requieren los siguientes parámetros: alumnoId, comisionId, fecha.'
      })
    }

    const status = await updateAlumnoAsistencia(alumnoId, comisionId, fecha, estado, observacion);

    // Si se actualizó en DB, invalidamos las claves de caché afectadas
    if (status.actualizado) {
      // Invalida el porcentaje de asistencia (puede haber cambiado de AUSENTE→PRESENTE o viceversa)
      await invalidateDataKey(keys.asistencia(alumnoId, comisionId));
      
      // Invalida el registro puntual de ese día (fue modificado)
      await invalidateDataKey(keys.registroAsistencia(alumnoId, comisionId, fecha));
    }

    //Dependiendo de si se actualizo o no, debemos informalo al cliente.
    const message = status.actualizado ? 'La asistencia se ha actualizado exitosamente' : 
                    'Error: no se pudo actualizar la asistencia porque el registro no existe.';
    const code = status.actualizado ? 200 : 404;

    res.status(code).json({
      mensaje: message,
      alumnoId: alumnoId,
      comisionId: comisionId,
      fecha: fecha,
      estado: estado,
      observacion: observacion
    });

  } catch (err) {
    next(err);
  }
});

/**
 * Autor: Santiago Marranti
 * Registra la asistencia de un alumno en determinada comisión y fecha. Si el registro ya existe, se muestra un error. 
 */
router.post('/asistencia', async (req, res, next) => {
  try{
    const { alumnoId, comisionId, fecha, estado, observacion } = req.body;

    if(!req.body || Object.keys(req.body).length === 0) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'El cuerpo de la solicitud no puede estar vacío. Se requieren los siguientes campos: alumnoId, comisionId, fecha, estado, observacion.'
      })
    }

    if(!alumnoId || !comisionId || !fecha || estado === undefined) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Faltan campos requeridos. Se requieren los siguientes campos: alumnoId, comisionId, fecha, estado.'
      })
    }

    const status = await setAlumnoAsistencia(alumnoId, comisionId, fecha, estado, observacion);

    const data = {
      alumnoId: alumnoId,
      comisionId: comisionId,
      fecha: fecha,
      estado: estado,
      observacion: observacion
    }

    // Guardamos el nuevo registro en caché
    const result = await setDataKey(keys.registroAsistencia(alumnoId, comisionId, fecha), data, TTL);

    // Invalidamos el porcentaje de asistencia cacheado: el nuevo registro lo modifica
    if (status.creado) {
      await invalidateDataKey(keys.asistencia(alumnoId, comisionId));
    }

    const message = status.creado ? 'La asistencia se ha registrado exitosamente' : 'Error: no se pudo registrar la asistencia';
    const code = status.creado ? 201 : 500;

    res.status(code).json({
      mensaje: message,
      alumnoId: alumnoId,
      comisionId: comisionId,
      fecha: fecha,
      estado: estado,
      observacion: observacion,
      cacheData: result.data,
      cacheKey: result.cacheKey
    })
  } catch (err) {
    next(err);
  }
});

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
