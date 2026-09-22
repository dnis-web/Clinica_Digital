-- ============================================================
-- PROYECTO: Plataforma digital para clínica de salud
-- SGBD: MySQL 8.0+
-- Base de datos: clinica_digital
-- Implementación corregida a partir del modelo relacional,
-- requerimientos, reglas de negocio y arquitectura del proyecto.
-- ============================================================

DROP DATABASE IF EXISTS clinica_digital;
CREATE DATABASE clinica_digital
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE clinica_digital;

-- ============================================================
-- 1. TABLAS MAESTRAS
-- ============================================================

CREATE TABLE plan_suscripcion (
    id_plan INT AUTO_INCREMENT PRIMARY KEY,
    nombre_plan VARCHAR(50) NOT NULL,
    limite_pacientes INT NULL,
    limite_citas INT NULL,
    permite_pdf BOOLEAN NOT NULL DEFAULT FALSE,
    permite_whatsapp BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_plan_nombre UNIQUE (nombre_plan),
    CONSTRAINT chk_plan_limite_pacientes CHECK (limite_pacientes IS NULL OR limite_pacientes > 0),
    CONSTRAINT chk_plan_limite_citas CHECK (limite_citas IS NULL OR limite_citas > 0)
) ENGINE=InnoDB;

CREATE TABLE clinica (
    id_clinica INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    direccion VARCHAR(250) NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(150) NULL,
    id_plan INT NOT NULL,
    CONSTRAINT fk_clinica_plan
        FOREIGN KEY (id_plan) REFERENCES plan_suscripcion(id_plan)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL,
    CONSTRAINT uq_rol_nombre UNIQUE (nombre_rol)
) ENGINE=InnoDB;

-- ============================================================
-- 2. SEGURIDAD Y USUARIOS
-- Corrección técnica:
-- Se agrega id_clinica para aislar usuarios por clínica.
-- ============================================================

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_clinica INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_rol INT NOT NULL,
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_clinica
        FOREIGN KEY (id_clinica) REFERENCES clinica(id_clinica)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_usuario_rol ON usuario(id_rol);
CREATE INDEX idx_usuario_clinica ON usuario(id_clinica);

-- ============================================================
-- 3. PACIENTES Y MÉDICOS
-- Correcciones técnicas:
-- - id_clinica permite aplicar límites del plan por clínica.
-- - id_usuario relaciona la cuenta de acceso con el perfil.
--   En paciente puede quedar NULL mientras el portal sea futuro.
-- ============================================================

CREATE TABLE paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    id_clinica INT NOT NULL,
    id_usuario INT NULL,
    dpi VARCHAR(20) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(150) NULL,
    direccion VARCHAR(250) NULL,
    sexo CHAR(1) NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_paciente_clinica_dpi UNIQUE (id_clinica, dpi),
    CONSTRAINT uq_paciente_usuario UNIQUE (id_usuario),
    CONSTRAINT chk_paciente_sexo CHECK (sexo IN ('M','F')),
    CONSTRAINT fk_paciente_clinica
        FOREIGN KEY (id_clinica) REFERENCES clinica(id_clinica)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_paciente_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_paciente_nombre ON paciente(apellidos, nombres);
CREATE INDEX idx_paciente_correo ON paciente(correo);
CREATE INDEX idx_paciente_clinica_estado ON paciente(id_clinica, estado);

CREATE TABLE medico (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    id_clinica INT NOT NULL,
    id_usuario INT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    colegiado VARCHAR(50) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(150) NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_medico_clinica_colegiado UNIQUE (id_clinica, colegiado),
    CONSTRAINT uq_medico_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_medico_clinica
        FOREIGN KEY (id_clinica) REFERENCES clinica(id_clinica)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_medico_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_medico_especialidad ON medico(especialidad);
CREATE INDEX idx_medico_clinica_estado ON medico(id_clinica, estado);

-- ============================================================
-- 4. CITAS Y EXPEDIENTE CLÍNICO
-- ============================================================

CREATE TABLE cita (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado_cita VARCHAR(20) NOT NULL DEFAULT 'Programada',
    motivo_consulta VARCHAR(250) NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cita_horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT chk_cita_estado CHECK (estado_cita IN ('Programada','Cancelada','Atendida')),
    CONSTRAINT fk_cita_paciente
        FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_medico
        FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_cita_medico_fecha ON cita(id_medico, fecha_cita, hora_inicio, hora_fin);
CREATE INDEX idx_cita_paciente_fecha ON cita(id_paciente, fecha_cita);
CREATE INDEX idx_cita_estado_fecha ON cita(estado_cita, fecha_cita);

CREATE TABLE expediente_clinico (
    id_expediente INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    fecha_apertura DATE NOT NULL DEFAULT (CURRENT_DATE),
    observaciones_generales TEXT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_expediente_paciente UNIQUE (id_paciente),
    CONSTRAINT fk_expediente_paciente
        FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE consulta_medica (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_expediente INT NOT NULL,
    id_medico INT NOT NULL,
    id_cita INT NOT NULL,
    fecha_consulta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnostico TEXT NOT NULL,
    tratamiento TEXT NULL,
    observaciones TEXT NULL,
    CONSTRAINT uq_consulta_cita UNIQUE (id_cita),
    CONSTRAINT fk_consulta_expediente
        FOREIGN KEY (id_expediente) REFERENCES expediente_clinico(id_expediente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_medico
        FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_cita
        FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_consulta_expediente_fecha ON consulta_medica(id_expediente, fecha_consulta);
CREATE INDEX idx_consulta_medico_fecha ON consulta_medica(id_medico, fecha_consulta);

CREATE TABLE receta (
    id_receta INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    fecha_emision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    indicaciones TEXT NOT NULL,
    archivo_pdf VARCHAR(500) NULL,
    CONSTRAINT fk_receta_consulta
        FOREIGN KEY (id_consulta) REFERENCES consulta_medica(id_consulta)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_receta_consulta ON receta(id_consulta);

-- ============================================================
-- 5. PAGOS Y NOTIFICACIONES
-- ============================================================

CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_cita INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago VARCHAR(50) NOT NULL,
    estado_pago VARCHAR(20) NOT NULL DEFAULT 'Pagado',
    CONSTRAINT chk_pago_monto CHECK (monto > 0),
    CONSTRAINT chk_pago_metodo CHECK (metodo_pago IN ('Efectivo','Tarjeta','Transferencia')),
    CONSTRAINT chk_pago_estado CHECK (estado_pago IN ('Pendiente','Pagado')),
    CONSTRAINT fk_pago_paciente
        FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pago_cita
        FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_pago_paciente_fecha ON pago(id_paciente, fecha_pago);
CREATE INDEX idx_pago_cita ON pago(id_cita);

CREATE TABLE notificacion (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_cita INT NOT NULL,
    tipo_notificacion VARCHAR(30) NOT NULL,
    fecha_envio DATETIME NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT chk_notificacion_tipo CHECK (tipo_notificacion IN ('Correo','WhatsApp','SMS')),
    CONSTRAINT chk_notificacion_estado CHECK (estado IN ('Pendiente','Enviada','Error')),
    CONSTRAINT fk_notificacion_paciente
        FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_notificacion_cita
        FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_notificacion_estado ON notificacion(estado, fecha_envio);
CREATE INDEX idx_notificacion_cita ON notificacion(id_cita);

-- Arquitectura de seguridad: bitácora de accesos.
CREATE TABLE bitacora_acceso (
    id_acceso BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NULL,
    correo_intentado VARCHAR(150) NULL,
    fecha_acceso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45) NULL,
    exitoso BOOLEAN NOT NULL,
    detalle VARCHAR(255) NULL,
    CONSTRAINT fk_bitacora_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_bitacora_fecha ON bitacora_acceso(fecha_acceso);
CREATE INDEX idx_bitacora_usuario ON bitacora_acceso(id_usuario, fecha_acceso);

-- ============================================================
-- 6. DATOS MAESTROS INICIALES
-- ============================================================

INSERT INTO plan_suscripcion
(nombre_plan, limite_pacientes, limite_citas, permite_pdf, permite_whatsapp)
VALUES
('Gratuito', 10, 20, FALSE, FALSE),
('Premium', NULL, NULL, TRUE, TRUE);

INSERT INTO rol (nombre_rol)
VALUES
('Administrador'),
('Recepción'),
('Médico'),
('Paciente');

-- Ejemplo opcional para pruebas:
-- INSERT INTO clinica(nombre, direccion, telefono, correo, id_plan)
-- VALUES ('Clínica Demo', 'Ciudad de Guatemala', '2222-2222',
--         'contacto@clinicademo.gt',
--         (SELECT id_plan FROM plan_suscripcion WHERE nombre_plan='Gratuito'));

-- IMPORTANTE:
-- password_hash debe contener un hash seguro generado en el backend (bcrypt/Argon2).
-- Nunca almacenar contraseñas en texto plano.

-- ============================================================
-- 7. FUNCIONES
-- ============================================================

DELIMITER $$

DROP FUNCTION IF EXISTS fn_edad_paciente $$
CREATE FUNCTION fn_edad_paciente(p_id_paciente INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_fecha DATE;

    SELECT fecha_nacimiento
      INTO v_fecha
      FROM paciente
     WHERE id_paciente = p_id_paciente;

    IF v_fecha IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN TIMESTAMPDIFF(YEAR, v_fecha, CURDATE());
END $$

DROP FUNCTION IF EXISTS fn_total_pagado_cita $$
CREATE FUNCTION fn_total_pagado_cita(p_id_cita INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT COALESCE(SUM(monto), 0)
      INTO v_total
      FROM pago
     WHERE id_cita = p_id_cita
       AND estado_pago = 'Pagado';

    RETURN v_total;
END $$

DROP FUNCTION IF EXISTS fn_medico_disponible $$
CREATE FUNCTION fn_medico_disponible(
    p_id_medico INT,
    p_fecha DATE,
    p_hora_inicio TIME,
    p_hora_fin TIME
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_conflictos INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_conflictos
      FROM cita
     WHERE id_medico = p_id_medico
       AND fecha_cita = p_fecha
       AND estado_cita <> 'Cancelada'
       AND p_hora_inicio < hora_fin
       AND p_hora_fin > hora_inicio;

    RETURN (v_conflictos = 0);
END $$

-- ============================================================
-- 8. TRIGGERS
-- ============================================================

DROP TRIGGER IF EXISTS trg_paciente_limite_plan_bi $$
CREATE TRIGGER trg_paciente_limite_plan_bi
BEFORE INSERT ON paciente
FOR EACH ROW
BEGIN
    DECLARE v_limite INT DEFAULT NULL;
    DECLARE v_actuales INT DEFAULT 0;

    IF NEW.estado = TRUE THEN
        SELECT ps.limite_pacientes
          INTO v_limite
          FROM clinica c
          JOIN plan_suscripcion ps ON ps.id_plan = c.id_plan
         WHERE c.id_clinica = NEW.id_clinica;

        IF v_limite IS NOT NULL THEN
            SELECT COUNT(*)
              INTO v_actuales
              FROM paciente
             WHERE id_clinica = NEW.id_clinica
               AND estado = TRUE;

            IF v_actuales >= v_limite THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'La clínica alcanzó el límite de pacientes activos de su plan';
            END IF;
        END IF;
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_paciente_limite_plan_bu $$
CREATE TRIGGER trg_paciente_limite_plan_bu
BEFORE UPDATE ON paciente
FOR EACH ROW
BEGIN
    DECLARE v_limite INT DEFAULT NULL;
    DECLARE v_actuales INT DEFAULT 0;

    IF NEW.estado = TRUE
       AND (OLD.estado = FALSE OR NEW.id_clinica <> OLD.id_clinica) THEN

        SELECT ps.limite_pacientes
          INTO v_limite
          FROM clinica c
          JOIN plan_suscripcion ps ON ps.id_plan = c.id_plan
         WHERE c.id_clinica = NEW.id_clinica;

        IF v_limite IS NOT NULL THEN
            SELECT COUNT(*)
              INTO v_actuales
              FROM paciente
             WHERE id_clinica = NEW.id_clinica
               AND estado = TRUE
               AND id_paciente <> OLD.id_paciente;

            IF v_actuales >= v_limite THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'La clínica alcanzó el límite de pacientes activos de su plan';
            END IF;
        END IF;
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_paciente_crear_expediente_ai $$
CREATE TRIGGER trg_paciente_crear_expediente_ai
AFTER INSERT ON paciente
FOR EACH ROW
BEGIN
    INSERT INTO expediente_clinico
        (id_paciente, fecha_apertura, observaciones_generales, estado)
    VALUES
        (NEW.id_paciente, CURDATE(), NULL, TRUE);
END $$

DROP TRIGGER IF EXISTS trg_cita_validar_bi $$
CREATE TRIGGER trg_cita_validar_bi
BEFORE INSERT ON cita
FOR EACH ROW
BEGIN
    DECLARE v_conflictos INT DEFAULT 0;
    DECLARE v_clinica_paciente INT DEFAULT NULL;
    DECLARE v_clinica_medico INT DEFAULT NULL;
    DECLARE v_paciente_activo BOOLEAN DEFAULT FALSE;
    DECLARE v_medico_activo BOOLEAN DEFAULT FALSE;
    DECLARE v_limite_citas INT DEFAULT NULL;
    DECLARE v_citas_mes INT DEFAULT 0;

    IF NEW.hora_fin <= NEW.hora_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La hora final debe ser mayor que la hora de inicio';
    END IF;

    IF NEW.fecha_cita < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede programar una cita en una fecha pasada';
    END IF;

    SELECT id_clinica, estado
      INTO v_clinica_paciente, v_paciente_activo
      FROM paciente
     WHERE id_paciente = NEW.id_paciente;

    SELECT id_clinica, estado
      INTO v_clinica_medico, v_medico_activo
      FROM medico
     WHERE id_medico = NEW.id_medico;

    IF v_clinica_paciente IS NULL OR v_clinica_medico IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Paciente o médico inexistente';
    END IF;

    IF v_paciente_activo = FALSE OR v_medico_activo = FALSE THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Paciente y médico deben estar activos';
    END IF;

    IF v_clinica_paciente <> v_clinica_medico THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El paciente y el médico deben pertenecer a la misma clínica';
    END IF;

    IF NEW.estado_cita <> 'Cancelada' THEN
        SELECT COUNT(*)
          INTO v_conflictos
          FROM cita
         WHERE id_medico = NEW.id_medico
           AND fecha_cita = NEW.fecha_cita
           AND estado_cita <> 'Cancelada'
           AND NEW.hora_inicio < hora_fin
           AND NEW.hora_fin > hora_inicio;

        IF v_conflictos > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El médico ya tiene una cita activa en ese horario';
        END IF;

        SELECT ps.limite_citas
          INTO v_limite_citas
          FROM clinica c
          JOIN plan_suscripcion ps ON ps.id_plan = c.id_plan
         WHERE c.id_clinica = v_clinica_paciente;

        IF v_limite_citas IS NOT NULL THEN
            SELECT COUNT(*)
              INTO v_citas_mes
              FROM cita ci
              JOIN paciente pa ON pa.id_paciente = ci.id_paciente
             WHERE pa.id_clinica = v_clinica_paciente
               AND ci.estado_cita <> 'Cancelada'
               AND YEAR(ci.fecha_cita) = YEAR(NEW.fecha_cita)
               AND MONTH(ci.fecha_cita) = MONTH(NEW.fecha_cita);

            IF v_citas_mes >= v_limite_citas THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'La clínica alcanzó el límite mensual de citas de su plan';
            END IF;
        END IF;
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_cita_validar_bu $$
CREATE TRIGGER trg_cita_validar_bu
BEFORE UPDATE ON cita
FOR EACH ROW
BEGIN
    DECLARE v_conflictos INT DEFAULT 0;
    DECLARE v_clinica_paciente INT DEFAULT NULL;
    DECLARE v_clinica_medico INT DEFAULT NULL;
    DECLARE v_limite_citas INT DEFAULT NULL;
    DECLARE v_citas_mes INT DEFAULT 0;

    IF NEW.hora_fin <= NEW.hora_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La hora final debe ser mayor que la hora de inicio';
    END IF;

    IF (NEW.fecha_cita <> OLD.fecha_cita
        OR NEW.hora_inicio <> OLD.hora_inicio
        OR NEW.hora_fin <> OLD.hora_fin)
       AND NEW.fecha_cita < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede reprogramar una cita a una fecha pasada';
    END IF;

    SELECT id_clinica
      INTO v_clinica_paciente
      FROM paciente
     WHERE id_paciente = NEW.id_paciente;

    SELECT id_clinica
      INTO v_clinica_medico
      FROM medico
     WHERE id_medico = NEW.id_medico;

    IF v_clinica_paciente <> v_clinica_medico THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El paciente y el médico deben pertenecer a la misma clínica';
    END IF;

    IF NEW.estado_cita <> 'Cancelada' THEN
        SELECT COUNT(*)
          INTO v_conflictos
          FROM cita
         WHERE id_medico = NEW.id_medico
           AND fecha_cita = NEW.fecha_cita
           AND estado_cita <> 'Cancelada'
           AND id_cita <> OLD.id_cita
           AND NEW.hora_inicio < hora_fin
           AND NEW.hora_fin > hora_inicio;

        IF v_conflictos > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El médico ya tiene una cita activa en ese horario';
        END IF;

        SELECT ps.limite_citas
          INTO v_limite_citas
          FROM clinica c
          JOIN plan_suscripcion ps ON ps.id_plan = c.id_plan
         WHERE c.id_clinica = v_clinica_paciente;

        IF v_limite_citas IS NOT NULL THEN
            SELECT COUNT(*)
              INTO v_citas_mes
              FROM cita ci
              JOIN paciente pa ON pa.id_paciente = ci.id_paciente
             WHERE pa.id_clinica = v_clinica_paciente
               AND ci.estado_cita <> 'Cancelada'
               AND ci.id_cita <> OLD.id_cita
               AND YEAR(ci.fecha_cita) = YEAR(NEW.fecha_cita)
               AND MONTH(ci.fecha_cita) = MONTH(NEW.fecha_cita);

            IF v_citas_mes >= v_limite_citas THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'La clínica alcanzó el límite mensual de citas de su plan';
            END IF;
        END IF;
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_cita_notificacion_ai $$
CREATE TRIGGER trg_cita_notificacion_ai
AFTER INSERT ON cita
FOR EACH ROW
BEGIN
    IF NEW.estado_cita = 'Programada' THEN
        INSERT INTO notificacion
            (id_paciente, id_cita, tipo_notificacion, fecha_envio, estado)
        VALUES
            (NEW.id_paciente, NEW.id_cita, 'Correo', NULL, 'Pendiente');
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_consulta_marcar_atendida_ai $$
CREATE TRIGGER trg_consulta_marcar_atendida_ai
AFTER INSERT ON consulta_medica
FOR EACH ROW
BEGIN
    UPDATE cita
       SET estado_cita = 'Atendida'
     WHERE id_cita = NEW.id_cita
       AND estado_cita <> 'Cancelada';
END $$

DROP TRIGGER IF EXISTS trg_receta_plan_bi $$
CREATE TRIGGER trg_receta_plan_bi
BEFORE INSERT ON receta
FOR EACH ROW
BEGIN
    DECLARE v_permite_pdf BOOLEAN DEFAULT FALSE;

    IF NEW.archivo_pdf IS NOT NULL AND NEW.archivo_pdf <> '' THEN
        SELECT ps.permite_pdf
          INTO v_permite_pdf
          FROM consulta_medica cm
          JOIN expediente_clinico ec ON ec.id_expediente = cm.id_expediente
          JOIN paciente p ON p.id_paciente = ec.id_paciente
          JOIN clinica c ON c.id_clinica = p.id_clinica
          JOIN plan_suscripcion ps ON ps.id_plan = c.id_plan
         WHERE cm.id_consulta = NEW.id_consulta;

        IF v_permite_pdf = FALSE THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La generación/descarga de PDF requiere plan Premium';
        END IF;
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_notificacion_plan_bi $$
CREATE TRIGGER trg_notificacion_plan_bi
BEFORE INSERT ON notificacion
FOR EACH ROW
BEGIN
    DECLARE v_permite_whatsapp BOOLEAN DEFAULT FALSE;

    IF NEW.tipo_notificacion IN ('WhatsApp','SMS') THEN
        SELECT ps.permite_whatsapp
          INTO v_permite_whatsapp
          FROM paciente p
          JOIN clinica c ON c.id_clinica = p.id_clinica
          JOIN plan_suscripcion ps ON ps.id_plan = c.id_plan
         WHERE p.id_paciente = NEW.id_paciente;

        IF v_permite_whatsapp = FALSE THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'WhatsApp/SMS requiere plan Premium';
        END IF;
    END IF;
END $$

-- ============================================================
-- 9. PROCEDIMIENTOS ALMACENADOS
-- ============================================================

DROP PROCEDURE IF EXISTS sp_agendar_cita $$
CREATE PROCEDURE sp_agendar_cita(
    IN p_id_paciente INT,
    IN p_id_medico INT,
    IN p_fecha DATE,
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    IN p_motivo VARCHAR(250)
)
BEGIN
    INSERT INTO cita
        (id_paciente, id_medico, fecha_cita, hora_inicio, hora_fin,
         estado_cita, motivo_consulta)
    VALUES
        (p_id_paciente, p_id_medico, p_fecha, p_hora_inicio, p_hora_fin,
         'Programada', p_motivo);

    SELECT LAST_INSERT_ID() AS id_cita_creada;
END $$

DROP PROCEDURE IF EXISTS sp_reprogramar_cita $$
CREATE PROCEDURE sp_reprogramar_cita(
    IN p_id_cita INT,
    IN p_fecha DATE,
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cita WHERE id_cita = p_id_cita) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cita no existe';
    END IF;

    UPDATE cita
       SET fecha_cita = p_fecha,
           hora_inicio = p_hora_inicio,
           hora_fin = p_hora_fin,
           estado_cita = 'Programada'
     WHERE id_cita = p_id_cita;
END $$

DROP PROCEDURE IF EXISTS sp_cancelar_cita $$
CREATE PROCEDURE sp_cancelar_cita(
    IN p_id_cita INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cita WHERE id_cita = p_id_cita) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cita no existe';
    END IF;

    UPDATE cita
       SET estado_cita = 'Cancelada'
     WHERE id_cita = p_id_cita;
END $$

DROP PROCEDURE IF EXISTS sp_registrar_consulta $$
CREATE PROCEDURE sp_registrar_consulta(
    IN p_id_usuario_medico INT,
    IN p_id_cita INT,
    IN p_diagnostico TEXT,
    IN p_tratamiento TEXT,
    IN p_observaciones TEXT
)
BEGIN
    DECLARE v_id_medico INT DEFAULT NULL;
    DECLARE v_id_expediente INT DEFAULT NULL;
    DECLARE v_medico_cita INT DEFAULT NULL;
    DECLARE v_estado_cita VARCHAR(20) DEFAULT NULL;

    SELECT m.id_medico
      INTO v_id_medico
      FROM medico m
      JOIN usuario u ON u.id_usuario = m.id_usuario
      JOIN rol r ON r.id_rol = u.id_rol
     WHERE u.id_usuario = p_id_usuario_medico
       AND u.estado = TRUE
       AND m.estado = TRUE
       AND r.nombre_rol = 'Médico'
     LIMIT 1;

    IF v_id_medico IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no corresponde a un médico autorizado';
    END IF;

    SELECT ec.id_expediente, c.id_medico, c.estado_cita
      INTO v_id_expediente, v_medico_cita, v_estado_cita
      FROM cita c
      JOIN expediente_clinico ec ON ec.id_paciente = c.id_paciente
     WHERE c.id_cita = p_id_cita;

    IF v_id_expediente IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cita o expediente no encontrado';
    END IF;

    IF v_estado_cita = 'Cancelada' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede registrar una consulta para una cita cancelada';
    END IF;

    IF v_medico_cita <> v_id_medico THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo el médico asignado a la cita puede registrar el diagnóstico';
    END IF;

    INSERT INTO consulta_medica
        (id_expediente, id_medico, id_cita, fecha_consulta,
         diagnostico, tratamiento, observaciones)
    VALUES
        (v_id_expediente, v_id_medico, p_id_cita, NOW(),
         p_diagnostico, p_tratamiento, p_observaciones);

    SELECT LAST_INSERT_ID() AS id_consulta_creada;
END $$

DROP PROCEDURE IF EXISTS sp_actualizar_consulta $$
CREATE PROCEDURE sp_actualizar_consulta(
    IN p_id_usuario_medico INT,
    IN p_id_consulta INT,
    IN p_diagnostico TEXT,
    IN p_tratamiento TEXT,
    IN p_observaciones TEXT
)
BEGIN
    DECLARE v_id_medico INT DEFAULT NULL;
    DECLARE v_medico_consulta INT DEFAULT NULL;

    SELECT m.id_medico
      INTO v_id_medico
      FROM medico m
      JOIN usuario u ON u.id_usuario = m.id_usuario
      JOIN rol r ON r.id_rol = u.id_rol
     WHERE u.id_usuario = p_id_usuario_medico
       AND u.estado = TRUE
       AND m.estado = TRUE
       AND r.nombre_rol = 'Médico'
     LIMIT 1;

    IF v_id_medico IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no corresponde a un médico autorizado';
    END IF;

    SELECT id_medico
      INTO v_medico_consulta
      FROM consulta_medica
     WHERE id_consulta = p_id_consulta;

    IF v_medico_consulta IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La consulta no existe';
    END IF;

    IF v_medico_consulta <> v_id_medico THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo el médico responsable puede modificar el diagnóstico';
    END IF;

    UPDATE consulta_medica
       SET diagnostico = p_diagnostico,
           tratamiento = p_tratamiento,
           observaciones = p_observaciones
     WHERE id_consulta = p_id_consulta;
END $$

DROP PROCEDURE IF EXISTS sp_crear_usuario $$
CREATE PROCEDURE sp_crear_usuario(
    IN p_id_admin INT,
    IN p_id_clinica INT,
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_correo VARCHAR(150),
    IN p_password_hash VARCHAR(255),
    IN p_nombre_rol VARCHAR(50)
)
BEGIN
    DECLARE v_rol_admin VARCHAR(50) DEFAULT NULL;
    DECLARE v_clinica_admin INT DEFAULT NULL;
    DECLARE v_id_rol INT DEFAULT NULL;

    SELECT r.nombre_rol, u.id_clinica
      INTO v_rol_admin, v_clinica_admin
      FROM usuario u
      JOIN rol r ON r.id_rol = u.id_rol
     WHERE u.id_usuario = p_id_admin
       AND u.estado = TRUE;

    IF v_rol_admin IS NULL OR v_rol_admin <> 'Administrador' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo un administrador activo puede crear usuarios';
    END IF;

    IF v_clinica_admin <> p_id_clinica THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El administrador solo puede crear usuarios de su clínica';
    END IF;

    SELECT id_rol
      INTO v_id_rol
      FROM rol
     WHERE nombre_rol = p_nombre_rol;

    IF v_id_rol IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rol no válido';
    END IF;

    INSERT INTO usuario
        (id_clinica, nombre, apellido, correo, password_hash, estado, id_rol)
    VALUES
        (p_id_clinica, p_nombre, p_apellido, p_correo, p_password_hash, TRUE, v_id_rol);

    SELECT LAST_INSERT_ID() AS id_usuario_creado;
END $$

DROP PROCEDURE IF EXISTS sp_desactivar_usuario $$
CREATE PROCEDURE sp_desactivar_usuario(
    IN p_id_admin INT,
    IN p_id_usuario_objetivo INT
)
BEGIN
    DECLARE v_rol_admin VARCHAR(50) DEFAULT NULL;
    DECLARE v_clinica_admin INT DEFAULT NULL;
    DECLARE v_clinica_objetivo INT DEFAULT NULL;

    SELECT r.nombre_rol, u.id_clinica
      INTO v_rol_admin, v_clinica_admin
      FROM usuario u
      JOIN rol r ON r.id_rol = u.id_rol
     WHERE u.id_usuario = p_id_admin
       AND u.estado = TRUE;

    SELECT id_clinica
      INTO v_clinica_objetivo
      FROM usuario
     WHERE id_usuario = p_id_usuario_objetivo;

    IF v_rol_admin IS NULL OR v_rol_admin <> 'Administrador' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo un administrador activo puede desactivar usuarios';
    END IF;

    IF v_clinica_objetivo IS NULL OR v_clinica_admin <> v_clinica_objetivo THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario objetivo no pertenece a la clínica del administrador';
    END IF;

    UPDATE usuario
       SET estado = FALSE
     WHERE id_usuario = p_id_usuario_objetivo;
END $$

DROP PROCEDURE IF EXISTS sp_registrar_pago $$
CREATE PROCEDURE sp_registrar_pago(
    IN p_id_cita INT,
    IN p_monto DECIMAL(10,2),
    IN p_metodo_pago VARCHAR(50),
    IN p_estado_pago VARCHAR(20)
)
BEGIN
    DECLARE v_id_paciente INT DEFAULT NULL;

    SELECT id_paciente
      INTO v_id_paciente
      FROM cita
     WHERE id_cita = p_id_cita;

    IF v_id_paciente IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cita no existe';
    END IF;

    INSERT INTO pago
        (id_paciente, id_cita, monto, fecha_pago, metodo_pago, estado_pago)
    VALUES
        (v_id_paciente, p_id_cita, p_monto, NOW(), p_metodo_pago, p_estado_pago);

    SELECT LAST_INSERT_ID() AS id_pago_creado;
END $$

DROP PROCEDURE IF EXISTS sp_registrar_acceso $$
CREATE PROCEDURE sp_registrar_acceso(
    IN p_id_usuario INT,
    IN p_correo_intentado VARCHAR(150),
    IN p_ip_origen VARCHAR(45),
    IN p_exitoso BOOLEAN,
    IN p_detalle VARCHAR(255)
)
BEGIN
    INSERT INTO bitacora_acceso
        (id_usuario, correo_intentado, fecha_acceso, ip_origen, exitoso, detalle)
    VALUES
        (p_id_usuario, p_correo_intentado, NOW(), p_ip_origen, p_exitoso, p_detalle);
END $$

DELIMITER ;

-- ============================================================
-- 10. VISTAS
-- ============================================================

CREATE OR REPLACE VIEW vw_usuarios_roles AS
SELECT
    u.id_usuario,
    u.id_clinica,
    c.nombre AS clinica,
    u.nombre,
    u.apellido,
    u.correo,
    u.estado,
    u.fecha_creacion,
    r.nombre_rol
FROM usuario u
JOIN rol r ON r.id_rol = u.id_rol
JOIN clinica c ON c.id_clinica = u.id_clinica;

CREATE OR REPLACE VIEW vw_agenda_medica AS
SELECT
    ci.id_cita,
    m.id_medico,
    CONCAT(m.nombres, ' ', m.apellidos) AS medico,
    m.especialidad,
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellidos) AS paciente,
    ci.fecha_cita,
    ci.hora_inicio,
    ci.hora_fin,
    ci.estado_cita,
    ci.motivo_consulta,
    p.id_clinica
FROM cita ci
JOIN medico m ON m.id_medico = ci.id_medico
JOIN paciente p ON p.id_paciente = ci.id_paciente;

CREATE OR REPLACE VIEW vw_historial_clinico AS
SELECT
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellidos) AS paciente,
    ec.id_expediente,
    cm.id_consulta,
    cm.fecha_consulta,
    CONCAT(m.nombres, ' ', m.apellidos) AS medico,
    m.especialidad,
    cm.diagnostico,
    cm.tratamiento,
    cm.observaciones,
    cm.id_cita,
    p.id_clinica
FROM paciente p
JOIN expediente_clinico ec ON ec.id_paciente = p.id_paciente
LEFT JOIN consulta_medica cm ON cm.id_expediente = ec.id_expediente
LEFT JOIN medico m ON m.id_medico = cm.id_medico;

CREATE OR REPLACE VIEW vw_estado_pagos AS
SELECT
    ci.id_cita,
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellidos) AS paciente,
    ci.fecha_cita,
    COUNT(pg.id_pago) AS cantidad_pagos,
    COALESCE(SUM(CASE WHEN pg.estado_pago = 'Pagado' THEN pg.monto ELSE 0 END), 0) AS total_pagado,
    p.id_clinica
FROM cita ci
JOIN paciente p ON p.id_paciente = ci.id_paciente
LEFT JOIN pago pg ON pg.id_cita = ci.id_cita
GROUP BY
    ci.id_cita, p.id_paciente, p.nombres, p.apellidos, ci.fecha_cita, p.id_clinica;

CREATE OR REPLACE VIEW vw_indicadores_citas_medico AS
SELECT
    m.id_medico,
    m.id_clinica,
    CONCAT(m.nombres, ' ', m.apellidos) AS medico,
    m.especialidad,
    COUNT(ci.id_cita) AS total_citas,
    SUM(CASE WHEN ci.estado_cita = 'Programada' THEN 1 ELSE 0 END) AS programadas,
    SUM(CASE WHEN ci.estado_cita = 'Atendida' THEN 1 ELSE 0 END) AS atendidas,
    SUM(CASE WHEN ci.estado_cita = 'Cancelada' THEN 1 ELSE 0 END) AS canceladas
FROM medico m
LEFT JOIN cita ci ON ci.id_medico = m.id_medico
GROUP BY
    m.id_medico, m.id_clinica, m.nombres, m.apellidos, m.especialidad;

CREATE OR REPLACE VIEW vw_plan_clinica AS
SELECT
    c.id_clinica,
    c.nombre AS clinica,
    ps.nombre_plan,
    ps.limite_pacientes,
    ps.limite_citas,
    ps.permite_pdf,
    ps.permite_whatsapp,
    SUM(CASE WHEN p.estado = TRUE THEN 1 ELSE 0 END) AS pacientes_activos
FROM clinica c
JOIN plan_suscripcion ps ON ps.id_plan = c.id_plan
LEFT JOIN paciente p ON p.id_clinica = c.id_clinica
GROUP BY
    c.id_clinica, c.nombre, ps.nombre_plan, ps.limite_pacientes,
    ps.limite_citas, ps.permite_pdf, ps.permite_whatsapp;

-- ============================================================
-- 11. CONSULTAS DE VERIFICACIÓN
-- ============================================================

-- Ver tablas:
-- SHOW TABLES;

-- Ver funciones:
-- SHOW FUNCTION STATUS WHERE Db = 'clinica_digital';

-- Ver procedimientos:
-- SHOW PROCEDURE STATUS WHERE Db = 'clinica_digital';

-- Ver triggers:
-- SHOW TRIGGERS FROM clinica_digital;

-- Ver vistas:
-- SHOW FULL TABLES IN clinica_digital WHERE Table_type = 'VIEW';

-- Validar disponibilidad de un médico:
-- SELECT fn_medico_disponible(1, '2026-09-15', '09:00:00', '10:00:00');

-- Consultar agenda:
-- SELECT * FROM vw_agenda_medica ORDER BY fecha_cita, hora_inicio;

-- Consultar historial:
-- SELECT * FROM vw_historial_clinico WHERE id_paciente = 1;

-- ============================================================
-- 12. SEGURIDAD (RECOMENDACIONES DE IMPLEMENTACIÓN)
-- ============================================================
-- 1) El backend debe conectarse con un usuario MySQL de privilegios mínimos.
-- 2) Las contraseñas se deben hashear en el backend usando bcrypt/Argon2.
-- 3) No exponer password_hash mediante vistas o endpoints.
-- 4) Aplicar HTTPS/TLS entre cliente y API.
-- 5) Programar backups cada 24 horas y conservar al menos 7 días.
-- 6) Usar procedimientos para operaciones sensibles y RBAC en el backend.
-- ============================================================
