DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getTriggers;

CREATE PROCEDURE IF NOT EXISTS sp_getTriggers(
   IN inp_userid INT,
   OUT ERR_MESSAGE VARCHAR(500),
   OUT ERR_IND BIT
)

 BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_userid IS NULL) THEN
     SET ERR_MESSAGE = 'Invalid input(s). User ID must not be null.', ERR_IND = 1;
 ELSEIF (inp_userid NOT IN (SELECT id FROM emotiontracker_users)) THEN
     SET ERR_MESSAGE = 'Invalid User ID provided', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

  SELECT GROUP_CONCAT(t.description ORDER BY t.id ASC SEPARATOR ",") AS triggerList
  FROM triggers t
  JOIN emotiontracker_users u
   ON u.id = inp_userid
   AND t.ACTIVE = 1
   AND t.UPDATED_BY = u.name;

 END$$

DELIMITER ;