DELIMITER $$

DROP PROCEDURE IF EXISTS sp_deleteEmotionHistByID;

CREATE PROCEDURE IF NOT EXISTS sp_deleteEmotionHistByID(
   IN inp_ehid INT,
   IN inp_user VARCHAR(100),
   OUT eh_delRows INT,
   OUT et_delRows INT,
   OUT tr_delRows INT
)
BEGIN

 START TRANSACTION;
 
  -- Get triggers attached to the snapshot that's about to be deleted
  DROP TEMPORARY TABLE IF EXISTS temp_deltriggers_before;

  CREATE TEMPORARY TABLE temp_deltriggers_before
  SELECT
   et.trigger_id
  FROM emotionhistory eh
  JOIN emotion_triggers et
  ON eh.id = et.emotionhistory_id
  AND eh.ACTIVE = 1
  AND et.ACTIVE = 1
  AND eh.id = inp_ehid;
  
  -- Delete the snapshot in emotionhistory and references to it in emotion_triggers
  DELETE FROM emotionhistory WHERE id = inp_ehid;
  SET eh_delRows = ROW_COUNT();
  
  DELETE FROM emotion_triggers WHERE emotionhistory_id = inp_ehid;
  SET et_delRows = ROW_COUNT();
  
  -- Delete any triggers belonging to inp_user that are no longer attached to a snapshot
  DROP TEMPORARY TABLE IF EXISTS temp_deltriggers;

  CREATE TEMPORARY TABLE temp_deltriggers
  SELECT trigger_id
  FROM temp_deltriggers_before
  WHERE trigger_id NOT IN (SELECT trigger_id FROM emotion_triggers
                           WHERE ACTIVE = 1
						   AND UPDATED_BY = inp_user);
  
  DELETE FROM triggers
  WHERE id IN (SELECT trigger_id FROM temp_deltriggers)
  AND UPDATED_BY = inp_user
  AND ACTIVE = 1;
  SET tr_delRows = ROW_COUNT();

 COMMIT;
 
 SELECT eh_delRows, et_delRows, tr_delRows;

END$$

DELIMITER ;