DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getTriggers;

CREATE PROCEDURE IF NOT EXISTS sp_getTriggers(
   IN inp_userid INT
)
BEGIN

 SELECT GROUP_CONCAT(t.description ORDER BY t.id ASC SEPARATOR ",") AS triggerList
 FROM triggers t
 JOIN emotiontracker_users u
  ON u.id = inp_userid
  AND t.ACTIVE = 1
  AND t.UPDATED_BY = u.name;

END$$

DELIMITER ;