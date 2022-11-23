/**************************************************************************************************
* David José de Jesús López Chan	       													      *
* Sistema: Nómina																	    		  *
* Objetivo: Entregable 2, Script de todo lo que se insertó en la base.		                      *																			  
* ------------------------------------------------------------------------------------------------*
*																						          *
* Versión   Fecha        Usuario            Descripción									          *
* -------   ----------   ------------------ ------------------------------------------- ----------*
*  1.0      14/11/2022   David López	    Creación de Vistas para las tablas de empleados y     *
*  											personas.
											  *
**************************************************************************************************/
use nomina;
CREATE OR REPLACE VIEW  personas AS
SELECT * FROM nompersona;

CREATE OR REPLACE VIEW empleados AS
SELECT nomempleados.nom_id_empleado, nompersona.nom_nombre, nompersona.nom_apellido, nompersona.nom_casado
FROM nomempleados
INNER JOIN nompersona ON nomempleados.nom_id_persona = nompersona.nom_id_persona;

CREATE OR REPLACE VIEW calculo AS
SELECT NOMEMPLEADOS.NOM_SUELDODIARIO * .15 AS PARTICIPACION 
FROM NOMEMPLEADOS;

CREATE OR REPLACE VIEW DEDUCCIONES AS
SELECT sum(NOM_IMPORTEDEDUCCION) FROM NOMPROCESOS where NOM_IDEMPLEADO = 2;

CREATE OR REPLACE VIEW DATOS AS
SELECT * FROM nomprocesos
  INNER JOIN nomempleados
  ON nomprocesos.nom_idempleado = nomempleados.nom_id_empleado;



/**************************************************************************************************
* David José de Jesús López Chan	       													      *
* Sistema: Nómina																	    		  *
* Objetivo: Creación de 2 Funciones 					                      *																			  
* ------------------------------------------------------------------------------------------------*
*																						          *
* Versión   Fecha        Usuario            Descripción									          *
* -------   ----------   ------------------ ------------------------------------------- ----------*
*  1.0      21/11/2022   David López	    Creación de 2 Funciones una normal y una con JOINS	  *
**************************************************************************************************/
/*Primera Función*/
USE `nomina`;
DROP function IF EXISTS `divide`;

DELIMITER $$
USE `nomina`$$
CREATE DEFINER=`root`@`localhost` CREATE FUNCTION `divide` (dividendo INT, divisor INT);
RETURNS INT;
NO SQL;
DETERMINISTIC;
BEGIN;
	DECLARE AUX INT;
    DECLARE contador INT;
    DECLARE resto int;
    set contador = 0;
    set aux = 0;
    while (aux + divisor) <= dividendo do
        set aux = aux + divisor ;
        set contador = contador + 1;
    end while;
    set resto = dividendo - aux ;
return contador;
end;


/*División simple*/
USE nomina;
SELECT divide(20,2) as Divide;




/*Segunda Función*/
USE `nomina`;
DROP function IF EXISTS `TOTALCONISR`;

DELIMITER $$
USE `nomina`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `TOTALCONISR` (lim_inf FLOAT, cuota FLOAT, porcentaje FLOAT, id_empleado INT)
RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE IMPORTE_ISR FLOAT;
    DECLARE ALTERNOS FLOAT;
    DECLARE TOTAL FLOAT;
    DECLARE QUINCENA FLOAT;
    DECLARE LIM_INFT FLOAT;
    DECLARE PORCT FLOAT;
    SET QUINCENA = (SELECT NOM_SUELDODIARIO * 15 FROM NOMEMPLEADOS WHERE NOM_ID_EMPLEADO = id_empleado);
    SET LIM_INFT = QUINCENA - lim_inf;
    SET PORCT = LIM_INFT * porcentaje;
	SET IMPORTE_ISR = PORCT + cuota;
    SET ALTERNOS = (SELECT SUM(NOM_IMPORTEDEDUCCION) - SUM(NOM_IMPORTEINCIDENCIA) AS RESULT FROM NOMPROCESOS WHERE NOM_IDEMPLEADO = id_empleado);
    SET TOTAL = (QUINCENA - IMPORTE_ISR + ALTERNOS) * -1;
RETURN (TOTAL);
END$$

DELIMITER ;

/*Mandando la info a la sentencia*/
USE nomina;
SELECT TOTALCONISR(2699.41,158.55,10.88,2) as NOMINATOTAL;


/**************************************************************************************************
* David José de Jesús López Chan	       													      *
* Sistema: Nómina																	    		  *
* Objetivo: Creación de Triggers					                      *																			  
* ------------------------------------------------------------------------------------------------*
*																						          *
* Versión   Fecha        Usuario            Descripción									          *
* -------   ----------   ------------------ ------------------------------------------- ----------*
*  1.0      21/11/2022   David López	    Se tuvo que modificar algunas tablas para el uso	  *
*											correcto de los Triggers							  *
**************************************************************************************************/


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
-- Table structure for table `log_nomepleados`
--

DROP TABLE IF EXISTS `log_nomepleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_nomepleados` (
  `idlog_nomepleados` int NOT NULL AUTO_INCREMENT,
  `log_nomepleadosuser` varchar(45) NOT NULL,
  `log_nomepleadosfecha` datetime NOT NULL,
  `log_nomepleadoshora` datetime NOT NULL,
  `DESCRIPCIONCAMBIO` varchar(200) NOT NULL,
  PRIMARY KEY (`idlog_nomepleados`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_nomepleados`
--

LOCK TABLES `log_nomepleados` WRITE;
/*!40000 ALTER TABLE `log_nomepleados` DISABLE KEYS */;
INSERT INTO `log_nomepleados` VALUES (1,'root@localhost','2022-11-07 00:00:00','2022-11-07 22:29:04','Empleado con ID: 1 se actualizó con la siguiente información pasa de: 980 a tener: 1500 y su pago pasa de: Transferencia a ser en: Cheque');
/*!40000 ALTER TABLE `log_nomepleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `log_nompersona`
--

DROP TABLE IF EXISTS `log_nompersona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_nompersona` (
  `idlog_nompersona` int NOT NULL AUTO_INCREMENT,
  `log_nompersonauser` varchar(45) NOT NULL,
  `log_nompersonafecha` datetime NOT NULL,
  `log_nompersonahora` datetime NOT NULL,
  `NOM_NOMBRE` varchar(100) NOT NULL,
  `NOM_APELLIDO` varchar(100) NOT NULL,
  `NOM_ID_PERSONA` varchar(45) NOT NULL,
  PRIMARY KEY (`idlog_nompersona`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_nompersona`
--

LOCK TABLES `log_nompersona` WRITE;
/*!40000 ALTER TABLE `log_nompersona` DISABLE KEYS */;
INSERT INTO `log_nompersona` VALUES (1,'root@localhost','2022-11-07 00:00:00','2022-11-07 21:20:25','','',''),(2,'root@localhost','2022-11-07 00:00:00','2022-11-07 21:24:51','','',''),(3,'root@localhost','2022-11-07 00:00:00','2022-11-07 21:34:47','David Jose','Lopez Chan',''),(4,'root@localhost','2022-11-07 00:00:00','2022-11-07 22:41:12','David Jose','Lopez Chan','14');
/*!40000 ALTER TABLE `log_nompersona` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nomempleados`
--

DROP TABLE IF EXISTS `nomempleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nomempleados` (
  `NOM_ID_EMPLEADO` int NOT NULL AUTO_INCREMENT,
  `NOM_ID_PERSONA` int DEFAULT NULL,
  `NOM_ID_PUESTO` int DEFAULT NULL,
  `NOM_ID_UBICACION` int DEFAULT NULL,
  `NOM_FECHAING` datetime DEFAULT NULL,
  `NOM_SUELDODIARIO` float DEFAULT NULL,
  `NOM_ACTIVO` int DEFAULT NULL,
  `NOM_FECHABAJA` datetime DEFAULT NULL,
  `NOM_FORMAPAGO` varchar(30) DEFAULT NULL,
  `NOM_IDDEPARTAMENTO` int DEFAULT NULL,
  `NOM_IDCLASIFICACION` int DEFAULT NULL,
  PRIMARY KEY (`NOM_ID_EMPLEADO`),
  KEY `NOM_ID_PERSONA_idx` (`NOM_ID_PERSONA`),
  KEY `NOM_ID_PUESTO_idx` (`NOM_ID_PUESTO`),
  KEY `NOM_ID_UBICACION_idx` (`NOM_ID_UBICACION`),
  KEY `NOM_IDDEPARTAMENTO_idx` (`NOM_IDDEPARTAMENTO`),
  KEY `NOM_IDCLASIFICACION_idx` (`NOM_IDCLASIFICACION`),
  CONSTRAINT `NOM_ID_PERSONA` FOREIGN KEY (`NOM_ID_PERSONA`) REFERENCES `nompersona` (`NOM_ID_PERSONA`),
  CONSTRAINT `NOM_ID_PUESTO` FOREIGN KEY (`NOM_ID_PUESTO`) REFERENCES `nompuestos` (`NOM_ID_PUESTO`),
  CONSTRAINT `NOM_ID_UBICACION` FOREIGN KEY (`NOM_ID_UBICACION`) REFERENCES `nomubicacion` (`NOM_ID_UBICACION`),
  CONSTRAINT `NOM_IDCLASIFICACION` FOREIGN KEY (`NOM_IDCLASIFICACION`) REFERENCES `nomclasificacion` (`NOM_IDCLASIFICACION`),
  CONSTRAINT `NOM_IDDEPARTAMENTO` FOREIGN KEY (`NOM_IDDEPARTAMENTO`) REFERENCES `nomdepartamento` (`NOM_IDDEPARTA`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Es la tabla en donde podremos saber la información del Empleado que ha entrado a laborar en la empresa, la cual tiene bastante información con respecto al puesto laboral.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nomempleados`
--

LOCK TABLES `nomempleados` WRITE;
/*!40000 ALTER TABLE `nomempleados` DISABLE KEYS */;
INSERT INTO `nomempleados` VALUES (1,10,1,1,'2015-12-31 00:00:00',1500,1,'0000-00-00 00:00:00','Cheque',1,1),(2,8,1,1,'2015-12-31 00:00:00',980,1,'0000-00-00 00:00:00','Efectivo',1,1),(3,2,1,1,'2015-12-31 00:00:00',980,1,'0000-00-00 00:00:00','Cheque',1,1),(4,1,1,1,'2015-12-31 00:00:00',980,1,'0000-00-00 00:00:00','Efectivo',1,1),(5,9,1,1,'2015-12-31 00:00:00',980,1,'0000-00-00 00:00:00','Transferencia',1,1),(6,7,1,1,'2015-12-31 00:00:00',980,1,'0000-00-00 00:00:00','Transferencia',1,1),(7,5,1,1,'2015-12-31 00:00:00',980,1,'0000-00-00 00:00:00','Transferencia',1,1);
/*!40000 ALTER TABLE `nomempleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nompersona`
--

DROP TABLE IF EXISTS `nompersona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nompersona` (
  `NOM_ID_PERSONA` int NOT NULL AUTO_INCREMENT,
  `NOM_NOMBRE` varchar(100) DEFAULT NULL,
  `NOM_APELLIDO` varchar(100) DEFAULT NULL,
  `NOM_ID_CIUDADNAC` int DEFAULT NULL,
  `NOM_FECHA_NAC` datetime DEFAULT NULL,
  `NOM_EDAD` int DEFAULT NULL,
  `NOM_CASADO` int DEFAULT NULL,
  `NOM_HIJOS` int DEFAULT NULL,
  `NOM_NUMEROHIJOS` int DEFAULT NULL,
  `NOM_IDENTIFICACION` char(20) DEFAULT NULL,
  `NOM_RFC` char(13) DEFAULT NULL,
  `NOM_CURP` char(18) DEFAULT NULL,
  `NOM_TELEFONO` char(10) DEFAULT NULL,
  `NOM_CORREO` char(50) DEFAULT NULL,
  `NOMPERSONAcol` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`NOM_ID_PERSONA`),
  KEY `NOM_ID_CIUDADNAC_idx` (`NOM_ID_CIUDADNAC`),
  CONSTRAINT `NOM_ID_CIUDADNAC` FOREIGN KEY (`NOM_ID_CIUDADNAC`) REFERENCES `princiudades` (`PRIN_IDCIUDAD`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Esta tabla servirá para poder dar de alta al padrón de Personas que podrán ser empleados y por lo tanto contiene información personal ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nompersona`
--

LOCK TABLES `nompersona` WRITE;
/*!40000 ALTER TABLE `nompersona` DISABLE KEYS */;
INSERT INTO `nompersona` VALUES (1,'David Jose','Lopez Chan',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal1@gmail.com',NULL),(2,'Rolando de Jesús','Pech Tun',1,'1985-12-31 00:00:00',37,1,1,1,'LUC997995','PETR850330LJ4','PETR850330HQRPHV98','9992601402','personal2@gmail.com',NULL),(3,'Shirley María','Canul Dzib',1,'1985-12-31 00:00:00',34,1,1,4,'LUC997115','CADS871231LL7','CADS871231MQRPHV58','9992601403','personal3@gmail.com',NULL),(4,'Diana Lucía','Ventura Tzec',1,'1985-12-31 00:00:00',33,0,1,1,'LUC994585','VETD890624DU7','VETD890624QRNPHV68','9992601407','personal4@gmail.com',NULL),(5,'Sandra Maribel','Escalante Vallejos',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal5@gmail.com',NULL),(6,'Ruben','Prado Cano',1,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal6@gmail.com',NULL),(7,'Jesús del Carmen','Avila Camacho',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal7@gmail.com',NULL),(8,'Darinel Eduardo','Lope Castillo',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal8@gmail.com',NULL),(9,'Jorge Alberto','Navarrete Tzuc',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal9@gmail.com',NULL),(10,'Victoria Albertana','Romero Zozaya',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal10@gmail.com',NULL),(11,'David Jose','Lopez Chan',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal1@gmail.com',NULL),(12,'David Jose','Lopez Chan',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal1@gmail.com',NULL),(13,'David Jose','Lopez Chan',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal1@gmail.com',NULL),(14,'David Jose','Lopez Chan',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal1@gmail.com',NULL);
/*!40000 ALTER TABLE `nompersona` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-11-07 22:46:01


/* En este Trigguer se controlará la información que se Actualiza en la tabla de Empleados, esto para saber los cambios que se están realizando, por cada uno de los empleados*/
USE nomina$$
DROP TRIGGER IF EXISTS nomina.nomempleadosBU $$

DELIMITER $$
CREATE TRIGGER nomempleadosBU BEFORE UPDATE ON nomempleados FOR EACH ROW 
BEGIN
  INSERT INTO log_nomepleados (log_nomempleadouser, log_nomepleadosfecha, log_nomepleadoshora, DESCRIPCIONCAMBIO)
  VALUES (USER(), CURRENT_DATE(), time(now()), CONCAT('Empleado con ID: ', OLD.NOM_ID_EMPLEADO, ' se actualizó con la siguiente información pasa de: ', OLD.NOM_SUELDODIARIO, ' a tener: ', NEW.NOM_SUELDODIARIO, ' y su pago pasa de: ', OLD.NOM_FORMAPAGO , ' a ser en: ', NEW.NOM_FORMAPAGO ));
END $$
DELIMITER ;

-- Ejemplo de Actualización de Datos -- 
update nomempleados
SET NOM_SUELDODIARIO = 1500, NOM_FORMAPAGO = 'Cheque'
Where NOM_ID_PERSONA = 10;



/* En este Trigguer tiene como objetivo guardar la información de quien cuando y como se está insertando datos en la tabla de Empleados*/
USE nomina$$
DROP TRIGGER IF EXISTS nomina.nompersonaAI $$

DELIMITER $$
CREATE TRIGGER nompersonaAI AFTER INSERT ON nompersona FOR EACH ROW
BEGIN
	INSERT INTO log_nompersona (log_nompersonauser, log_nompersonafecha, log_nompersonahora, NOM_NOMBRE, NOM_APELLIDO, NOM_ID_PERSONA) 
    VALUES (USER(), CURRENT_DATE(), time(now()), NEW.NOM_NOMBRE, NEW.NOM_APELLIDO, NEW.NOM_ID_PERSONA);
END $$
DELIMITER ;


-- Ejemplo de Inserción de Datos -- 
INSERT INTO `nompersona` VALUES (15,'David Jose','Lopez Chan',5,'1985-12-31 00:00:00',36,1,1,3,'LUC997885','LOCD851231LJ4','LOCD851231HYNPHV58','9992601401','personal1@gmail.com',NULL);

/**************************************************************************************************
* David José de Jesús López Chan	       													      *
* Sistema: Nómina																	    		  *
* Objetivo: El primer S.P. debe permitir indicar a través de un parámetro el campo de             *
* ordenamiento de una tabla y mediante un segundo parámetro, si el orden es descendente           *
* o ascendente.			                                                                          *																			  
* ------------------------------------------------------------------------------------------------*
*																						          *
* Versión   Fecha        Usuario            Descripción									          *
* -------   ----------   ------------------ ------------------------------------------- ----------*
*  1.0      02/11/2022   David López	    Intento para la creación de dos SPs                   *
*  																								  *
**************************************************************************************************/
USE nomina;

DROP PROCEDURE IF EXISTS `OrdernarTabla`;

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `OrdernarTabla` (IN band INTEGER, IN columna CHAR(40), IN forma CHAR(40)) /*La SP recibirá la info de bandera, para que sepa como procede, nombre de la tabla y la forma (ASC o DESC)*/
BEGIN
	SET @forma = (forma); /*variable de la forma*/
	IF band = 1 THEN
		SET @tableorder = concat('ORDER BY ', columna);/* si la condición es para saber si se ordena o no*/
        
	ELSE
		SET @tableorder = '';
	END IF;
    
	    
    SET @clausula = concat('SELECT * FROM nomina.nomempleados ', @tableorder, @forma); /*realiza la selección de la tabla y la forma en la que se verá en la consulta*/
    
    PREPARE runSQL FROM @clausula;
    EXECUTE runSQL;
    DEALLOCATE PREPARE runSQL; 

END//
 
call OrdernarTabla("1","nom_formapago", " DESC"); /*A la SP hay que mandarle la bandera (0 o 1), el nomnre de la columna, y la manera en que regresará la info de la tabla*/


USE nomina;

DROP PROCEDURE IF EXISTS `InsertarEliminar`;

DELIMITER //
/*La SP validará una bandera para saber si inserta o elimina, el ID para eliminar, en su defecto es '0', las variables de Ciudad, Estado y Pais*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEliminar` (IN band INTEGER, IN ID INT, IN CIUDAD VARCHAR(40), IN ESTADO VARCHAR (40), IN PAIS VARCHAR (40))
BEGIN
	IF band = 1 THEN /*Bandera que valida si inserta o elimina*/
		INSERT INTO princiudades (PRIN_NOMBRECIUDAD, PRIN_NOMBREESTADO, PRIN_NOMBREPAIS)
		VALUES (CIUDAD, ESTADO, PAIS);
	ELSE
		DELETE FROM princiudades WHERE PRIN_IDCIUDAD = ID;
	END IF;
END//


CALL INSERTARELIMINAR ('1','0','CDMX', 'CDMX', 'MÉXICO') /*Las variables que se manda son: 1 para insertar, 0 para elimindar, el ID del registro, y las variables*/
