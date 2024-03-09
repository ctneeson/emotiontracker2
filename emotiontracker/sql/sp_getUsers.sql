DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getUsers;

CREATE PROCEDURE IF NOT EXISTS sp_getUsers(
  IN inp_userid INT,
  IN inp_role VARCHAR(100)
)
BEGIN

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