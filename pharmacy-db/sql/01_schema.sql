-- Схема базы pharmacy (вариант «Аптека»): 14 таблиц со связями.
-- Удаляет и пересоздаёт таблицы. Данные — в 02_data.sql.
CREATE DATABASE IF NOT EXISTS pharmacy
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pharmacy;
SET NAMES utf8mb4;

-- Отключаем проверку внешних ключей, чтобы удалять и заполнять таблицы
-- в любом порядке; в конце включаем обратно.
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. Удаление старых таблиц
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `запросы на лекарства`;
DROP TABLE IF EXISTS `клиент`;
DROP TABLE IF EXISTS `ассортимент`;
DROP TABLE IF EXISTS `лекарство`;
DROP TABLE IF EXISTS `основное вещество`;
DROP TABLE IF EXISTS `назначение`;
DROP TABLE IF EXISTS `форма выпуска`;
DROP TABLE IF EXISTS `маршруты аптек`;
DROP TABLE IF EXISTS `аптека`;
DROP TABLE IF EXISTS `транспортные маршруты`;
DROP TABLE IF EXISTS `остановка`;
DROP TABLE IF EXISTS `вид транспорта`;
DROP TABLE IF EXISTS `районы`;
DROP TABLE IF EXISTS `сеть`;

-- ---------------------------------------------------------------------
-- 2. Создание таблиц
-- ---------------------------------------------------------------------

-- Сети аптек
CREATE TABLE `сеть` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Наименование_сети` varchar(150) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Районы
CREATE TABLE `районы` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Название_района` varchar(150) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Виды транспорта
CREATE TABLE `вид транспорта` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Название` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Остановки
CREATE TABLE `остановка` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Название_остановки` varchar(150) NOT NULL,
  `ID_районы` int NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID_районы` (`ID_районы`),
  CONSTRAINT `остановка_ibfk_1` FOREIGN KEY (`ID_районы`) REFERENCES `районы` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Транспортные маршруты
CREATE TABLE `транспортные маршруты` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ID_Вид_транспорта` int NOT NULL,
  `Номер_маршрута` varchar(20) NOT NULL,
  `ID_Остановка` int NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID_Вид_транспорта` (`ID_Вид_транспорта`),
  KEY `ID_Остановка` (`ID_Остановка`),
  CONSTRAINT `транспортные маршруты_ibfk_1` FOREIGN KEY (`ID_Вид_транспорта`) REFERENCES `вид транспорта` (`ID`),
  CONSTRAINT `транспортные маршруты_ibfk_2` FOREIGN KEY (`ID_Остановка`) REFERENCES `остановка` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Аптеки
CREATE TABLE `аптека` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ID_Сеть` int NOT NULL,
  `Название_аптеки` varchar(150) NOT NULL,
  `Адрес` varchar(255) DEFAULT NULL,
  `График` varchar(100) DEFAULT NULL,
  `ID_Районы` int NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID_Сеть` (`ID_Сеть`),
  KEY `ID_Районы` (`ID_Районы`),
  CONSTRAINT `аптека_ibfk_1` FOREIGN KEY (`ID_Сеть`) REFERENCES `сеть` (`ID`),
  CONSTRAINT `аптека_ibfk_2` FOREIGN KEY (`ID_Районы`) REFERENCES `районы` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Как добраться до аптек
CREATE TABLE `маршруты аптек` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ID_Аптека` int NOT NULL,
  `ID_Транспортный_маршрут` int NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID_Аптека` (`ID_Аптека`),
  KEY `ID_Транспортный_маршрут` (`ID_Транспортный_маршрут`),
  CONSTRAINT `маршруты аптек_ibfk_1` FOREIGN KEY (`ID_Аптека`) REFERENCES `аптека` (`ID`),
  CONSTRAINT `маршруты аптек_ibfk_2` FOREIGN KEY (`ID_Транспортный_маршрут`) REFERENCES `транспортные маршруты` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Формы выпуска
CREATE TABLE `форма выпуска` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Название` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Назначение (группы лекарств)
CREATE TABLE `назначение` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Наименование_Назначения` varchar(150) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Действующие вещества
CREATE TABLE `основное вещество` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Название_основного_вещества` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Лекарства
CREATE TABLE `лекарство` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Название_лекарства` varchar(255) NOT NULL,
  `ID_Основное_вещество` int NOT NULL,
  `ID_Назначение` int DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID_Основное_вещество` (`ID_Основное_вещество`),
  KEY `ID_Назначение` (`ID_Назначение`),
  CONSTRAINT `лекарство_ibfk_1` FOREIGN KEY (`ID_Основное_вещество`) REFERENCES `основное вещество` (`ID`),
  CONSTRAINT `лекарство_ibfk_2` FOREIGN KEY (`ID_Назначение`) REFERENCES `назначение` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ассортимент аптек
CREATE TABLE `ассортимент` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ID_Аптека` int NOT NULL,
  `ID_Лекарство` int NOT NULL,
  `ID_Форма_выпуска` int NOT NULL,
  `Объем_вес` varchar(50) DEFAULT NULL,
  `Количество_в_упаковке` int DEFAULT NULL,
  `Цена_за_упаковку` decimal(10,2) DEFAULT NULL,
  `Количество_в_аптеке` int DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID_Аптека` (`ID_Аптека`),
  KEY `ID_Лекарство` (`ID_Лекарство`),
  KEY `ID_Форма_выпуска` (`ID_Форма_выпуска`),
  CONSTRAINT `ассортимент_ibfk_1` FOREIGN KEY (`ID_Аптека`) REFERENCES `аптека` (`ID`),
  CONSTRAINT `ассортимент_ibfk_2` FOREIGN KEY (`ID_Лекарство`) REFERENCES `лекарство` (`ID`),
  CONSTRAINT `ассортимент_ibfk_3` FOREIGN KEY (`ID_Форма_выпуска`) REFERENCES `форма выпуска` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Клиенты
CREATE TABLE `клиент` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Имя` varchar(100) NOT NULL,
  `Номер_телефона` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Запросы клиентов на лекарства
CREATE TABLE `запросы на лекарства` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ID_Форма_упаковки` int NOT NULL,
  `Запрашиваемое_количество` int DEFAULT NULL,
  `ID_Клиент` int NOT NULL,
  `ID_Лекарство` int NOT NULL,
  `ID_Аптека` int NOT NULL,
  `Дата_запроса` date DEFAULT NULL,
  `Дата_покупки` date DEFAULT NULL,
  `Покупка` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `ID_Форма_упаковки` (`ID_Форма_упаковки`),
  KEY `ID_Клиент` (`ID_Клиент`),
  KEY `ID_Лекарство` (`ID_Лекарство`),
  KEY `ID_Аптека` (`ID_Аптека`),
  CONSTRAINT `запросы на лекарства_ibfk_1` FOREIGN KEY (`ID_Форма_упаковки`) REFERENCES `форма выпуска` (`ID`),
  CONSTRAINT `запросы на лекарства_ibfk_2` FOREIGN KEY (`ID_Клиент`) REFERENCES `клиент` (`ID`),
  CONSTRAINT `запросы на лекарства_ibfk_3` FOREIGN KEY (`ID_Лекарство`) REFERENCES `лекарство` (`ID`),
  CONSTRAINT `запросы на лекарства_ibfk_4` FOREIGN KEY (`ID_Аптека`) REFERENCES `аптека` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
