DELIMITER $$

DROP PROCEDURE IF EXISTS sp_deleteUser;

CREATE PROCEDURE IF NOT EXISTS sp_deleteUser(
   IN inp_name VARCHAR(250),
   OUT u_delRows INT,
   OUT eh_delRows INT,
   OUT et_delRows INT,
   OUT tr_delRows INT
)
BEGIN

 START TRANSACTION;
 
  DELETE FROM emotiontracker_users WHERE name = inp_name;
  SET u_delRows = ROW_COUNT();
  
  DELETE FROM emotionhistory WHERE ACTIVE = 1 AND UPDATED_BY = inp_name;
  SET eh_delRows = ROW_COUNT();
  
  DELETE FROM emotion_triggers WHERE ACTIVE = 1 AND UPDATED_BY = inp_name;
  SET et_delRows = ROW_COUNT();

  DELETE FROM triggers WHERE ACTIVE = 1 AND UPDATED_BY = inp_name;
  SET tr_delRows = ROW_COUNT();
  
 COMMIT;
 
 SELECT u_delRows, eh_delRows, et_delRows, tr_delRows;
 
END$$              

DELIMITER ;