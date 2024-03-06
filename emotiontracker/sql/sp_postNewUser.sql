DELIMITER $$

DROP PROCEDURE IF EXISTS sp_postNewUser;

CREATE PROCEDURE IF NOT EXISTS sp_postNewUser(
   IN inp_name VARCHAR(250),
   IN inp_firstname VARCHAR(100),
   IN inp_lastname VARCHAR(100),
   IN inp_email VARCHAR(250),
   IN inp_password VARCHAR(50),
   IN inp_typeid INT,
   OUT ins_rows INT
)
BEGIN

 START TRANSACTION;
 
 /*- Add emotion levels & notes to emotionhistory table -*/
 INSERT INTO emotiontracker_users (name, firstname, lastname, email, password, type_id) VALUES (inp_name, inp_firstname, inp_lastname, inp_email, inp_password, inp_typeid);
 SET ins_rows = ROW_COUNT();

 COMMIT;
 
 SELECT @ins_rows;

END$$

DELIMITER ;