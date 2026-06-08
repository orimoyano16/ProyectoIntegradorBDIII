const { pool } = require('../config/database');

async function getUsuarioByDni(dni) {
  const { rows } = await pool.query(
    `SELECT
       u.usuario_id,
       u.nombre,
       u.apellido,
       u.email,
       u.dni,
       u.rol,
       u.carrera_id,
       c.nombre_carrera
     FROM usuario u
     JOIN carrera c ON u.carrera_id = c.carrera_id
     WHERE u.dni = $1`,
    [dni]
  );

  if (rows.length === 0) {
    const error = new Error(`No se encontró usuario con DNI ${dni}`);
    error.statusCode = 404;
    throw error;
  }

  const u = rows[0];
  return {
    usuarioId: u.usuario_id,
    nombre: u.nombre,
    apellido: u.apellido,
    email: u.email,
    dni: Number(u.dni),
    rol: u.rol,
    carreraId: u.carrera_id,
    nombreCarrera: u.nombre_carrera,
  };
}

module.exports = { getUsuarioByDni };
