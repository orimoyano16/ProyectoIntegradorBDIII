require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });

const express = require('express');
const { testConnection } = require('./config/database');
const { connectRedis } = require('./config/redis');
const asistenciaRoutes = require('./routes/asistencia.routes');
const usuarioRoutes = require('./routes/usuario.routes');
const healthRoutes = require('./routes/health.routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (_req, res) => {
  res.json({
    proyecto: 'Sistema de Asistencias — Parte 3 Redis',
    endpoints: {
      health: 'GET /api/health',
      redisPing: 'GET /api/health/redis',
      asistencia: 'GET /api/alumnos/:id/asistencia/:comisionId',
      usuarioDni: 'GET /api/usuarios/dni/:dni',
    },
    ejemplos: {
      asistencia: 'GET /api/alumnos/1/asistencia/1',
      usuario: 'GET /api/usuarios/dni/40123456',
    },
  });
});

app.use('/api', healthRoutes);
app.use('/api', asistenciaRoutes);
app.use('/api', usuarioRoutes);

app.use((err, _req, res, _next) => {
  const status = err.statusCode || 500;
  res.status(status).json({
    error: err.message || 'Error interno del servidor',
  });
});

async function start() {
  await testConnection();
  await connectRedis();

  app.listen(PORT, () => {
    console.log(`API escuchando en http://localhost:${PORT}`);
    console.log('Probá: GET /api/alumnos/1/asistencia/1 (2 veces para ver HIT/MISS)');
  });
}

start().catch((err) => {
  console.error('No se pudo iniciar la API:', err.message);
  process.exit(1);
});
