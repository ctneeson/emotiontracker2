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
  DROP TEMPORARY TABLE IF EXISTS temp_triggerids;
  
  CREATE TEMPORARY TABLE temp_triggerids
  SELECT DISTINCT et.trigger_id FROM emotion_triggers et
  WHERE et.ACTIVE = 1
  AND et.emotionhistory_id = inp_ehid
  AND et.trigger_id NOT IN (SELECT trigger_id FROM triggers
                            WHERE ACTIVE = 1
                            AND description IN (SELECT TRIM(j.name)
                                                FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist), ',', '","'), '$[*]' columns (name varchar(50) PATH '$') ) j
                                               )
                           );
  
  DELETE FROM emotion_triggers
  WHERE emotionhistory_id = inp_ehid
  AND ACTIVE = 1
  AND trigger_id IN (SELECT trigger_id FROM temp_triggerids);
  SET tr_affectedRows_del = ROW_COUNT();


  /* 3. Insert any new triggers for the selected emotionhistory record into the triggers & emotion_triggers tables */
  DROP TABLE IF EXISTS temp_triggers;
  
  -- Insert new descriptions into triggers table
  CREATE TABLE temp_triggers
  SELECT TRIM(j.name) AS description, inp_user AS UPDATED_BY
  FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist), ',', '","'), '$[*]' columns (name varchar(50) PATH '$') ) j
  WHERE TRIM(j.name) NOT IN (SELECT t.description FROM triggers t
                             JOIN emotion_triggers et
                              ON et.emotionhistory_id = inp_ehid
                             AND t.id = et.trigger_id
                             AND t.ACTIVE = 1
                             AND et.ACTIVE = 1);

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
  JOIN temp_triggers tt
   ON t.description = tt.description
  AND t.active = 1
  AND t.UPDATED_BY = inp_user;

  INSERT INTO emotion_triggers (emotionhistory_id, trigger_id, UPDATED_BY)
  SELECT emotionhistory_id, trigger_id, UPDATED_BY FROM temp_emotiontriggers;
					
 COMMIT;
 
 SELECT @eh_affectedRows, @tr_affectedRows_ins, @tr_affectedRows_del;

END$$

DELIMITER ;
