DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getUserPostLogin;

CREATE PROCEDURE IF NOT EXISTS sp_getUserPostLogin(
	IN inp_username VARCHAR(250),
	IN inp_userpass VARCHAR(50),
    OUT ERR_MESSAGE VARCHAR(500),
    OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_username IS NULL OR inp_userpass IS NULL) THEN
     SET ERR_MESSAGE = 'Invalid input: username/password cannot be null.', ERR_IND = 1;
 ELSEIF ((SELECT LENGTH(inp_userpass) < 3) OR (SELECT LENGTH(inp_userpass) > 50)) THEN
     SET ERR_MESSAGE = 'Invalid password length.', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 SELECT u.id, u.name, ut.role
 FROM emotiontracker_users u
 JOIN emotiontracker_userstypes ut
  ON u.type_id = ut.type_id
 WHERE u.name = inp_username
 AND u.password = AES_ENCRYPT(CONCAT(inp_username,
                                     inp_userpass,
									(SELECT salt FROM emotiontracker_userauth WHERE id = (SELECT id FROM emotiontracker_users WHERE name = inp_username))),
                             (SELECT aes_key FROM emotiontracker_userauth WHERE id = (SELECT id FROM emotiontracker_users WHERE name = inp_username)));
/* AND u.password = SHA2(CONCAT(inp_username,
                              inp_userpass,
 							 (SELECT salt FROM emotiontracker_userauth
                               WHERE id = (SELECT id FROM emotiontracker_users
 							              WHERE name = inp_username)))
 							, 256);*/

END$$

DELIMITER ;