DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getEmotionHistByID;

CREATE PROCEDURE IF NOT EXISTS sp_getEmotionHistByID(
   IN inp_id INT,
   OUT ERR_MESSAGE VARCHAR(500),
   OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_id IS NULL) THEN
     SET ERR_MESSAGE = 'Invalid input(s). Snapshot ID must not be null.', ERR_IND = 1;
 ELSEIF (SELECT COUNT(id) FROM emotionhistory WHERE id = inp_id) = 0 THEN
     SET ERR_MESSAGE = 'Invalid snapshot ID.', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 SELECT
  eh.id,
  eh.level_anger,
  eh.level_contempt,
  eh.level_disgust,
  eh.level_enjoyment,
  eh.level_fear,
  eh.level_sadness,
  eh.level_surprise,
  GROUP_CONCAT(t.id ORDER BY t.id ASC SEPARATOR ", ") AS triggerIDs,
  GROUP_CONCAT(t.description ORDER BY t.id ASC SEPARATOR ", ") AS triggers,
  t2.all_triggers,
  eh.notes,
  eh.ACTIVE,
  eh.INSERT_DATE,
  eh.UPDATE_DATE,
  eh.UPDATED_BY
 FROM emotionhistory eh
 LEFT JOIN emotion_triggers et
  ON et.emotionhistory_id = eh.id
  AND eh.ACTIVE = 1
  AND et.ACTIVE = 1
 LEFT JOIN triggers t
  ON et.trigger_id = t.id
  AND t.ACTIVE = 1
  AND et.ACTIVE = 1
 LEFT JOIN (SELECT
             GROUP_CONCAT(DISTINCT DESCRIPTION ORDER BY id ASC SEPARATOR ",") AS all_triggers,
             UPDATED_BY
            FROM triggers
            WHERE ACTIVE = 1
			GROUP BY UPDATED_BY) t2
  ON eh.UPDATED_BY = t2.UPDATED_BY
  AND eh.ACTIVE = 1
 WHERE eh.id = inp_id
 GROUP BY eh.id;

END$$

DELIMITER ;