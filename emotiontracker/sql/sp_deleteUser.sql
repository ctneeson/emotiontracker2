DELIMITER $$

DROP PROCEDURE IF EXISTS sp_deleteUser;

CREATE PROCEDURE IF NOT EXISTS sp_deleteUser(
   IN inp_name VARCHAR(250),
   OUT del_rows INT
)
BEGIN

 START TRANSACTION;
 
 DELETE FROM emotiontracker_users WHERE name = inp_name;
 SELECT ROW_COUNT() AS del_rows;

 COMMIT;
 
END$$

DELIMITER ;