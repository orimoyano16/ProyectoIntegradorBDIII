/**
 * Nomenclatura keyspace con dos puntos (:)
 * Ejemplos: asistencia:1:1 | users:dni:40123456
 */
const keys = {
  asistencia: (alumnoId, comisionId) => `asistencia:${alumnoId}:${comisionId}`,
  usuarioDni: (dni) => `users:dni:${dni}`,
};

module.exports = keys;
