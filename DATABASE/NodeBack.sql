CREATE DATABASE  IF NOT EXISTS `node_back` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `node_back`;
-- MySQL dump 10.13  Distrib 8.0.22, for Win64 (x86_64)
--
-- Host: localhost    Database: node_back
-- ------------------------------------------------------
-- Server version	8.0.22

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
-- Table structure for table `tb_categoria`
--

DROP TABLE IF EXISTS `tb_categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_categoria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_categoria`
--

LOCK TABLES `tb_categoria` WRITE;
/*!40000 ALTER TABLE `tb_categoria` DISABLE KEYS */;
INSERT INTO `tb_categoria` VALUES (1,'Tecnologico','Articulos de tecnologia'),(2,'Multimedia','Articulos multimedia'),(3,'Hogar','Articulos de Hogar'),(4,'Electronico','Articulos de electronica'),(6,'Electrónica','Productos electrónicos'),(7,'Electrónica2','Productos electrónicos2');
/*!40000 ALTER TABLE `tb_categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_empleado`
--

DROP TABLE IF EXISTS `tb_empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_empleado` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) DEFAULT NULL,
  `apellido` varchar(255) DEFAULT NULL,
  `sueldo` decimal(8,2) DEFAULT NULL,
  `fecha_nacimiento` datetime DEFAULT NULL,
  `telefono` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_empleado`
--

LOCK TABLES `tb_empleado` WRITE;
/*!40000 ALTER TABLE `tb_empleado` DISABLE KEYS */;
INSERT INTO `tb_empleado` VALUES (1,'cristian','orizanoh',1500.00,'2010-02-07 00:00:00',123456789),(2,'Juan','Rosales',3500.00,'2000-05-07 00:00:00',987456132),(8,'Emma','Salazar',5000.00,'2024-06-04 00:00:00',987456514),(9,'Anna','Dorw',456.00,'2024-07-23 00:00:00',789456123),(10,'Taylor','Dorw',411.00,'2024-07-17 00:00:00',987456123),(11,'Juan','Pérez',3500.50,'1985-03-25 00:00:00',123456789),(12,'María','González',4200.75,'1990-07-14 00:00:00',987654321),(13,'Carlos','Ramírez',3800.00,'1978-11-05 00:00:00',112233445),(14,'Ana','Martínez',4500.25,'1982-02-18 00:00:00',223344556),(15,'Luis','Fernández',3200.80,'1995-09-22 00:00:00',334455667),(16,'Laura','López',4000.65,'1988-12-01 00:00:00',445566778),(17,'Juan','Perez',3500.50,'1985-03-23 00:00:00',123456789),(18,'María','González',4200.75,'1990-07-14 00:00:00',987654321),(19,'Carlos','Ramírez',3800.00,'1978-11-05 00:00:00',112233445),(20,'Ana','Martínez',4500.25,'1982-02-18 00:00:00',223344556),(21,'Luis','Fernández',3200.80,'1995-09-22 00:00:00',334455667),(22,'Laura','López',4000.65,'1988-12-01 00:00:00',445566778),(23,'Pedro','Gómez',3700.40,'1987-06-13 00:00:00',556677889),(24,'Lucía','Díaz',3900.95,'1992-08-25 00:00:00',667788990),(25,'Javier','Torres',3600.30,'1984-04-16 00:00:00',778899001),(26,'Elena','Ruiz',4100.55,'1989-10-20 00:00:00',889900112),(27,'Miguel','Sánchez',3400.70,'1976-12-15 00:00:00',990011223),(28,'Sara','Morales',4300.85,'1993-05-22 00:00:00',110022334);
/*!40000 ALTER TABLE `tb_empleado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_producto`
--

DROP TABLE IF EXISTS `tb_producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_producto` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `stock` int DEFAULT NULL,
  `precio` decimal(8,2) DEFAULT NULL,
  `id_categoria` int DEFAULT NULL,
  `estado` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_IDCATEGORIA_idx` (`id_categoria`),
  CONSTRAINT `FK_IDCATEGORIA` FOREIGN KEY (`id_categoria`) REFERENCES `tb_categoria` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_producto`
--

LOCK TABLES `tb_producto` WRITE;
/*!40000 ALTER TABLE `tb_producto` DISABLE KEYS */;
INSERT INTO `tb_producto` VALUES (1,'Iphad','Ultima generacion RXJ',100,1500.99,2,_binary ''),(3,'Mac Book','Ultima generacion RXJ',100,1500.99,2,_binary ''),(4,'Camara sony','Ultima generacion RXJ',100,1500.99,2,_binary ''),(7,'Smartphone','Teléfono inteligente',100,599.99,6,_binary ''),(8,'Laptop','Computadora portátil',50,1299.99,6,_binary ''),(9,'Smartphone2024','Teléfono inteligente',100,599.99,7,_binary ''),(10,'Laptop2024','Computadora portátil',50,1299.99,7,_binary '');
/*!40000 ALTER TABLE `tb_producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_role`
--

DROP TABLE IF EXISTS `tb_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_role`
--

LOCK TABLES `tb_role` WRITE;
/*!40000 ALTER TABLE `tb_role` DISABLE KEYS */;
INSERT INTO `tb_role` VALUES (1,'ADMIN'),(2,'USER');
/*!40000 ALTER TABLE `tb_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_usuario`
--

DROP TABLE IF EXISTS `tb_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_usuario` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) DEFAULT NULL,
  `apellido` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `idRole` int DEFAULT NULL,
  `estado` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  KEY `FK_IDROLE_idx` (`idRole`),
  CONSTRAINT `FK_IDROLE` FOREIGN KEY (`idRole`) REFERENCES `tb_role` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_usuario`
--

LOCK TABLES `tb_usuario` WRITE;
/*!40000 ALTER TABLE `tb_usuario` DISABLE KEYS */;
INSERT INTO `tb_usuario` VALUES (1,'cristia','orizano','cristian@gmail.com','$2b$10$UBXToAmtg3jLHPJYd.XrXu0LXvz/wxcbgVsHY/z3MGtWKVbWiaJSm',1,_binary ''),(2,'nini','salazar','nini@gmail.com','$2b$10$W2q6o3QvNCBOAaeqQuElDO9UVd.ntysC3LMxTLv2vincZQQZLXE7e',2,_binary ''),(5,'lucas','cardenas','lucas@gmail.com','$2b$10$37KsyzRHNo9HQD53EYspwemndlOufHsXpcSJ3v9D3AULzZDYZXea2',1,_binary ''),(6,'Asaf','Olmos','Asaf@gmail.com','$2b$10$Vrg1e5.WaoOhTQbXEfYiuOxKByK8MjHQ9.wPUAA/.2bT.svsIo9Le',1,_binary ''),(7,'carlos','lopez','carlos@gmail.com','$2b$10$OzDWG3Xa3NrSMZgB.H8uRO0.3ahAAPvmyIZ3otG0pxrCstqXPAQ6i',1,_binary ''),(8,'luis','perez','luis@gmail.com','$2b$10$evw.iYdO6kWZBWlJXSLPU.aYa0b9coUMYptnz7h8XfRqQJicNjI2C',1,_binary ''),(18,'cristian','orizano','ninicc@gmail.com','$2b$10$qCXNcSWc9h2oSgJmgRhEauh9r32WCqPcKxoouPipQS0G.ETQ8ylH.',1,_binary '');
/*!40000 ALTER TABLE `tb_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'node_back'
--

--
-- Dumping routines for database 'node_back'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-08-08 17:35:11
