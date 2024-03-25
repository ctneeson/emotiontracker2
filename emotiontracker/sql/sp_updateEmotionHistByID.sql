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
   OUT et_affectedRows_ins INT,
   OUT et_affectedRows_del INT,
   OUT tr_affectedRows_ins INT,
   OUT tr_affectedRows_del INT,
   OUT ERR_MESSAGE VARCHAR(500),
   OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_ehid IS NULL
     OR inp_anger IS NULL
     OR inp_contempt IS NULL
     OR inp_disgust IS NULL
     OR inp_enjoyment IS NULL
     OR inp_fear IS NULL
     OR inp_sadness IS NULL
     OR inp_surprise IS NULL
     OR inp_snapshotdate IS NULL
     OR inp_user IS NULL
	) THEN
     SET ERR_MESSAGE = 'Invalid input provided: emotion levels, snapshot date and user must not be null.', ERR_IND = 1;
 ELSEIF (SELECT COUNT(id) FROM emotionhistory WHERE id = inp_ehid) = 0 THEN
     SET ERR_MESSAGE = 'Invalid snapshot ID provided', ERR_IND = 1;
 ELSEIF (inp_user NOT IN (SELECT name FROM emotiontracker_users)) THEN
     SET ERR_MESSAGE = 'Invalid user name provided.', ERR_IND = 1;
 ELSEIF (inp_snapshotdate > NOW()) THEN
     SET ERR_MESSAGE = 'Invalid snapshot date: cannot be in the future', ERR_IND = 1;
 ELSEIF (inp_anger        < 0 OR inp_anger     > 10
         OR inp_contempt  < 0 OR inp_contempt  > 10
         OR inp_disgust   < 0 OR inp_disgust   > 10
         OR inp_enjoyment < 0 OR inp_enjoyment > 10
         OR inp_fear      < 0 OR inp_fear      > 10
         OR inp_sadness   < 0 OR inp_sadness   > 10
         OR inp_surprise  < 0 OR inp_surprise  > 10
		 ) THEN
     SET ERR_MESSAGE = 'Invalid snapshot value(s).', ERR_IND = 1;
 ELSEIF (inp_anger = (SELECT level_anger FROM emotionhistory WHERE id = inp_ehid)
         AND inp_anger        = (SELECT level_anger     FROM emotionhistory WHERE id = inp_ehid)
         AND inp_contempt     = (SELECT level_contempt  FROM emotionhistory WHERE id = inp_ehid)
         AND inp_disgust      = (SELECT level_disgust   FROM emotionhistory WHERE id = inp_ehid)
         AND inp_enjoyment    = (SELECT level_enjoyment FROM emotionhistory WHERE id = inp_ehid)
         AND inp_fear         = (SELECT level_fear      FROM emotionhistory WHERE id = inp_ehid)
         AND inp_sadness      = (SELECT level_sadness   FROM emotionhistory WHERE id = inp_ehid)
         AND inp_surprise     = (SELECT level_surprise  FROM emotionhistory WHERE id = inp_ehid)
         AND inp_snapshotdate = (SELECT INSERT_DATE     FROM emotionhistory WHERE id = inp_ehid)
         AND TRIM(inp_notes)  = (SELECT TRIM(notes)     FROM emotionhistory WHERE id = inp_ehid)
		 AND (SELECT GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ",")
              FROM (SELECT TRIM(j.name) AS name
                    FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist), ',', '","'), '$[*]'
                                     columns (name varchar(50) PATH '$') ) j
                   ) a)
             = (SELECT GROUP_CONCAT(DISTINCT t.description ORDER BY t.description ASC SEPARATOR ",")
                FROM triggers t
                JOIN emotion_triggers et
                ON et.emotionhistory_id = inp_ehid
                AND t.id = et.trigger_id
                AND t.UPDATED_BY = inp_user
                AND t.ACTIVE = 1
                AND et.ACTIVE = 1)
		) THEN
     SET ERR_MESSAGE = 'Update snapshot rejected. No changes exist in the input values.', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

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
  SET et_affectedRows_del = ROW_COUNT();
  
  -- Delete any triggers that are no longer attached to a snapshot that belongs to the user in question
  DELETE FROM triggers
  WHERE UPDATED_BY = inp_user
  AND ACTIVE = 1
  AND id NOT IN (SELECT trigger_id FROM emotion_triggers
                 WHERE UPDATED_BY = inp_user
				 AND ACTIVE = 1);
  SET tr_affectedRows_del = ROW_COUNT();

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
  SET et_affectedRows_ins = ROW_COUNT();

 SELECT eh_affectedRows, et_affectedRows_del, et_affectedRows_ins, tr_affectedRows_del, tr_affectedRows_ins;

 COMMIT;
 
END$$

DELIMITER ;
