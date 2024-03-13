SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT;
SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS;
SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION;
SET NAMES utf8mb4;

USE emotiontracker;
-- Drop fk_emotiontriggers_emotionhistory_id if exists
set @var=if( (SELECT true
              FROM information_schema.TABLE_CONSTRAINTS
			  WHERE CONSTRAINT_SCHEMA = DATABASE()
			  AND TABLE_NAME          = 'emotion_triggers'
			  AND CONSTRAINT_NAME     = 'fk_emotiontriggers_emotionhistory_id'
			  AND CONSTRAINT_TYPE     = 'FOREIGN KEY') = true,
			 'ALTER TABLE emotion_triggers drop foreign key fk_emotiontriggers_emotionhistory_id',
			 'select 1');
prepare stmt from @var;
execute stmt;
deallocate prepare stmt;
-- Drop fk_emotiontriggers_trigger_id if exists
set @var=if( (SELECT true
              FROM information_schema.TABLE_CONSTRAINTS
			  WHERE CONSTRAINT_SCHEMA = DATABASE()
			  AND TABLE_NAME          = 'emotion_triggers'
			  AND CONSTRAINT_NAME     = 'fk_emotiontriggers_trigger_id'
			  AND CONSTRAINT_TYPE     = 'FOREIGN KEY') = true,
			 'ALTER TABLE emotion_triggers drop foreign key fk_emotiontriggers_trigger_id',
			 'select 1');
prepare stmt from @var;
execute stmt;
deallocate prepare stmt;
-- Drop fk_emotiontriggers_emotiontrackerusers_updatedby if exists
set @var=if( (SELECT true
              FROM information_schema.TABLE_CONSTRAINTS
			  WHERE CONSTRAINT_SCHEMA = DATABASE()
			  AND TABLE_NAME          = 'emotion_triggers'
			  AND CONSTRAINT_NAME     = 'fk_emotiontriggers_emotiontrackerusers_updatedby'
			  AND CONSTRAINT_TYPE     = 'FOREIGN KEY') = true,
			 'ALTER TABLE emotion_triggers drop foreign key fk_emotiontriggers_emotiontrackerusers_updatedby',
			 'select 1');
prepare stmt from @var;
execute stmt;
deallocate prepare stmt;
-- Drop fk_emotionhistory_emotiontrackerusers_updatedby if exists
set @var=if( (SELECT true
              FROM information_schema.TABLE_CONSTRAINTS
			  WHERE CONSTRAINT_SCHEMA = DATABASE()
			  AND TABLE_NAME          = 'emotionhistory'
			  AND CONSTRAINT_NAME     = 'fk_emotionhistory_emotiontrackerusers_updatedby'
			  AND CONSTRAINT_TYPE     = 'FOREIGN KEY') = true,
			 'ALTER TABLE emotionhistory drop foreign key fk_emotionhistory_emotiontrackerusers_updatedby',
			 'select 1');
prepare stmt from @var;
execute stmt;
deallocate prepare stmt;
-- Drop fk_triggers_emotiontrackerusers_updatedby if exists
set @var=if( (SELECT true
              FROM information_schema.TABLE_CONSTRAINTS
			  WHERE CONSTRAINT_SCHEMA = DATABASE()
			  AND TABLE_NAME          = 'triggers'
			  AND CONSTRAINT_NAME     = 'fk_triggers_emotiontrackerusers_updatedby'
			  AND CONSTRAINT_TYPE     = 'FOREIGN KEY') = true,
			 'ALTER TABLE triggers drop foreign key fk_triggers_emotiontrackerusers_updatedby',
			 'select 1');
prepare stmt from @var;
execute stmt;
deallocate prepare stmt;


-- Table structure for table `emotionhistory`
DROP TABLE IF EXISTS `emotionhistory`;
CREATE TABLE `emotionhistory` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `level_anger` INT NOT NULL DEFAULT 0,
  `level_contempt` INT NOT NULL DEFAULT 0,
  `level_disgust` INT NOT NULL DEFAULT 0,
  `level_enjoyment` INT NOT NULL DEFAULT 0,
  `level_fear` INT NOT NULL DEFAULT 0,
  `level_sadness` INT NOT NULL DEFAULT 0,
  `level_surprise` INT NOT NULL DEFAULT 0,
  `notes` VARCHAR(500) NULL,
  `ACTIVE` BIT NOT NULL DEFAULT 1,
  `INSERT_DATE` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `UPDATE_DATE` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `UPDATED_BY` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table structure for table `emotion_triggers`
DROP TABLE IF EXISTS `emotion_triggers`;
CREATE TABLE `emotion_triggers` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `emotionhistory_id` INT NOT NULL,
  `trigger_id` INT NOT NULL,
  `ACTIVE` BIT NOT NULL DEFAULT 1,
  `INSERT_DATE` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `UPDATE_DATE` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `UPDATED_BY` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table structure for table `triggers`
DROP TABLE IF EXISTS `triggers`;
CREATE TABLE `triggers` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(100) NOT NULL,
  `ACTIVE` BIT NOT NULL DEFAULT 1,
  `INSERT_DATE` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `UPDATE_DATE` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `UPDATED_BY` VARCHAR(100) NOT NULL,
  CONSTRAINT uc_description_updatedby UNIQUE (description,UPDATED_BY)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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

-- Truncate tables before repopulating
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `emotiontracker_users`;
TRUNCATE TABLE `emotiontracker_userstypes`;
TRUNCATE TABLE `triggers`;
TRUNCATE TABLE `emotionhistory`;
TRUNCATE TABLE `emotion_triggers`;
SET FOREIGN_KEY_CHECKS = 1;

-- Populate table `emotiontracker_userstypes`
INSERT INTO `emotiontracker_userstypes` (`role`) VALUES
('administrator'),
('user');

-- Populate table `emotiontracker_users`
INSERT INTO `emotiontracker_users` (`name`, `firstname`, `lastname`, `email`, `password`, `type_id`) VALUES
('admin', 'Admini', 'Strator', 'admin@admin.com', 'admin123', 1),
('user', 'User', 'McUser', 'user@qub.ac.uk', 'user123', 2);

-- Constraints for table `emotion_triggers`
ALTER TABLE `emotion_triggers` ADD CONSTRAINT `fk_emotiontriggers_emotionhistory_id` FOREIGN KEY (`emotionhistory_id`) REFERENCES emotionhistory(`id`) ON DELETE CASCADE;
ALTER TABLE `emotion_triggers` ADD CONSTRAINT `fk_emotiontriggers_trigger_id` FOREIGN KEY (`trigger_id`) REFERENCES triggers(`id`) ON DELETE CASCADE;
ALTER TABLE `emotion_triggers` ADD CONSTRAINT `fk_emotiontriggers_emotiontrackerusers_updatedby` FOREIGN KEY (UPDATED_BY) REFERENCES `emotiontracker_users` (`name`);

-- Constraints for table `emotionhistory`
ALTER TABLE `emotionhistory` ADD CONSTRAINT `fk_emotionhistory_emotiontrackerusers_updatedby` FOREIGN KEY (UPDATED_BY) REFERENCES `emotiontracker_users` (`name`);

-- Constraints for table `triggers`
ALTER TABLE `triggers` ADD CONSTRAINT `fk_triggers_emotiontrackerusers_updatedby` FOREIGN KEY (UPDATED_BY) REFERENCES `emotiontracker_users` (`name`);

-- Populate triggers table
INSERT INTO triggers(description, UPDATED_BY) VALUES('Work Stress', 'user');
INSERT INTO triggers(description, UPDATED_BY) VALUES('Argument', 'user');
INSERT INTO triggers(description, UPDATED_BY) VALUES('Phone Call', 'user');
INSERT INTO triggers(description, UPDATED_BY) VALUES('Financial', 'user');

-- Populate emotionhistory table
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(6, 8, 6, 2, 5, 5, 2, 'Notes - Work situation', 'user');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(9, 8, 8, 1, 4, 4, 6, 'Notes - Argument', 'user');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(3, 7, 7, 3, 3, 0, 2, 'Notes - Phone call', 'user');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(0, 0, 0, 7, 1, 1, 1, 'Notes - Financial news', 'user');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(5, 6, 7, 7, 6, 5, 6, 'Notes - No triggers', 'user');

-- Populate emotion_triggers table
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(1,1, 'user');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(1,2, 'user');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(2,2, 'user');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(3,3, 'user');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(4,4, 'user');

COMMIT;

SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT;
SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS;
SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION;
