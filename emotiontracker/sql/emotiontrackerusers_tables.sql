-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT;
SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS;
SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION;
SET NAMES utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `emotiontracker_users`
--

DROP TABLE IF EXISTS `emotiontracker_users`;
CREATE TABLE IF NOT EXISTS `emotiontracker_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `type_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type_id` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `emotiontracker_users`
--

INSERT INTO `emotiontracker_users` (`id`, `name`, `password`, `type_id`) VALUES
(86, 'admin', 'admin123', 1),
(87, 'ctn', 'ctn123', 2);

-- --------------------------------------------------------

--
-- Table structure for table `emotiontracker_userstypes`
--

DROP TABLE IF EXISTS `emotiontracker_userstypes`;
CREATE TABLE IF NOT EXISTS `emotiontracker_userstypes` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(100) NOT NULL,
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `emotiontracker_userstypes`
--

INSERT INTO `emotiontracker_userstypes` (`type_id`, `role`) VALUES
(1, 'administrator'),
(2, 'user');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `emotiontracker_users`
--
ALTER TABLE `emotiontracker_users`
  ADD CONSTRAINT `emotiontracker_users_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `emotiontracker_userstypes` (`type_id`);
COMMIT;

SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT;
SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS;
SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION;
