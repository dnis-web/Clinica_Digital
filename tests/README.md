# /tests — Pruebas automatizadas

Pruebas con **PHPUnit** (incluido en Laravel por defecto), organizadas así:

```
tests/
├── Unit/          # Pruebas unitarias (ej. cálculo de disponibilidad de un médico)
└── Feature/       # Pruebas de endpoints/funcionalidades completas (ej. agendar una cita)
```

## Ejecutar las pruebas dentro del contenedor

```bash
cd docker
docker compose exec app php artisan test
```

## Ejemplo de caso a cubrir (Sprint 1)

- `AgendarCitaTest`: verifica que el sistema **rechace** agendar dos citas para el mismo médico
  en un horario que se traslapa (regla de negocio ya implementada como trigger en la base de
  datos — esta prueba valida que el backend también la respete a nivel de aplicación).

*(Responsable: Denis — Backend, con apoyo de todo el equipo en la fase de pruebas del Sprint)*
