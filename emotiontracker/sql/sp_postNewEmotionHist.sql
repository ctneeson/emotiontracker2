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
   IN inp_user VARCHAR(100)
)
BEGIN

 START TRANSACTION;

 INSERT INTO emotionhistory (level_anger, level_contempt, level_disgust, level_enjoyment, level_fear, level_sadness, level_surprise, notes, UPDATED_BY)
 VALUES (inp_anger, inp_contempt, inp_disgust, inp_enjoyment, inp_fear, inp_sadness, inp_surprise, inp_notes, inp_user);
					 
 COMMIT;

 START TRANSACTION;
 
 DROP TEMPORARY TABLE IF EXISTS temp_triggers;
 CREATE TEMPORARY TABLE temp_triggers
 SELECT DISTINCT description FROM triggers WHERE ACTIVE = 1;


 INSERT INTO triggers (description, UPDATED_BY)
 VALUES ( (SELECT TRIM(j.name) FROM JSON_TABLE( replace(JSON_ARRAY(inp_triggerlist),',','","'), '$[*]' columns (name varchar(50) PATH '$')) j
           WHERE TRIM(j.name) NOT IN (SELECT description FROM temp_triggers)),
          inp_user );

 COMMIT;

 START TRANSACTION;
 
 DROP TEMPORARY TABLE IF EXISTS temp_emotiontriggers;

 CREATE TEMPORARY TABLE temp_emotiontriggers
 SELECT
  eh.id AS emotionhistory_id,
  trig.id AS trigger_id,
  'admin' AS UPDATED_BY
 FROM (SELECT MAX(id) AS id FROM emotionhistory WHERE ACTIVE = 1 AND UPDATED_BY = inp_user) eh
 LEFT JOIN (SELECT t.id
            FROM JSON_TABLE(replace(JSON_ARRAY(inp_triggerlist),',','","'), '$[*]' columns (name varchar(50) PATH '$')) j
            JOIN triggers t
            ON TRIM(j.name) = t.description
            AND t.ACTIVE = 1) AS trig
  ON 1=1;

 COMMIT;

 START TRANSACTION;
 
 INSERT INTO emotion_triggers (emotionhistory_id, trigger_id, UPDATED_BY)
 SELECT emotionhistory_id, trigger_id, UPDATED_BY FROM temp_emotiontriggers;

 COMMIT;

END$$

DELIMITER ;



/*
CALL sp_postNewEmotionHist(
   7,
   7,
   7,
   7,
   7,
   7,
   7,
   'NotesNotesNotes',
   'Work Stress, New Trigger',
   'admin'
);
*/