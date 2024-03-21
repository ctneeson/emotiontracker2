DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getUsers;

CREATE PROCEDURE IF NOT EXISTS sp_getUsers(
  IN inp_userid INT,
  IN inp_role VARCHAR(100),
  OUT ERR_MESSAGE VARCHAR(500),
  OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_userid IS NULL OR inp_role IS NULL) THEN
     SET ERR_MESSAGE = 'Invalid input(s). Username and Role must not be null.', ERR_IND = 1;
 ELSEIF (inp_userid NOT IN (SELECT id FROM emotiontracker_users)) THEN
     SET ERR_MESSAGE = 'Invalid User ID provided', ERR_IND = 1;
 ELSEIF (inp_role NOT IN (SELECT role FROM emotiontracker_userstypes)) THEN
     SET ERR_MESSAGE = 'Invalid Role provided', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 SELECT
  u.id,
  u.name,
  u.firstname,
  u.lastname,
  u.email,
  u.password,
  ut.role
 FROM emotiontracker_users u
 INNER JOIN emotiontracker_userstypes ut
  ON u.type_id = ut.type_id
 WHERE ( (inp_role = 'user' AND u.id = inp_userid) OR (inp_role = 'administrator') );

END$$

DELIMITER ;