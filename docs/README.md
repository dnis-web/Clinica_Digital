# /docs — Documentación del proyecto

Carpeta destinada a la documentación ya elaborada en entregas previas del curso:

- `01-antecedentes-objetivos-modelo-negocio.pdf`
- `02-determinacion-requerimientos.pdf`
- `03-analisis-uml-diagrama-clases.pdf`
- `04-modelo-relacional-diccionario-datos.pdf`
- `05-arquitectura-del-sistema.pdf`
- `sql/` → scripts SQL de la base de datos (`clinica_digital_mysql.sql`,
  `pruebas_clinica_digital.sql`, `respaldo_clinica_digital.sql`). Esta subcarpeta se monta
  automáticamente en el contenedor de MySQL (`docker-entrypoint-initdb.d`), por lo que al levantar
  el proyecto con `docker compose up`, la base de datos se inicializa sola con la estructura ya
  definida.

*(Responsable de mantener esta carpeta actualizada: Product Owner — José Iván Salazar)*
