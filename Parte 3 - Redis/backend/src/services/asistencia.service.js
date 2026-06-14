const { pool } = require('../config/database');

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

module.exports = { getPorcentajeAsistencia };
