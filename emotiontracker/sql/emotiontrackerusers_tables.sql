SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT;
SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS;
SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION;
SET NAMES utf8mb4;

-- Create table `emotiontracker_users`
DROP TABLE IF EXISTS `emotiontracker_users`;
CREATE TABLE IF NOT EXISTS `emotiontracker_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `firstname` varchar(100),
  `lastname` varchar(100),
  `email` varchar(250) NOT NULL,
  `password` varchar(50) NOT NULL,
  `type_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type_id` (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create table `emotiontracker_userstypes`
DROP TABLE IF EXISTS `emotiontracker_userstypes`;
CREATE TABLE IF NOT EXISTS `emotiontracker_userstypes` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(100) NOT NULL,
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Constraints for table `emotiontracker_users`
ALTER TABLE `emotiontracker_users` ADD UNIQUE(`name`);
ALTER TABLE `emotiontracker_users` ADD UNIQUE(`email`);
ALTER TABLE `emotiontracker_users` ADD CONSTRAINT minlength_name CHECK (CHAR_LENGTH(name) >= 3);
ALTER TABLE `emotiontracker_users` ADD CONSTRAINT minlength_email CHECK (CHAR_LENGTH(email) >= 3);
ALTER TABLE `emotiontracker_users` ADD CONSTRAINT minlength_password CHECK (CHAR_LENGTH(password) >= 6);
ALTER TABLE `emotiontracker_users` ADD CONSTRAINT `emotiontracker_users_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `emotiontracker_userstypes` (`type_id`);

-- Populate table `emotiontracker_userstypes`
INSERT INTO `emotiontracker_userstypes` (`role`) VALUES
('administrator'),
('user');

-- Populate table `emotiontracker_users`
INSERT INTO `emotiontracker_users` (`name`, `firstname`, `lastname`, `email`, `password`, `type_id`) VALUES
('admin', 'Admini', 'Strator', 'admin@admin.com', 'admin123', 1),
('ctn', 'Ciaran', 'Neeson', 'cneeson04@qub.ac.uk', 'ctn123', 2);

COMMIT;

SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT;
SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS;
SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION;
