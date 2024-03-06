DELIMITER $$

DROP PROCEDURE IF EXISTS sp_postLogin;

CREATE PROCEDURE IF NOT EXISTS sp_postLogin(
   IN inp_username VARCHAR(250),
   IN inp_userpass VARCHAR(50)
)
BEGIN

 SELECT id FROM emotiontracker_users u
 WHERE u.name = inp_username 
 AND u.password = inp_userpass;

END$$

DELIMITER ;