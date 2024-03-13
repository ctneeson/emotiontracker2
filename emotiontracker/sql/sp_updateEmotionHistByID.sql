DELIMITER $$

DROP PROCEDURE IF EXISTS sp_updateEmotionHistByID;

CREATE PROCEDURE IF NOT EXISTS sp_updateEmotionHistByID(
   IN inp_ehid INT,
   IN inp_anger INT,
   IN inp_contempt INT,
   IN inp_disgust INT,
   IN inp_enjoyment INT,
   IN inp_fear INT,
   IN inp_sadness INT,
   IN inp_surprise INT,
   IN inp_notes VARCHAR(500),
   IN inp_triggerlist VARCHAR(500),
   IN inp_snapshotdate DATETIME,
   IN inp_user VARCHAR(100),
   OUT eh_affectedRows INT,
   OUT tr_affectedRows_ins INT,
   OUT tr_affectedRows_del INT
)
BEGIN

 START TRANSACTION;

  /* 1. Update emotionhistory table first */
  UPDATE emotionhistory
  SET level_anger     = inp_anger,
      level_contempt  = inp_contempt,
 	  level_disgust   = inp_disgust,
 	  level_enjoyment = inp_enjoyment,
 	  level_fear      = inp_fear,
 	  level_sadness   = inp_sadness,
 	  level_surprise  = inp_surprise,
 	  notes           = inp_notes,
	  INSERT_DATE     = inp_snapshotdate,
	  UPDATE_DATE     = NOW(),
 	  UPDATED_BY      = inp_user
  WHERE id = inp_ehid;
  SET eh_affectedRows = ROW_COUNT();

  /* 2. After updating emotionhistory, delete any existing triggers that no longer apply from emotion_triggers table */
  
  -- Get the trigger ID from emotion_triggers for any 
  DROP TEMPORARY TABLE IF EXISTS temp_triggerids;
  
  CREATE TEMPORARY TABLE temp_triggerids
  -- Get trigger IDs for any triggers currently attached to the snapshot ID (inp_ehid)
  -- which aren't in the list of triggers (@inp_triggerlist) that we're updating the snapshot with
  -- Any triggers previously added whihc are no longer present will be deleted
  SELECT DISTINCT et.trigger_id FROM emotion_triggers et
  WHERE et.ACTIVE = 1
  AND et.emotionhistory_id = inp_ehid
  AND et.trigger_id NOT IN
   -- trigger IDs for already-present triggers in the list of values from @inp_triggerlist
   (SELECT id FROM triggers
    WHERE ACTIVE = 1
    AND description IN (SELECT TRIM(j.name)
                        FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist), ',', '","'), '$[*]' columns (name varchar(50) PATH '$') ) j
                       )
   );
  
  -- Delete any links to triggers that are no longer applicable to the snapshot being updated
  DELETE FROM emotion_triggers
  WHERE emotionhistory_id = inp_ehid
  AND ACTIVE = 1
  AND trigger_id IN (SELECT trigger_id FROM temp_triggerids);
  SET tr_affectedRows_del = ROW_COUNT();
  
  -- Delete any triggers that are no longer attached to a snapshot that belongs to the user in question
  DELETE FROM triggers
  WHERE UPDATED_BY = inp_user
  AND ACTIVE = 1
  AND id NOT IN (SELECT trigger_id FROM emotion_triggers
                 WHERE UPDATED_BY = inp_user
				 AND ACTIVE = 1);

  /* 3. Insert any new triggers for the selected emotionhistory record into the triggers & emotion_triggers tables */
  DROP TABLE IF EXISTS temp_triggers;
  
  -- Insert any new triggers in the input list (inp_triggerlist) that haven't already
  -- been inserted in the triggers table by the existing user (UPDATED_BY = inp_user)
  CREATE TABLE temp_triggers
  SELECT TRIM(j.name) AS description, inp_user AS UPDATED_BY
  FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist), ',', '","'), '$[*]' columns (name varchar(50) PATH '$') ) j
  WHERE TRIM(j.name) NOT IN (SELECT description FROM triggers
                             WHERE ACTIVE = 1 AND UPDATED_BY = inp_user);

  INSERT INTO triggers (description, UPDATED_BY)
  SELECT description, UPDATED_BY
  FROM temp_triggers;
  SET tr_affectedRows_ins = ROW_COUNT();
  
  -- Insert new trigger IDs into emotion_triggers table
  DROP TEMPORARY TABLE IF EXISTS temp_emotiontriggers;
  
  CREATE TEMPORARY TABLE temp_emotiontriggers
  SELECT
   inp_ehid AS emotionhistory_id,
   t.id AS trigger_id,
   inp_user AS UPDATED_BY
  FROM triggers t
  JOIN ( SELECT TRIM(j.name) AS name
         FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist), ',', '","'), '$[*]' columns (name varchar(50) PATH '$') ) j) tt
   ON t.description = tt.name
  AND t.active = 1
  AND t.UPDATED_BY = inp_user;

  INSERT INTO emotion_triggers (emotionhistory_id, trigger_id, UPDATED_BY)
  SELECT emotionhistory_id, trigger_id, UPDATED_BY FROM temp_emotiontriggers
  WHERE trigger_id NOT IN (SELECT trigger_id FROM emotion_triggers
                           WHERE emotionhistory_id = inp_ehid
						   AND UPDATED_BY = inp_user
						   AND ACTIVE = 1);
					
 COMMIT;
 
 SELECT @eh_affectedRows, @tr_affectedRows_ins, @tr_affectedRows_del;

END$$

DELIMITER ;
