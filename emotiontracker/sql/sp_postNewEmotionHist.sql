DELIMITER $$

DROP PROCEDURE IF EXISTS sp_postNewEmotionHist;

CREATE PROCEDURE IF NOT EXISTS sp_postNewEmotionHist(
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
   OUT tr_affectedRows INT
)
BEGIN

 START TRANSACTION;
 
 /*- Add emotion levels & notes to emotionhistory table -*/
 INSERT INTO emotionhistory (level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, INSERT_DATE, UPDATED_BY)
 VALUES (inp_anger, inp_contempt, inp_disgust, inp_enjoyment, inp_fear, inp_sadness, inp_surprise, inp_notes, inp_snapshotdate, inp_user);
 SET eh_affectedRows = ROW_COUNT();

 /*- Get list of existing triggers for current user -*/
 DROP TEMPORARY TABLE IF EXISTS temp_triggers;
 CREATE TEMPORARY TABLE temp_triggers
 SELECT DISTINCT description FROM triggers WHERE ACTIVE = 1 AND UPDATED_BY = inp_user;

 /*- Add any new triggers for current user -*/
 INSERT INTO triggers (description, UPDATED_BY)
 SELECT TRIM(j.name), u.UPDATED_BY
 FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist),',','","'), '$[*]' columns (name varchar(50) PATH '$')) j
 JOIN (SELECT inp_user AS UPDATED_BY) u ON 1=1
 WHERE TRIM(j.name) NOT IN (SELECT description FROM temp_triggers);
 SET tr_affectedRows = ROW_COUNT();

 /*- Update emotion_triggers link table -*/
 /*- 1. Get the most recent entry in emotionhistory for the current user: MAX(id) -*/
 /*- 2. Join this to the list of ids from the 'triggers' table for triggers being added in the current snapshot -*/
 /*- 3. Insert the emotionhistory.[id] joined with the list of trigger.[id]'s into the emotion_triggers table -*/
 DROP TEMPORARY TABLE IF EXISTS temp_emotiontriggers;

 CREATE TEMPORARY TABLE temp_emotiontriggers
 SELECT
  eh.id AS emotionhistory_id,
  trig.id AS trigger_id,
  inp_user AS UPDATED_BY
 FROM (SELECT MAX(id) AS id FROM emotionhistory WHERE ACTIVE = 1 AND UPDATED_BY = inp_user) eh
 LEFT JOIN (SELECT t.id
            FROM JSON_TABLE(replace(JSON_ARRAY(inp_triggerlist),',','","'), '$[*]' columns (name varchar(50) PATH '$')) j
            JOIN triggers t
            ON TRIM(j.name) = t.description
            AND t.ACTIVE = 1
				AND t.UPDATED_BY = inp_user) AS trig
  ON 1=1;

 INSERT INTO emotion_triggers (emotionhistory_id, trigger_id, UPDATED_BY)
 SELECT emotionhistory_id, trigger_id, UPDATED_BY FROM temp_emotiontriggers;

 COMMIT;
 
 SELECT eh_affectedRows, tr_affectedRows;

END$$

DELIMITER ;