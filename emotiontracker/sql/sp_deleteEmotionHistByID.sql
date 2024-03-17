DELIMITER $$

DROP PROCEDURE IF EXISTS sp_deleteEmotionHistByID;

CREATE PROCEDURE IF NOT EXISTS sp_deleteEmotionHistByID(
   IN inp_ehid INT,
   OUT del_affectedRows INT
)
BEGIN

 START TRANSACTION;

  DELETE FROM emotionhistory WHERE id = inp_ehid;

 COMMIT;
 
 SELECT ROW_COUNT() AS del_affectedRows;

END$$

DELIMITER ;