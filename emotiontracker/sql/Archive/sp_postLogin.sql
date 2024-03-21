DELIMITER $$

DROP PROCEDURE IF EXISTS sp_postLogin;

CREATE PROCEDURE IF NOT EXISTS sp_postLogin(
  IN inp_username VARCHAR(250),
  IN inp_userpass VARCHAR(50),
  OUT ERR_MESSAGE VARCHAR(500),
  OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_username IS NULL OR inp_userpass IS NULL) THEN
     SET ERR_MESSAGE = 'Invalid input(s). Username and Password must not be null.', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 SELECT id FROM emotiontracker_users u
 WHERE u.name = inp_username 
 AND u.password = SHA2(CONCAT(inp_username,
                              inp_userpass,
							  (SELECT salt FROM emotiontracker_userauth
                               WHERE id = (SELECT id FROM emotiontracker_users
 							               WHERE name = inp_username)))
							  ,256);

END$$

DELIMITER ;