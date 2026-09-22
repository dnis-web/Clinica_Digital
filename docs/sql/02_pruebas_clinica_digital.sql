-- ============================================================
-- DATOS Y PRUEBAS BÁSICAS - clinica_digital
-- Ejecutar DESPUÉS de clinica_digital_mysql.sql
-- ============================================================

USE clinica_digital;

-- 1) Crear clínica en plan Gratuito.
INSERT INTO clinica(nombre, direccion, telefono, correo, id_plan)
SELECT 'Clínica Demo Guatemala',
       'Ciudad de Guatemala',
       '2222-2222',
       'contacto@clinicademo.gt',
       id_plan
FROM plan_suscripcion
WHERE nombre_plan = 'Gratuito';

SET @id_clinica = LAST_INSERT_ID();

-- 2) Crear primer administrador (bootstrap).
-- En una aplicación real, reemplazar por un hash bcrypt/Argon2 válido.
INSERT INTO usuario
(id_clinica, nombre, apellido, correo, password_hash, estado, id_rol)
SELECT @id_clinica, 'Admin', 'Principal', 'admin@clinicademo.gt',
       'HASH_DEMO_REEMPLAZAR_POR_BCRYPT', TRUE, id_rol
FROM rol
WHERE nombre_rol = 'Administrador';

SET @id_admin = LAST_INSERT_ID();

-- 3) Crear cuenta de médico usando el procedimiento protegido.
CALL sp_crear_usuario(
    @id_admin,
    @id_clinica,
    'Ana',
    'López',
    'ana.lopez@clinicademo.gt',
    'HASH_DEMO_REEMPLAZAR_POR_BCRYPT',
    'Médico'
);

SELECT id_usuario INTO @id_usuario_medico
FROM usuario
WHERE correo = 'ana.lopez@clinicademo.gt';

INSERT INTO medico
(id_clinica, id_usuario, nombres, apellidos, colegiado, especialidad, telefono, correo, estado)
VALUES
(@id_clinica, @id_usuario_medico, 'Ana', 'López', 'COL-1001',
 'Medicina General', '5555-1001', 'ana.lopez@clinicademo.gt', TRUE);

SET @id_medico = LAST_INSERT_ID();

-- 4) Registrar paciente.
-- El trigger crea automáticamente su expediente clínico.
INSERT INTO paciente
(id_clinica, id_usuario, dpi, nombres, apellidos, fecha_nacimiento,
 telefono, correo, direccion, sexo, estado)
VALUES
(@id_clinica, NULL, '1234567890101', 'Carlos', 'Pérez', '1995-05-20',
 '5555-2001', 'carlos.perez@example.com', 'Ciudad de Guatemala', 'M', TRUE);

SET @id_paciente = LAST_INSERT_ID();

-- 5) Agendar cita.
CALL sp_agendar_cita(
    @id_paciente,
    @id_medico,
    DATE_ADD(CURDATE(), INTERVAL 2 DAY),
    '09:00:00',
    '09:30:00',
    'Consulta general'
);

SELECT MAX(id_cita) INTO @id_cita
FROM cita
WHERE id_paciente = @id_paciente
  AND id_medico = @id_medico;

-- 6) Revisar agenda.
SELECT * FROM vw_agenda_medica WHERE id_cita = @id_cita;

-- 7) Probar función de edad.
SELECT fn_edad_paciente(@id_paciente) AS edad_paciente;

-- 8) Probar disponibilidad.
SELECT fn_medico_disponible(
    @id_medico,
    DATE_ADD(CURDATE(), INTERVAL 2 DAY),
    '09:10:00',
    '09:20:00'
) AS disponible_esperado_0;

SELECT fn_medico_disponible(
    @id_medico,
    DATE_ADD(CURDATE(), INTERVAL 2 DAY),
    '10:00:00',
    '10:30:00'
) AS disponible_esperado_1;

-- 9) Registrar consulta por el médico asignado.
CALL sp_registrar_consulta(
    @id_usuario_medico,
    @id_cita,
    'Diagnóstico de prueba',
    'Tratamiento de prueba',
    'Paciente estable'
);

-- 10) Consultar historial clínico.
SELECT * FROM vw_historial_clinico WHERE id_paciente = @id_paciente;

-- 11) Registrar pago.
CALL sp_registrar_pago(@id_cita, 250.00, 'Efectivo', 'Pagado');

SELECT fn_total_pagado_cita(@id_cita) AS total_pagado;
SELECT * FROM vw_estado_pagos WHERE id_cita = @id_cita;

-- 12) Registrar acceso en bitácora.
CALL sp_registrar_acceso(
    @id_admin,
    'admin@clinicademo.gt',
    '127.0.0.1',
    TRUE,
    'Inicio de sesión de prueba'
);

SELECT * FROM bitacora_acceso ORDER BY id_acceso DESC LIMIT 5;

-- ============================================================
-- PRUEBA DE REGLA DE NEGOCIO: CITA SOLAPADA
-- Descomentar para comprobar que el trigger rechaza la operación.
-- ============================================================
-- CALL sp_agendar_cita(
--     @id_paciente,
--     @id_medico,
--     DATE_ADD(CURDATE(), INTERVAL 2 DAY),
--     '09:15:00',
--     '09:45:00',
--     'Esta cita debe ser rechazada por solapamiento'
-- );

-- ============================================================
-- PRUEBAS DE OBJETOS CREADOS
-- ============================================================
SHOW TABLES;
SHOW TRIGGERS FROM clinica_digital;
SHOW FUNCTION STATUS WHERE Db = 'clinica_digital';
SHOW PROCEDURE STATUS WHERE Db = 'clinica_digital';
SHOW FULL TABLES IN clinica_digital WHERE Table_type = 'VIEW';
