# PARTE 3 — Integración de Caché con Redis

**Unidad:** Base de Datos III · **Eje III:** El Ecosistema NoSQL  
**Proyecto:** Sistema de Asistencias · Persistencia políglota (PostgreSQL + Redis)

Esta carpeta implementa el patrón **Cache-Aside** sobre la base relacional de las Partes 1 y 2.

> **Entrega de la consigna:** API backend + Redis + PostgreSQL. No requiere frontend; se prueba con navegador, Postman o `curl`.

---

## Estructura

```
Parte 3 - Redis/
├── docker-compose.yml      # PostgreSQL + Redis
├── init/                   # Schema, funciones y datos de prueba
├── .env.example
└── backend/                # API Node.js (Cache-Aside)
    └── src/
        ├── config/         # Conexiones PG + Redis (con fallback)
        ├── cache/          # keys.js + cacheAside.js
        ├── services/         # Consultas a PostgreSQL
        └── routes/           # Endpoints HTTP
```

---

## Endpoints cacheados (Fase de diseño)

| Endpoint | Clave Redis | TTL | Por qué |
|----------|-------------|-----|---------|
| `GET /api/alumnos/:id/asistencia/:comisionId` | `asistencia:{id}:{comisionId}` | 120 s | Alta lectura, baja escritura, tolera 2 min de retraso |
| `GET /api/usuarios/dni/:dni` | `users:dni:{dni}` | 300 s | Búsqueda frecuente por DNI, datos estables |

---

## Cómo levantar el proyecto

### Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Node.js 18+](https://nodejs.org/)

### Paso 1 — Infraestructura

```powershell
cd "Parte 3 - Redis"
docker compose up -d
```

Esperá a que PostgreSQL y Redis estén healthy. La primera vez carga `init/` (tablas, funciones, datos de prueba).

### Paso 2 — Variables de entorno

```powershell
copy .env.example .env
```

### Paso 3 — Backend

```powershell
cd backend
npm install
npm start
```

La API queda en `http://localhost:3000`.

> **Ruta completa en Windows:**
> `Proyecto integrador parte 2\ProyectoIntegradorBDIII\Parte 3 - Redis`

---

## Solución de problemas

### `la autentificación password falló para el usuario postgres`

**Causa:** Docker no está corriendo y la API intenta conectarse al PostgreSQL **local** (puerto 5432) con contraseña `postgres`, que no coincide con la tuya.

**Solución A — Usar Docker (recomendado):**

1. Abrí **Docker Desktop** y esperá a que diga "Running".
2. En la carpeta `Parte 3 - Redis`:
   ```powershell
   docker compose up -d
   ```
3. El `.env` debe usar puerto **5433** (Docker), no 5432:
   ```
   DATABASE_URL=postgresql://postgres:postgres@localhost:5433/asistencia_institucional_db
   ```
4. `npm start` en `backend/`.

**Solución B — Usar tu PostgreSQL de DBeaver:**

1. Editá `.env` con tu contraseña real:
   ```
   DATABASE_URL=postgresql://postgres:TU_PASSWORD@localhost:5432/asistencia_institucional_db
   ```
2. Ejecutá manualmente en esa base los scripts de `init/` (01, 02, 03) o los de `Scripts SQL/`.

---

## Pruebas del patrón Cache-Aside

### 1. Verificar conexiones

```powershell
curl http://localhost:3000/api/health
curl http://localhost:3000/api/health/redis
```

`/api/health/redis` debe responder `"ping": "PONG"`.

### 2. Cache MISS (primera consulta)

```powershell
curl http://localhost:3000/api/alumnos/1/asistencia/1
```

Respuesta esperada:

```json
{
  "alumnoId": 1,
  "comisionId": 1,
  "porcentaje": 75,
  "nivel": "regular",
  "cached": false,
  "source": "database",
  "cacheKey": "asistencia:1:1",
  "ttlSeconds": 120
}
```

### 3. Cache HIT (segunda consulta, misma URL)

```powershell
curl http://localhost:3000/api/alumnos/1/asistencia/1
```

Ahora `"cached": true` y `"source": "redis"`.

### 4. Ver clave y TTL en Redis

```powershell
docker exec -it asistencias_redis redis-cli GET asistencia:1:1
docker exec -it asistencias_redis redis-cli TTL asistencia:1:1
```

### 5. Usuario por DNI

```powershell
curl http://localhost:3000/api/usuarios/dni/40123456
```

Clave: `users:dni:40123456`.

### 6. Fallback (Redis caído)

```powershell
docker stop asistencias_redis
curl http://localhost:3000/api/alumnos/1/asistencia/1
```

La API sigue respondiendo con `"source": "database"`. Reiniciá Redis con `docker start asistencias_redis`.

---

## Flujo Cache-Aside

```
Cliente → API → ¿Existe clave en Redis?
                    │
         SÍ (HIT) ──┴──→ Respuesta rápida
         NO (MISS) ──→ PostgreSQL (fn_calcular_porcentaje_asistencia)
                    ──→ SET en Redis con TTL
                    ──→ Respuesta
```

---

## Checklist: Integración de Caché con Redis

### 1. Fase de Diseño y Selección

- [x] Identificamos 2 endpoints estratégicos (alta lectura, baja escritura).
- [x] Listado de endpoints cacheados:
  - *Endpoint 1:* `GET /api/alumnos/:id/asistencia/:comisionId`
  - *Endpoint 2:* `GET /api/usuarios/dni/:dni`
- [x] El caso de uso soporta **consistencia eventual** (TTL 120 s / 300 s).

### 2. Configuración (Setup)

- [x] Cliente Redis instalado (`ioredis`).
- [x] Conexión exitosa con Redis (`GET /api/health/redis` → PONG).
- [x] **Fallback:** si Redis cae, la app consulta PostgreSQL directamente.

### 3. Implementación del Patrón Cache-Aside

- [x] El endpoint verifica primero si la clave existe en Redis.
- [x] **Cache HIT:** retorna sin ir a la DB.
- [x] **Cache MISS:** consulta PostgreSQL.
- [x] **Población:** guarda resultado en Redis con TTL.
- [x] Respuesta al cliente en todos los flujos.

### 4. Buenas Prácticas Técnicas

- [x] **Nomenclatura:** claves con `:` → `asistencia:1:1`, `users:dni:40123456`.
- [x] **TTL:** toda clave tiene tiempo de vida configurado.

---

## Qué se hizo (resumen)

- API Node.js con patrón **Cache-Aside** entre Redis y PostgreSQL.
- Docker con PostgreSQL (puerto 5433) y Redis (puerto 6379).
- Dos endpoints cacheados con claves `asistencia:id:comisionId` y `users:dni:dni`.
- TTL configurado (120 s / 300 s) y **fallback** a PostgreSQL si Redis no responde.
- Pruebas en navegador: conexión Redis (PONG) y Cache HIT demostrado.

---

## Capturas de prueba

> Guardá tus capturas en `imagenes/` con estos nombres para que se vean en GitHub.

### API — endpoints disponibles

<img width="900" alt="API endpoints localhost:3000" src="imagenes/01-api-endpoints.png" />

### Redis conectado (PING → PONG)

<img width="900" alt="Redis health PONG" src="imagenes/02-redis-pong.png" />

### Cache HIT — dato servido desde Redis

<img width="900" alt="Cache HIT source redis" src="imagenes/03-cache-hit.png" />

Respuesta: `"cached": true`, `"source": "redis"`, `"cacheKey": "asistencia:1:1"`, `"ttlSeconds": 120`.

---

## Datos de prueba

| Alumno | DNI | Comisión | % esperado |
|--------|-----|----------|------------|
| Roman (id 1) | 40123456 | 1 | 75 % (regular) |
| Oriana (id 3) | 40345678 | 1 | 50 % (en_riesgo) |
