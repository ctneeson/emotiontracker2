DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getUserDetails;

CREATE PROCEDURE IF NOT EXISTS sp_getUserDetails(
   IN inp_id INT,
   OUT ERR_MESSAGE VARCHAR(500),
   OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_id IS NULL) THEN
     SET ERR_MESSAGE = 'Invalid input(s). User ID must not be null.', ERR_IND = 1;
 ELSEIF (inp_id NOT IN (SELECT id FROM emotiontracker_users)) THEN
     SET ERR_MESSAGE = 'Invalid User ID provided', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 SELECT u.name, ut.role
 FROM emotiontracker_users u
 INNER JOIN emotiontracker_userstypes ut
  ON u.type_id = ut.type_id
  AND u.id = inp_id;

END$$

DELIMITER ;