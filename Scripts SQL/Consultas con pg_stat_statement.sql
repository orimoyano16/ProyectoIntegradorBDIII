create extension pg_stat_statements;

--1. CONSULTAS MÁS LENTAS
SELECT query, total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;

--2. CONSULTAS MÁS EJECUTADAS
SELECT query, calls
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 5;

--3. CONSULTAS CON MÁS I/O
SELECT query, shared_blks_read
FROM pg_stat_statements
ORDER BY shared_blks_read DESC
LIMIT 5;

--4. CONSULTAS CON MÁS WAL
SELECT query, wal_bytes
FROM pg_stat_statements
ORDER BY wal_bytes DESC
LIMIT 5;

--5. CONSULTAS CON MÁS PLANIFICACIÓN
SELECT query, total_plan_time
FROM pg_stat_statements
ORDER BY total_plan_time DESC
LIMIT 5;