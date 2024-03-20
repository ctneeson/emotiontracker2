DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getUserPostLogin;

CREATE PROCEDURE IF NOT EXISTS sp_getUserPostLogin(
	IN inp_username varchar(250),
	IN inp_userpass varchar(50)
)
BEGIN

SELECT u.id, ut.role
FROM emotiontracker_users u
JOIN emotiontracker_userstypes ut
 ON u.type_id = ut.type_id
WHERE u.name = inp_username
AND u.password = inp_userpass;

END$$

DELIMITER ;