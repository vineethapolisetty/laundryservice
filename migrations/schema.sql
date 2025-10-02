-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: laundryservice
-- ------------------------------------------------------
-- Server version	8.0.41

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
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `AdminID` int NOT NULL AUTO_INCREMENT,
  `FullName` varchar(100) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `PasswordHash` varchar(255) DEFAULT NULL,
  `Role` enum('RegionAdmin','SuperAdmin') NOT NULL,
  `RegionID` int DEFAULT NULL,
  `CreatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`AdminID`),
  KEY `RegionID` (`RegionID`),
  CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`RegionID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agents` (
  `AgentID` int NOT NULL AUTO_INCREMENT,
  `FullName` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `PasswordHash` varchar(255) DEFAULT NULL,
  `StoreID` int DEFAULT NULL,
  `RegionID` int DEFAULT NULL,
  `Status` enum('Active','Inactive') DEFAULT 'Active',
  `PhotoUrl` varchar(255) DEFAULT NULL,
  `CreatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`AgentID`),
  KEY `StoreID` (`StoreID`),
  KEY `RegionID` (`RegionID`),
  CONSTRAINT `agents_ibfk_1` FOREIGN KEY (`StoreID`) REFERENCES `stores` (`StoreID`),
  CONSTRAINT `agents_ibfk_2` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`RegionID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `NotificationID` int NOT NULL AUTO_INCREMENT,
  `UserID` int DEFAULT NULL,
  `OrderID` int DEFAULT NULL,
  `Message` text,
  `IsRead` tinyint(1) DEFAULT '0',
  `SentAt` datetime DEFAULT NULL,
  PRIMARY KEY (`NotificationID`),
  KEY `UserID` (`UserID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`),
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orderitems`
--

DROP TABLE IF EXISTS `orderitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderitems` (
  `OrderItemID` int NOT NULL AUTO_INCREMENT,
  `OrderID` int DEFAULT NULL,
  `ItemType` varchar(50) DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `PricePerItem` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`OrderItemID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `OrderID` int NOT NULL AUTO_INCREMENT,
  `UserID` int DEFAULT NULL,
  `StoreID` int DEFAULT NULL,
  `AgentID` int DEFAULT NULL,
  `DropType` enum('StoreDrop','DeliveryPickup') NOT NULL,
  `Status` enum('Pending','Accepted','InProgress','Delivered','Cancelled') DEFAULT 'Pending',
  `EstimatedDeliveryDate` datetime DEFAULT NULL,
  `DeliveryAddress` text,
  `TotalItems` int DEFAULT NULL,
  `TotalEstimatedCost` decimal(10,2) DEFAULT NULL,
  `CreatedAt` datetime DEFAULT NULL,
  `UpdatedAt` datetime DEFAULT NULL,
  `IsGracePeriod` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`OrderID`),
  KEY `UserID` (`UserID`),
  KEY `StoreID` (`StoreID`),
  KEY `AgentID` (`AgentID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`StoreID`) REFERENCES `stores` (`StoreID`),
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`AgentID`) REFERENCES `agents` (`AgentID`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `regions` (
  `RegionID` int NOT NULL AUTO_INCREMENT,
  `RegionName` varchar(100) NOT NULL,
  PRIMARY KEY (`RegionID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stores` (
  `StoreID` int NOT NULL AUTO_INCREMENT,
  `StoreName` varchar(100) DEFAULT NULL,
  `RegionID` int DEFAULT NULL,
  `Address` text,
  `Latitude` decimal(10,6) DEFAULT NULL,
  `Longitude` decimal(10,6) DEFAULT NULL,
  PRIMARY KEY (`StoreID`),
  KEY `RegionID` (`RegionID`),
  CONSTRAINT `stores_ibfk_1` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`RegionID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usermagiclinks`
--

DROP TABLE IF EXISTS `usermagiclinks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usermagiclinks` (
  `MagicID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `Token` varchar(128) NOT NULL,
  `ExpiresAt` datetime NOT NULL,
  `UsedAt` datetime DEFAULT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`MagicID`),
  UNIQUE KEY `Token` (`Token`),
  KEY `idx_user_expires` (`UserID`,`ExpiresAt`),
  CONSTRAINT `fk_magic_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `FullName` varchar(100) NOT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `PasswordHash` varchar(255) DEFAULT NULL,
  `Address` text,
  `ProfileImage` varchar(255) DEFAULT NULL,
  `RegionID` int DEFAULT NULL,
  `CreatedAt` datetime DEFAULT NULL,
  `Role` varchar(20) NOT NULL DEFAULT 'user',
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `RegionID` (`RegionID`),
  KEY `idx_users_email` (`Email`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`RegionID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-02  7:32:42
