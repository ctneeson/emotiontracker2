DELIMITER $$

DROP PROCEDURE IF EXISTS sp_deleteUser;

CREATE PROCEDURE IF NOT EXISTS sp_deleteUser(
   IN inp_name VARCHAR(250),
   OUT u_delRows INT,
   OUT ua_delRows INT,
   OUT eh_delRows INT,
   OUT et_delRows INT,
   OUT tr_delRows INT,
   OUT ERR_MESSAGE VARCHAR(500),
   OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_name IS NULL) THEN
     SET ERR_MESSAGE = 'Invalid input. Username must not be null.', ERR_IND = 1;
 ELSEIF (SELECT COUNT(name) FROM emotiontracker_users WHERE name = inp_name) = 0 THEN
     SET ERR_MESSAGE = 'The username provided does not exist.', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 START TRANSACTION;
 
  DELETE FROM emotiontracker_userauth WHERE id = (SELECT id FROM emotiontracker_users WHERE name = inp_name);
  SET ua_delRows = ROW_COUNT();
  
  DELETE FROM emotionhistory WHERE ACTIVE = 1 AND UPDATED_BY = inp_name;
  SET eh_delRows = ROW_COUNT();
  
  DELETE FROM emotion_triggers WHERE ACTIVE = 1 AND UPDATED_BY = inp_name;
  SET et_delRows = ROW_COUNT();

  DELETE FROM triggers WHERE ACTIVE = 1 AND UPDATED_BY = inp_name;
  SET tr_delRows = ROW_COUNT();
  
  DELETE FROM emotiontracker_users WHERE name = inp_name;
  SET u_delRows = ROW_COUNT();
  
 COMMIT;
 
 SELECT u_delRows, ua_delRows, eh_delRows, et_delRows, tr_delRows;
 
END$$              

DELIMITER ;