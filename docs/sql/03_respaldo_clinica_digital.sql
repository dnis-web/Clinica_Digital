CREATE DATABASE  IF NOT EXISTS `clinica_digital` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `clinica_digital`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: clinica_digital
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bitacora_acceso`
--

DROP TABLE IF EXISTS `bitacora_acceso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bitacora_acceso` (
  `id_acceso` bigint NOT NULL AUTO_INCREMENT,
  `id_usuario` int DEFAULT NULL,
  `correo_intentado` varchar(150) DEFAULT NULL,
  `fecha_acceso` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_origen` varchar(45) DEFAULT NULL,
  `exitoso` tinyint(1) NOT NULL,
  `detalle` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_acceso`),
  KEY `idx_bitacora_fecha` (`fecha_acceso`),
  KEY `idx_bitacora_usuario` (`id_usuario`,`fecha_acceso`),
  CONSTRAINT `fk_bitacora_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bitacora_acceso`
--

LOCK TABLES `bitacora_acceso` WRITE;
/*!40000 ALTER TABLE `bitacora_acceso` DISABLE KEYS */;
INSERT INTO `bitacora_acceso` VALUES (1,1,'admin@clinicademo.gt','2026-09-11 19:34:50','127.0.0.1',1,'Inicio de sesión de prueba');
/*!40000 ALTER TABLE `bitacora_acceso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cita`
--

DROP TABLE IF EXISTS `cita`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cita` (
  `id_cita` int NOT NULL AUTO_INCREMENT,
  `id_paciente` int NOT NULL,
  `id_medico` int NOT NULL,
  `fecha_cita` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `estado_cita` varchar(20) NOT NULL DEFAULT 'Programada',
  `motivo_consulta` varchar(250) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cita`),
  KEY `idx_cita_medico_fecha` (`id_medico`,`fecha_cita`,`hora_inicio`,`hora_fin`),
  KEY `idx_cita_paciente_fecha` (`id_paciente`,`fecha_cita`),
  KEY `idx_cita_estado_fecha` (`estado_cita`,`fecha_cita`),
  CONSTRAINT `fk_cita_medico` FOREIGN KEY (`id_medico`) REFERENCES `medico` (`id_medico`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cita_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_cita_estado` CHECK ((`estado_cita` in (_utf8mb4'Programada',_utf8mb4'Cancelada',_utf8mb4'Atendida'))),
  CONSTRAINT `chk_cita_horas` CHECK ((`hora_fin` > `hora_inicio`))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cita`
--

LOCK TABLES `cita` WRITE;
/*!40000 ALTER TABLE `cita` DISABLE KEYS */;
INSERT INTO `cita` VALUES (1,1,1,'2026-09-13','09:00:00','09:30:00','Atendida','Consulta general','2026-09-11 19:34:50');
/*!40000 ALTER TABLE `cita` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_cita_validar_bi` BEFORE INSERT ON `cita` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_cita_notificacion_ai` AFTER INSERT ON `cita` FOR EACH ROW BEGIN
    IF NEW.estado_cita = 'Programada' THEN
        INSERT INTO notificacion
            (id_paciente, id_cita, tipo_notificacion, fecha_envio, estado)
        VALUES
            (NEW.id_paciente, NEW.id_cita, 'Correo', NULL, 'Pendiente');
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_cita_validar_bu` BEFORE UPDATE ON `cita` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `clinica`
--

DROP TABLE IF EXISTS `clinica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clinica` (
  `id_clinica` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `direccion` varchar(250) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(150) DEFAULT NULL,
  `id_plan` int NOT NULL,
  PRIMARY KEY (`id_clinica`),
  KEY `fk_clinica_plan` (`id_plan`),
  CONSTRAINT `fk_clinica_plan` FOREIGN KEY (`id_plan`) REFERENCES `plan_suscripcion` (`id_plan`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clinica`
--

LOCK TABLES `clinica` WRITE;
/*!40000 ALTER TABLE `clinica` DISABLE KEYS */;
INSERT INTO `clinica` VALUES (1,'Clínica Demo Guatemala','Ciudad de Guatemala','2222-2222','contacto@clinicademo.gt',1);
/*!40000 ALTER TABLE `clinica` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consulta_medica`
--

DROP TABLE IF EXISTS `consulta_medica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `consulta_medica` (
  `id_consulta` int NOT NULL AUTO_INCREMENT,
  `id_expediente` int NOT NULL,
  `id_medico` int NOT NULL,
  `id_cita` int NOT NULL,
  `fecha_consulta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `diagnostico` text NOT NULL,
  `tratamiento` text,
  `observaciones` text,
  PRIMARY KEY (`id_consulta`),
  UNIQUE KEY `uq_consulta_cita` (`id_cita`),
  KEY `idx_consulta_expediente_fecha` (`id_expediente`,`fecha_consulta`),
  KEY `idx_consulta_medico_fecha` (`id_medico`,`fecha_consulta`),
  CONSTRAINT `fk_consulta_cita` FOREIGN KEY (`id_cita`) REFERENCES `cita` (`id_cita`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_consulta_expediente` FOREIGN KEY (`id_expediente`) REFERENCES `expediente_clinico` (`id_expediente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_consulta_medico` FOREIGN KEY (`id_medico`) REFERENCES `medico` (`id_medico`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consulta_medica`
--

LOCK TABLES `consulta_medica` WRITE;
/*!40000 ALTER TABLE `consulta_medica` DISABLE KEYS */;
INSERT INTO `consulta_medica` VALUES (1,1,1,1,'2026-09-11 19:34:50','Diagnóstico de prueba','Tratamiento de prueba','Paciente estable');
/*!40000 ALTER TABLE `consulta_medica` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_consulta_marcar_atendida_ai` AFTER INSERT ON `consulta_medica` FOR EACH ROW BEGIN
    UPDATE cita
       SET estado_cita = 'Atendida'
     WHERE id_cita = NEW.id_cita
       AND estado_cita <> 'Cancelada';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `expediente_clinico`
--

DROP TABLE IF EXISTS `expediente_clinico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expediente_clinico` (
  `id_expediente` int NOT NULL AUTO_INCREMENT,
  `id_paciente` int NOT NULL,
  `fecha_apertura` date NOT NULL DEFAULT (curdate()),
  `observaciones_generales` text,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_expediente`),
  UNIQUE KEY `uq_expediente_paciente` (`id_paciente`),
  CONSTRAINT `fk_expediente_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expediente_clinico`
--

LOCK TABLES `expediente_clinico` WRITE;
/*!40000 ALTER TABLE `expediente_clinico` DISABLE KEYS */;
INSERT INTO `expediente_clinico` VALUES (1,1,'2026-09-11',NULL,1);
/*!40000 ALTER TABLE `expediente_clinico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medico`
--

DROP TABLE IF EXISTS `medico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medico` (
  `id_medico` int NOT NULL AUTO_INCREMENT,
  `id_clinica` int NOT NULL,
  `id_usuario` int DEFAULT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `colegiado` varchar(50) NOT NULL,
  `especialidad` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(150) DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_medico`),
  UNIQUE KEY `uq_medico_clinica_colegiado` (`id_clinica`,`colegiado`),
  UNIQUE KEY `uq_medico_usuario` (`id_usuario`),
  KEY `idx_medico_especialidad` (`especialidad`),
  KEY `idx_medico_clinica_estado` (`id_clinica`,`estado`),
  CONSTRAINT `fk_medico_clinica` FOREIGN KEY (`id_clinica`) REFERENCES `clinica` (`id_clinica`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_medico_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medico`
--

LOCK TABLES `medico` WRITE;
/*!40000 ALTER TABLE `medico` DISABLE KEYS */;
INSERT INTO `medico` VALUES (1,1,2,'Ana','López','COL-1001','Medicina General','5555-1001','ana.lopez@clinicademo.gt',1);
/*!40000 ALTER TABLE `medico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificacion`
--

DROP TABLE IF EXISTS `notificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notificacion` (
  `id_notificacion` int NOT NULL AUTO_INCREMENT,
  `id_paciente` int NOT NULL,
  `id_cita` int NOT NULL,
  `tipo_notificacion` varchar(30) NOT NULL,
  `fecha_envio` datetime DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'Pendiente',
  PRIMARY KEY (`id_notificacion`),
  KEY `fk_notificacion_paciente` (`id_paciente`),
  KEY `idx_notificacion_estado` (`estado`,`fecha_envio`),
  KEY `idx_notificacion_cita` (`id_cita`),
  CONSTRAINT `fk_notificacion_cita` FOREIGN KEY (`id_cita`) REFERENCES `cita` (`id_cita`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_notificacion_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_notificacion_estado` CHECK ((`estado` in (_utf8mb4'Pendiente',_utf8mb4'Enviada',_utf8mb4'Error'))),
  CONSTRAINT `chk_notificacion_tipo` CHECK ((`tipo_notificacion` in (_utf8mb4'Correo',_utf8mb4'WhatsApp',_utf8mb4'SMS')))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificacion`
--

LOCK TABLES `notificacion` WRITE;
/*!40000 ALTER TABLE `notificacion` DISABLE KEYS */;
INSERT INTO `notificacion` VALUES (1,1,1,'Correo',NULL,'Pendiente');
/*!40000 ALTER TABLE `notificacion` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_notificacion_plan_bi` BEFORE INSERT ON `notificacion` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `paciente`
--

DROP TABLE IF EXISTS `paciente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paciente` (
  `id_paciente` int NOT NULL AUTO_INCREMENT,
  `id_clinica` int NOT NULL,
  `id_usuario` int DEFAULT NULL,
  `dpi` varchar(20) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(150) DEFAULT NULL,
  `direccion` varchar(250) DEFAULT NULL,
  `sexo` char(1) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_paciente`),
  UNIQUE KEY `uq_paciente_clinica_dpi` (`id_clinica`,`dpi`),
  UNIQUE KEY `uq_paciente_usuario` (`id_usuario`),
  KEY `idx_paciente_nombre` (`apellidos`,`nombres`),
  KEY `idx_paciente_correo` (`correo`),
  KEY `idx_paciente_clinica_estado` (`id_clinica`,`estado`),
  CONSTRAINT `fk_paciente_clinica` FOREIGN KEY (`id_clinica`) REFERENCES `clinica` (`id_clinica`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_paciente_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_paciente_sexo` CHECK ((`sexo` in (_utf8mb4'M',_utf8mb4'F')))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paciente`
--

LOCK TABLES `paciente` WRITE;
/*!40000 ALTER TABLE `paciente` DISABLE KEYS */;
INSERT INTO `paciente` VALUES (1,1,NULL,'1234567890101','Carlos','Pérez','1995-05-20','5555-2001','carlos.perez@example.com','Ciudad de Guatemala','M',1);
/*!40000 ALTER TABLE `paciente` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_paciente_limite_plan_bi` BEFORE INSERT ON `paciente` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_paciente_crear_expediente_ai` AFTER INSERT ON `paciente` FOR EACH ROW BEGIN
    INSERT INTO expediente_clinico
        (id_paciente, fecha_apertura, observaciones_generales, estado)
    VALUES
        (NEW.id_paciente, CURDATE(), NULL, TRUE);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_paciente_limite_plan_bu` BEFORE UPDATE ON `paciente` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pago`
--

DROP TABLE IF EXISTS `pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pago` (
  `id_pago` int NOT NULL AUTO_INCREMENT,
  `id_paciente` int NOT NULL,
  `id_cita` int NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha_pago` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `metodo_pago` varchar(50) NOT NULL,
  `estado_pago` varchar(20) NOT NULL DEFAULT 'Pagado',
  PRIMARY KEY (`id_pago`),
  KEY `idx_pago_paciente_fecha` (`id_paciente`,`fecha_pago`),
  KEY `idx_pago_cita` (`id_cita`),
  CONSTRAINT `fk_pago_cita` FOREIGN KEY (`id_cita`) REFERENCES `cita` (`id_cita`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pago_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_pago_estado` CHECK ((`estado_pago` in (_utf8mb4'Pendiente',_utf8mb4'Pagado'))),
  CONSTRAINT `chk_pago_metodo` CHECK ((`metodo_pago` in (_utf8mb4'Efectivo',_utf8mb4'Tarjeta',_utf8mb4'Transferencia'))),
  CONSTRAINT `chk_pago_monto` CHECK ((`monto` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pago`
--

LOCK TABLES `pago` WRITE;
/*!40000 ALTER TABLE `pago` DISABLE KEYS */;
INSERT INTO `pago` VALUES (1,1,1,250.00,'2026-09-11 19:34:50','Efectivo','Pagado');
/*!40000 ALTER TABLE `pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_suscripcion`
--

DROP TABLE IF EXISTS `plan_suscripcion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plan_suscripcion` (
  `id_plan` int NOT NULL AUTO_INCREMENT,
  `nombre_plan` varchar(50) NOT NULL,
  `limite_pacientes` int DEFAULT NULL,
  `limite_citas` int DEFAULT NULL,
  `permite_pdf` tinyint(1) NOT NULL DEFAULT '0',
  `permite_whatsapp` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_plan`),
  UNIQUE KEY `uq_plan_nombre` (`nombre_plan`),
  CONSTRAINT `chk_plan_limite_citas` CHECK (((`limite_citas` is null) or (`limite_citas` > 0))),
  CONSTRAINT `chk_plan_limite_pacientes` CHECK (((`limite_pacientes` is null) or (`limite_pacientes` > 0)))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_suscripcion`
--

LOCK TABLES `plan_suscripcion` WRITE;
/*!40000 ALTER TABLE `plan_suscripcion` DISABLE KEYS */;
INSERT INTO `plan_suscripcion` VALUES (1,'Gratuito',10,20,0,0),(2,'Premium',NULL,NULL,1,1);
/*!40000 ALTER TABLE `plan_suscripcion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `receta`
--

DROP TABLE IF EXISTS `receta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `receta` (
  `id_receta` int NOT NULL AUTO_INCREMENT,
  `id_consulta` int NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `indicaciones` text NOT NULL,
  `archivo_pdf` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_receta`),
  KEY `idx_receta_consulta` (`id_consulta`),
  CONSTRAINT `fk_receta_consulta` FOREIGN KEY (`id_consulta`) REFERENCES `consulta_medica` (`id_consulta`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receta`
--

LOCK TABLES `receta` WRITE;
/*!40000 ALTER TABLE `receta` DISABLE KEYS */;
/*!40000 ALTER TABLE `receta` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_receta_plan_bi` BEFORE INSERT ON `receta` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol` (
  `id_rol` int NOT NULL AUTO_INCREMENT,
  `nombre_rol` varchar(50) NOT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `uq_rol_nombre` (`nombre_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (1,'Administrador'),(3,'Médico'),(4,'Paciente'),(2,'Recepción');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `id_clinica` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `correo` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_rol` int NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_correo` (`correo`),
  KEY `idx_usuario_rol` (`id_rol`),
  KEY `idx_usuario_clinica` (`id_clinica`),
  CONSTRAINT `fk_usuario_clinica` FOREIGN KEY (`id_clinica`) REFERENCES `clinica` (`id_clinica`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,1,'Admin','Principal','admin@clinicademo.gt','HASH_DEMO_REEMPLAZAR_POR_BCRYPT',1,'2026-09-11 19:34:50',1),(2,1,'Ana','López','ana.lopez@clinicademo.gt','HASH_DEMO_REEMPLAZAR_POR_BCRYPT',1,'2026-09-11 19:34:50',3);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_agenda_medica`
--

DROP TABLE IF EXISTS `vw_agenda_medica`;
/*!50001 DROP VIEW IF EXISTS `vw_agenda_medica`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_agenda_medica` AS SELECT 
 1 AS `id_cita`,
 1 AS `id_medico`,
 1 AS `medico`,
 1 AS `especialidad`,
 1 AS `id_paciente`,
 1 AS `paciente`,
 1 AS `fecha_cita`,
 1 AS `hora_inicio`,
 1 AS `hora_fin`,
 1 AS `estado_cita`,
 1 AS `motivo_consulta`,
 1 AS `id_clinica`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_estado_pagos`
--

DROP TABLE IF EXISTS `vw_estado_pagos`;
/*!50001 DROP VIEW IF EXISTS `vw_estado_pagos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_estado_pagos` AS SELECT 
 1 AS `id_cita`,
 1 AS `id_paciente`,
 1 AS `paciente`,
 1 AS `fecha_cita`,
 1 AS `cantidad_pagos`,
 1 AS `total_pagado`,
 1 AS `id_clinica`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_historial_clinico`
--

DROP TABLE IF EXISTS `vw_historial_clinico`;
/*!50001 DROP VIEW IF EXISTS `vw_historial_clinico`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_historial_clinico` AS SELECT 
 1 AS `id_paciente`,
 1 AS `paciente`,
 1 AS `id_expediente`,
 1 AS `id_consulta`,
 1 AS `fecha_consulta`,
 1 AS `medico`,
 1 AS `especialidad`,
 1 AS `diagnostico`,
 1 AS `tratamiento`,
 1 AS `observaciones`,
 1 AS `id_cita`,
 1 AS `id_clinica`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_indicadores_citas_medico`
--

DROP TABLE IF EXISTS `vw_indicadores_citas_medico`;
/*!50001 DROP VIEW IF EXISTS `vw_indicadores_citas_medico`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_indicadores_citas_medico` AS SELECT 
 1 AS `id_medico`,
 1 AS `id_clinica`,
 1 AS `medico`,
 1 AS `especialidad`,
 1 AS `total_citas`,
 1 AS `programadas`,
 1 AS `atendidas`,
 1 AS `canceladas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_plan_clinica`
--

DROP TABLE IF EXISTS `vw_plan_clinica`;
/*!50001 DROP VIEW IF EXISTS `vw_plan_clinica`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_plan_clinica` AS SELECT 
 1 AS `id_clinica`,
 1 AS `clinica`,
 1 AS `nombre_plan`,
 1 AS `limite_pacientes`,
 1 AS `limite_citas`,
 1 AS `permite_pdf`,
 1 AS `permite_whatsapp`,
 1 AS `pacientes_activos`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_usuarios_roles`
--

DROP TABLE IF EXISTS `vw_usuarios_roles`;
/*!50001 DROP VIEW IF EXISTS `vw_usuarios_roles`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_usuarios_roles` AS SELECT 
 1 AS `id_usuario`,
 1 AS `id_clinica`,
 1 AS `clinica`,
 1 AS `nombre`,
 1 AS `apellido`,
 1 AS `correo`,
 1 AS `estado`,
 1 AS `fecha_creacion`,
 1 AS `nombre_rol`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'clinica_digital'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_edad_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_edad_paciente`(p_id_paciente INT) RETURNS int
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_medico_disponible` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_medico_disponible`(
    p_id_medico INT,
    p_fecha DATE,
    p_hora_inicio TIME,
    p_hora_fin TIME
) RETURNS tinyint(1)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_total_pagado_cita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_pagado_cita`(p_id_cita INT) RETURNS decimal(10,2)
    READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT COALESCE(SUM(monto), 0)
      INTO v_total
      FROM pago
     WHERE id_cita = p_id_cita
       AND estado_pago = 'Pagado';

    RETURN v_total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_actualizar_consulta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_consulta`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_agendar_cita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_agendar_cita`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cancelar_cita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cancelar_cita`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crear_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_usuario`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_desactivar_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_desactivar_usuario`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrar_acceso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_acceso`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrar_consulta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_consulta`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrar_pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_pago`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reprogramar_cita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reprogramar_cita`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_agenda_medica`
--

/*!50001 DROP VIEW IF EXISTS `vw_agenda_medica`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_agenda_medica` AS select `ci`.`id_cita` AS `id_cita`,`m`.`id_medico` AS `id_medico`,concat(`m`.`nombres`,' ',`m`.`apellidos`) AS `medico`,`m`.`especialidad` AS `especialidad`,`p`.`id_paciente` AS `id_paciente`,concat(`p`.`nombres`,' ',`p`.`apellidos`) AS `paciente`,`ci`.`fecha_cita` AS `fecha_cita`,`ci`.`hora_inicio` AS `hora_inicio`,`ci`.`hora_fin` AS `hora_fin`,`ci`.`estado_cita` AS `estado_cita`,`ci`.`motivo_consulta` AS `motivo_consulta`,`p`.`id_clinica` AS `id_clinica` from ((`cita` `ci` join `medico` `m` on((`m`.`id_medico` = `ci`.`id_medico`))) join `paciente` `p` on((`p`.`id_paciente` = `ci`.`id_paciente`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_estado_pagos`
--

/*!50001 DROP VIEW IF EXISTS `vw_estado_pagos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_estado_pagos` AS select `ci`.`id_cita` AS `id_cita`,`p`.`id_paciente` AS `id_paciente`,concat(`p`.`nombres`,' ',`p`.`apellidos`) AS `paciente`,`ci`.`fecha_cita` AS `fecha_cita`,count(`pg`.`id_pago`) AS `cantidad_pagos`,coalesce(sum((case when (`pg`.`estado_pago` = 'Pagado') then `pg`.`monto` else 0 end)),0) AS `total_pagado`,`p`.`id_clinica` AS `id_clinica` from ((`cita` `ci` join `paciente` `p` on((`p`.`id_paciente` = `ci`.`id_paciente`))) left join `pago` `pg` on((`pg`.`id_cita` = `ci`.`id_cita`))) group by `ci`.`id_cita`,`p`.`id_paciente`,`p`.`nombres`,`p`.`apellidos`,`ci`.`fecha_cita`,`p`.`id_clinica` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_historial_clinico`
--

/*!50001 DROP VIEW IF EXISTS `vw_historial_clinico`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_historial_clinico` AS select `p`.`id_paciente` AS `id_paciente`,concat(`p`.`nombres`,' ',`p`.`apellidos`) AS `paciente`,`ec`.`id_expediente` AS `id_expediente`,`cm`.`id_consulta` AS `id_consulta`,`cm`.`fecha_consulta` AS `fecha_consulta`,concat(`m`.`nombres`,' ',`m`.`apellidos`) AS `medico`,`m`.`especialidad` AS `especialidad`,`cm`.`diagnostico` AS `diagnostico`,`cm`.`tratamiento` AS `tratamiento`,`cm`.`observaciones` AS `observaciones`,`cm`.`id_cita` AS `id_cita`,`p`.`id_clinica` AS `id_clinica` from (((`paciente` `p` join `expediente_clinico` `ec` on((`ec`.`id_paciente` = `p`.`id_paciente`))) left join `consulta_medica` `cm` on((`cm`.`id_expediente` = `ec`.`id_expediente`))) left join `medico` `m` on((`m`.`id_medico` = `cm`.`id_medico`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_indicadores_citas_medico`
--

/*!50001 DROP VIEW IF EXISTS `vw_indicadores_citas_medico`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_indicadores_citas_medico` AS select `m`.`id_medico` AS `id_medico`,`m`.`id_clinica` AS `id_clinica`,concat(`m`.`nombres`,' ',`m`.`apellidos`) AS `medico`,`m`.`especialidad` AS `especialidad`,count(`ci`.`id_cita`) AS `total_citas`,sum((case when (`ci`.`estado_cita` = 'Programada') then 1 else 0 end)) AS `programadas`,sum((case when (`ci`.`estado_cita` = 'Atendida') then 1 else 0 end)) AS `atendidas`,sum((case when (`ci`.`estado_cita` = 'Cancelada') then 1 else 0 end)) AS `canceladas` from (`medico` `m` left join `cita` `ci` on((`ci`.`id_medico` = `m`.`id_medico`))) group by `m`.`id_medico`,`m`.`id_clinica`,`m`.`nombres`,`m`.`apellidos`,`m`.`especialidad` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_plan_clinica`
--

/*!50001 DROP VIEW IF EXISTS `vw_plan_clinica`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_plan_clinica` AS select `c`.`id_clinica` AS `id_clinica`,`c`.`nombre` AS `clinica`,`ps`.`nombre_plan` AS `nombre_plan`,`ps`.`limite_pacientes` AS `limite_pacientes`,`ps`.`limite_citas` AS `limite_citas`,`ps`.`permite_pdf` AS `permite_pdf`,`ps`.`permite_whatsapp` AS `permite_whatsapp`,sum((case when (`p`.`estado` = true) then 1 else 0 end)) AS `pacientes_activos` from ((`clinica` `c` join `plan_suscripcion` `ps` on((`ps`.`id_plan` = `c`.`id_plan`))) left join `paciente` `p` on((`p`.`id_clinica` = `c`.`id_clinica`))) group by `c`.`id_clinica`,`c`.`nombre`,`ps`.`nombre_plan`,`ps`.`limite_pacientes`,`ps`.`limite_citas`,`ps`.`permite_pdf`,`ps`.`permite_whatsapp` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_usuarios_roles`
--

/*!50001 DROP VIEW IF EXISTS `vw_usuarios_roles`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_usuarios_roles` AS select `u`.`id_usuario` AS `id_usuario`,`u`.`id_clinica` AS `id_clinica`,`c`.`nombre` AS `clinica`,`u`.`nombre` AS `nombre`,`u`.`apellido` AS `apellido`,`u`.`correo` AS `correo`,`u`.`estado` AS `estado`,`u`.`fecha_creacion` AS `fecha_creacion`,`r`.`nombre_rol` AS `nombre_rol` from ((`usuario` `u` join `rol` `r` on((`r`.`id_rol` = `u`.`id_rol`))) join `clinica` `c` on((`c`.`id_clinica` = `u`.`id_clinica`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-11 20:11:06
