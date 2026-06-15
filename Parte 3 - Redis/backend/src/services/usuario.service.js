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

// Agrego nueva función: DELETE para dar de baja lógica
async function bajaDeUsuario(id) {
  const { rows: existing } =  await pool.query(
    'SELECT usuario_id, dni, fecha_baja FROM usuario WHERE usuario_id = $1',
    [id]
  );

  if (existing.length === 0){
    const error = new Error(`No se encontró usuario con ID ${id}`);
    error.statusCode = 400;
    throw error;
  }

  if (existing[0].fecha_baja !== null){
    const error = new Error(`El usuario con ID ${id} ya fue dado de baja`);
    error.statusCode = 409;
    throw error;
  }

  const { rows } = await pool.query (
    `UPDATE usuario
    SET fecha_baja = now()
    WHERE usuario_id = $1
    RETURNING usuario_id, nombre, apellido, email, dni, rol, fecha_baja`,
    [id]
  );

  const u = rows[0];
  return {
    usuarioId: u.usuario_id,
    nombre: u.nombre,
    apellido: u.apellido,
    email: u.email,
    dni: Number(u.dni),
    rol: u.rol,
    fechaBaja: u.fecha_baja,
  };
}



module.exports = { getUsuarioByDni, bajaDeUsuario };
