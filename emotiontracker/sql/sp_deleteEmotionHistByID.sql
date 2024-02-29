DELIMITER $$

DROP PROCEDURE IF EXISTS sp_deleteEmotionHistByID;

CREATE PROCEDURE IF NOT EXISTS sp_deleteEmotionHistByID(
   IN inp_ehid INT
)
BEGIN

 START TRANSACTION;

  DELETE FROM emotionhistory WHERE id = inp_ehid;

 COMMIT;

END$$

DELIMITER ;



/*
CALL sp_deleteEmotionHistByID(4);
*/