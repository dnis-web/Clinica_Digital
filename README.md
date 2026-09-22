# Clínica Digital — Sistema de Gestión Clínica

Plataforma web para digitalizar el agendamiento de citas, el expediente clínico electrónico, la
gestión de usuarios y la comunicación con pacientes de una clínica de salud que actualmente opera
con procesos manuales.

Proyecto desarrollado para el curso de **Seminario de Tecnología de Información**, Universidad
Mariano Gálvez, Sección A, Plan Fin de Semana.

## Nota sobre la arquitectura (adaptación de la guía DevOps)

La guía de este entregable usa como ejemplo genérico una arquitectura de **microservicios**
(auth, catálogo, pedidos, pagos) con PostgreSQL. **Este proyecto no está diseñado como
microservicios**: es una aplicación **monolítica** construida en **PHP con el framework Laravel**,
organizada internamente por módulos (Autenticación/Usuarios, Citas, Expediente Clínico,
Notificaciones, Pagos), consistente con la Arquitectura del Sistema ya definida y corregida en
entregas anteriores del proyecto (servidor de aplicación PHP/Laravel detrás de Nginx, base de
datos **MySQL**, no PostgreSQL).

Por eso, en este repositorio:
- Se usa **un solo Dockerfile** para el servicio de aplicación (el monolito Laravel), en vez de
  un Dockerfile por cada "microservicio" ficticio.
- El motor de base de datos en `docker-compose.yml` es **MySQL 8**, no PostgreSQL, para ser
  coherente con el modelo relacional, el diccionario de datos y los scripts SQL ya construidos
  y probados por el equipo.
- Se mantiene **Redis** tal como pide la guía, utilizado aquí como caché de sesiones/consultas y
  como backend de colas (por ejemplo, para el envío asíncrono de notificaciones por correo o
  WhatsApp), que es un uso perfectamente válido dentro de una arquitectura monolítica.

## Estructura del repositorio

```
.
├── README.md
├── .gitignore
├── .env.example
├── src/              # Código fuente de la aplicación Laravel (monolito)
├── docs/             # Documentación del proyecto (modelo relacional, diccionario de datos,
│                      # arquitectura, requerimientos, etc.)
├── docker/           # Dockerfile, configuración de Nginx y docker-compose.yml
└── tests/            # Pruebas automatizadas (PHPUnit)
```

## Requisitos previos

- Docker Desktop (o Docker Engine + Docker Compose) instalado.
- Git.
- Copia local de este repositorio (`git clone ...`).

## Cómo levantar el proyecto localmente

1. Clonar el repositorio y entrar a la carpeta:
   ```bash
   git clone https://github.com/<usuario-o-equipo>/clinica-digital.git
   cd clinica-digital
   ```

2. Copiar el archivo de variables de entorno de ejemplo:
   ```bash
   cp .env.example .env
   ```
   Ajustar los valores de `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` según se necesite.

3. Levantar los contenedores desde la carpeta `docker`:
   ```bash
   cd docker
   docker compose up -d --build
   ```

4. Instalar dependencias de Laravel dentro del contenedor de la aplicación (solo la primera vez):
   ```bash
   docker compose exec app composer install
   docker compose exec app php artisan key:generate
   docker compose exec app php artisan migrate
   ```

5. Acceder a los servicios:
   | Servicio | URL |
   |---|---|
   | Aplicación web | http://localhost:8080 |
   | phpMyAdmin | http://localhost:8081 |
   | MySQL | localhost:3306 |
   | Redis | localhost:6379 |

6. Para detener los contenedores:
   ```bash
   docker compose down
   ```

## Ramas de trabajo (Git Flow simplificado)

- `main` → código estable, listo para producción.
- `develop` → integración de las funcionalidades ya probadas.
- `feature/<nombre-modulo>` → una rama por funcionalidad en desarrollo (ej. `feature/citas`,
  `feature/expediente-clinico`).

Todo cambio se integra a `develop` mediante Pull Request revisado por al menos un integrante
distinto de quien lo desarrolló, antes de fusionarse eventualmente a `main`.

## Equipo

| Integrante | Carné | Rol Scrum |
|---|---|---|
| Jorge Eduardo González | 0494-22-6231 | Scrum Master |
| José Iván Salazar | 0494-05-4804 | Product Owner |
| Diego Alejandro Arriola | 0494-22-6594 | Desarrollador Frontend |
| Denis Rogelio Gómez | 0494-22-2045 | Desarrollador Backend |

## Documentación adicional

Ver la carpeta [`/docs`](./docs) para el modelo relacional, el diccionario de datos, la
arquitectura del sistema, los requerimientos y las reglas de negocio ya documentadas en entregas
previas del proyecto.
