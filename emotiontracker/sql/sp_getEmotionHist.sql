DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getEmotionHist;

CREATE PROCEDURE IF NOT EXISTS sp_getEmotionHist(
	IN inp_userid INT,
	IN inp_role VARCHAR(100)
)
BEGIN

 SELECT
  eh.id,
  eh.level_anger,
  eh.level_contempt,
  eh.level_disgust,
  eh.level_enjoyment,
  eh.level_fear,
  eh.level_sadness,
  eh.level_surprise,
  GROUP_CONCAT(t.id ORDER BY t.id ASC SEPARATOR ",") AS triggerIDs,
  GROUP_CONCAT(t.description ORDER BY t.id ASC SEPARATOR ",") AS triggers,
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
 WHERE ( (inp_role = 'user' AND eh.UPDATED_BY = (SELECT name FROM emotiontracker_users WHERE id = inp_userid) )
         OR (inp_role = 'administrator') )
 GROUP BY eh.id;

END$$

DELIMITER ;