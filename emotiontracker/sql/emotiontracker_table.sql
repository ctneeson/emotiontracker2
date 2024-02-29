SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT;
SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS;
SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION;
SET NAMES utf8mb4;

USE emotiontracker;
-- Drop fk_emotionhistory if exists
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
-- Drop fk_emotion_trigger_id if exists
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

-- Populate sample data - triggers
TRUNCATE TABLE `triggers`;
TRUNCATE TABLE `emotionhistory`;
TRUNCATE TABLE `emotion_triggers`;

-- Constraints for table `emotion_triggers`
ALTER TABLE `emotion_triggers` ADD CONSTRAINT `fk_emotiontriggers_emotionhistory_id` FOREIGN KEY (`emotionhistory_id`) REFERENCES emotionhistory(`id`) ON DELETE CASCADE;
ALTER TABLE `emotion_triggers` ADD CONSTRAINT `fk_emotiontriggers_trigger_id` FOREIGN KEY (`trigger_id`) REFERENCES triggers(`id`) ON DELETE CASCADE;

-- Populate triggers table
INSERT INTO triggers(description, UPDATED_BY) VALUES('Work Stress', 'admin');
INSERT INTO triggers(description, UPDATED_BY) VALUES('Argument', 'admin');
INSERT INTO triggers(description, UPDATED_BY) VALUES('Phone Call', 'admin');
INSERT INTO triggers(description, UPDATED_BY) VALUES('Financial', 'admin');

-- Populate emotionhistory table
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(6, 8, 6, 2, 5, 5, 2, 'Notes - Work situation', 'admin');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(9, 8, 8, 1, 4, 4, 6, 'Notes - Argument', 'admin');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(3, 7, 7, 3, 3, 0, 2, 'Notes - Phone call', 'admin');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(0, 0, 0, 7, 1, 1, 1, 'Notes - Financial news', 'admin');
INSERT INTO emotionhistory(level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY) VALUES(5, 6, 7, 7, 6, 5, 6, 'Notes - No triggers', 'admin');

-- Populate emotion_triggers table
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(1,1, 'admin');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(1,2, 'admin');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(2,2, 'admin');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(3,3, 'admin');
INSERT INTO emotion_triggers(emotionhistory_id, trigger_id, UPDATED_BY) VALUES(4,4, 'admin');

COMMIT;

SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT;
SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS;
SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION;
