# Clínica Digital — Sistema de Gestión Clínica

Plataforma web para digitalizar el agendamiento de citas, el expediente clínico electrónico, la
gestión de usuarios y la comunicación con pacientes de una clínica de salud que actualmente opera
con procesos manuales.

Proyecto desarrollado para el curso de **Seminario de Tecnología de Información**, Universidad
Mariano Gálvez, Sección A, Plan Fin de Semana.

## Arquitectura

El sistema es una aplicación **monolítica**, organizada internamente en capas (presentación,
lógica de negocio y acceso a datos) y por módulos funcionales: Autenticación/Usuarios, Citas,
Expediente Clínico, Notificaciones y Pagos. Se construye en **PHP con el framework Laravel**,
detrás de un servidor **Nginx**, con **MySQL** como motor de base de datos — la misma decisión
técnica ya documentada y corregida en la Arquitectura del Sistema del proyecto.

Componentes contenerizados en este repositorio:

| Servicio | Tecnología | Rol |
|---|---|---|
| `app` | PHP 8.2 + Laravel | Lógica de la aplicación: usuarios, citas, expediente clínico, notificaciones y pagos |
| `webserver` | Nginx | Servidor web, enruta las peticiones hacia `app` |
| `db` | MySQL 8 | Base de datos relacional del sistema |
| `phpmyadmin` | phpMyAdmin | Administración visual de la base de datos |
| `redis` | Redis 7 | Caché de sesiones/consultas y cola para el envío asíncrono de notificaciones (correo, WhatsApp) |

## Estructura del repositorio

- `README.md`, `.gitignore`, `.env.example` — en la raíz del proyecto.
- `src/` — código fuente de la aplicación Laravel (monolito).
- `docs/` — documentación del proyecto (modelo relacional, diccionario de datos, arquitectura,
  requerimientos, scripts SQL en `docs/sql/`, etc.).
- `docker/` — Dockerfile, configuración de Nginx y `docker-compose.yml`.
- `tests/` — pruebas automatizadas (PHPUnit).

## Requisitos previos

- Docker Desktop (o Docker Engine + Docker Compose) instalado.
- Git.
- Copia local de este repositorio (`git clone ...`).

## Cómo levantar el proyecto localmente

1. Clonar el repositorio y entrar a la carpeta:
   ```bash
   git clone https://github.com/dnis-web/Clinica_Digital.git
   cd Clinica_Digital
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
