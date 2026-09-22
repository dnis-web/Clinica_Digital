# /src — Código fuente de la aplicación

Aquí vivirá la aplicación Laravel (el monolito) organizada internamente por módulos, sin ser
microservicios separados:

```
src/
├── app/
│   ├── Http/Controllers/
│   │   ├── AuthController.php
│   │   ├── CitaController.php
│   │   ├── ExpedienteController.php
│   │   ├── PagoController.php
│   │   └── NotificacionController.php
│   ├── Models/
│   └── Services/
├── database/
│   └── migrations/
├── routes/
│   └── web.php / api.php
└── ...(estructura estándar de Laravel)
```

## Cómo instalar Laravel aquí

Desde la raíz del repositorio, con Docker ya configurado:

```bash
cd docker
docker compose run --rm app composer create-project laravel/laravel .
```

Esto generará la estructura completa de Laravel dentro de esta carpeta `/src`, respetando el
`docker-compose.yml` y el `Dockerfile` ya definidos.

*(Responsable de esta carpeta: Diego — Frontend / Denis — Backend, según el módulo)*
