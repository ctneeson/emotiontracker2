DELIMITER $$

DROP PROCEDURE IF EXISTS sp_updateUser;

CREATE PROCEDURE IF NOT EXISTS sp_updateUser(
   IN inp_id INT,
   IN inp_name VARCHAR(250),
   IN inp_firstname VARCHAR(100),
   IN inp_lastname VARCHAR(100),
   IN inp_email VARCHAR(250),
   IN inp_password VARCHAR(50),
   IN inp_role VARCHAR(100),
   OUT upd_affectedRows INT
)
BEGIN

 START TRANSACTION;
 
 UPDATE emotiontracker_users
 SET
  name = inp_name,
  firstname = inp_firstname,
  lastname = inp_lastname,
  email = inp_email,
  password = inp_password,
  type_id = (SELECT type_id FROM emotiontracker_userstypes WHERE role = inp_role)
 WHERE id = inp_id;
 SELECT ROW_COUNT() AS upd_affectedRows;

 COMMIT;
 
END$$

DELIMITER ;