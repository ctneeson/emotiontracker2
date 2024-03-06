DELIMITER $$

DROP PROCEDURE IF EXISTS sp_getUserDetails;

CREATE PROCEDURE IF NOT EXISTS sp_getUserDetails(
   IN inp_id INT
)
BEGIN

 /*- Add emotion levels & notes to emotionhistory table -*/
 SELECT u.name, ut.role
 FROM emotiontracker_users u
 INNER JOIN emotiontracker_userstypes ut
  ON u.type_id = ut.type_id
  AND u.id = inp_id;

END$$

DELIMITER ;