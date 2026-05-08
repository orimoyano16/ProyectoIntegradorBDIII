EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)
SELECT * FROM usuario WHERE email = 'email120322@gmail.com';

-- Formato JSON SIN OPTIMIZAR 
[
  {
    "Plan": {
      "Node Type": "Seq Scan",
      "Parallel Aware": false,
      "Async Capable": false,
      "Relation Name": "usuario",
      "Schema": "public",
      "Alias": "usuario",
      "Startup Cost": 0.00,
      "Total Cost": 5348.00,
      "Plan Rows": 1,
      "Plan Width": 84,
      "Actual Startup Time": 26.602,
      "Actual Total Time": 45.830,
      "Actual Rows": 1,
      "Actual Loops": 1,
      "Output": ["usuario_id", "nombre", "apellido", "email", "password_hash", "dni", "rol", "carrera_id"],
      "Filter": "((usuario.email)::text = 'email120453@gmail.com'::text)",
      "Rows Removed by Filter": 199999,
      "Shared Hit Blocks": 2848,
      "Shared Read Blocks": 0,
      "Shared Dirtied Blocks": 0,
      "Shared Written Blocks": 0,
      "Local Hit Blocks": 0,
      "Local Read Blocks": 0,
      "Local Dirtied Blocks": 0,
      "Local Written Blocks": 0,
      "Temp Read Blocks": 0,
      "Temp Written Blocks": 0,
      "Shared I/O Read Time": 0.000,
      "Shared I/O Write Time": 0.000,
      "Local I/O Read Time": 0.000,
      "Local I/O Write Time": 0.000,
      "Temp I/O Read Time": 0.000,
      "Temp I/O Write Time": 0.000
    },
    "Query Identifier": -5346184146192494060,
    "Planning": {
      "Shared Hit Blocks": 0,
      "Shared Read Blocks": 0,
      "Shared Dirtied Blocks": 0,
      "Shared Written Blocks": 0,
      "Local Hit Blocks": 0,
      "Local Read Blocks": 0,
      "Local Dirtied Blocks": 0,
      "Local Written Blocks": 0,
      "Temp Read Blocks": 0,
      "Temp Written Blocks": 0,
      "Shared I/O Read Time": 0.000,
      "Shared I/O Write Time": 0.000,
      "Local I/O Read Time": 0.000,
      "Local I/O Write Time": 0.000,
      "Temp I/O Read Time": 0.000,
      "Temp I/O Write Time": 0.000
    },
    "Planning Time": 0.127,
    "Triggers": [
    ],
    "Execution Time": 45.861
  }
]

-- Formato JSON  OPTIMIZADO 

```
[
  {
    "Plan": {
      "Node Type": "Index Scan",
      "Parallel Aware": false,
      "Async Capable": false,
      "Scan Direction": "Forward",
      "Index Name": "idx_usuario_email",
      "Relation Name": "usuario",
      "Schema": "public",
      "Alias": "usuario",
      "Startup Cost": 0.00,
      "Total Cost": 2.22,
      "Plan Rows": 1,
      "Plan Width": 84,
      "Actual Startup Time": 0.024,
      "Actual Total Time": 0.026,
      "Actual Rows": 1,
      "Actual Loops": 1,
      "Output": ["usuario_id", "nombre", "apellido", "email", "password_hash", "dni", "rol", "carrera_id"],
      "Index Cond": "((usuario.email)::text = 'email120453@gmail.com'::text)",
      "Rows Removed by Index Recheck": 0,
      "Shared Hit Blocks": 3,
      "Shared Read Blocks": 0,
      "Shared Dirtied Blocks": 0,
      "Shared Written Blocks": 0,
      "Local Hit Blocks": 0,
      "Local Read Blocks": 0,
      "Local Dirtied Blocks": 0,
      "Local Written Blocks": 0,
      "Temp Read Blocks": 0,
      "Temp Written Blocks": 0,
      "Shared I/O Read Time": 0.000,
      "Shared I/O Write Time": 0.000,
      "Local I/O Read Time": 0.000,
      "Local I/O Write Time": 0.000,
      "Temp I/O Read Time": 0.000,
      "Temp I/O Write Time": 0.000
    },
    "Query Identifier": -5346184146192494060,
    "Planning": {
      "Shared Hit Blocks": 0,
      "Shared Read Blocks": 0,
      "Shared Dirtied Blocks": 0,
      "Shared Written Blocks": 0,
      "Local Hit Blocks": 0,
      "Local Read Blocks": 0,
      "Local Dirtied Blocks": 0,
      "Local Written Blocks": 0,
      "Temp Read Blocks": 0,
      "Temp Written Blocks": 0,
      "Shared I/O Read Time": 0.000,
      "Shared I/O Write Time": 0.000,
      "Local I/O Read Time": 0.000,
      "Local I/O Write Time": 0.000,
      "Temp I/O Read Time": 0.000,
      "Temp I/O Write Time": 0.000
    },
    "Planning Time": 0.142,
    "Triggers": [
    ],
    "Execution Time": 0.054
  }
]

```