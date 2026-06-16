const { pool } = require('../config/database');

async function updateAlumnoAsistencia(alumno_id, comision_id, fecha, estado, observacion) {
  const result = await pool.query(`
    UPDATE asistencia
    SET estado = $1, observacion = $2
    WHERE alumno_id = $3 AND comision_id = $4 AND fecha = $5
  `, [estado, observacion, alumno_id, comision_id, fecha]
  );

  const status = result.rowCount > 0;

  return {
    actualizado: status,
    alumnoId: Number(alumno_id),
    comisionId: Number(comision_id),
    fecha: fecha,
    estado: estado,
    observacion: observacion,
  }

}

async function setAlumnoAsistencia(alumno_id, comision_id, fecha, estado, observacion) {
  const result = await pool.query(`
    INSERT INTO asistencia(alumno_id, comision_id, fecha, estado, observacion)
    VALUES ($1, $2, $3, $4, $5)
  `, [alumno_id, comision_id, fecha, estado, observacion]
  );

  let status = result.rowCount > 0;

  return {
    creado: status,
    alumnoId: Number(alumno_id),
    comisionId: Number(comision_id),
    fecha: fecha,
    estado: estado,
    observacion: observacion
  }
}

async function getPorcentajeAsistencia(alumnoId, comisionId) {
  const { rows } = await pool.query(
    `SELECT
       fn_calcular_porcentaje_asistencia($1, $2) AS porcentaje,
       fn_clasificar_nivel_asistencia(
         fn_calcular_porcentaje_asistencia($1, $2)
       ) AS nivel`,
    [alumnoId, comisionId]
  );

  return {
    alumnoId: Number(alumnoId),
    comisionId: Number(comisionId),
    porcentaje: Number(rows[0].porcentaje),
    nivel: rows[0].nivel,
  };
}

module.exports = { getPorcentajeAsistencia, setAlumnoAsistencia,
                   updateAlumnoAsistencia };
