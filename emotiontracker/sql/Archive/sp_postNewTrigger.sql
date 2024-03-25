DELIMITER $$

DROP PROCEDURE IF EXISTS sp_postNewTrigger;

CREATE PROCEDURE IF NOT EXISTS sp_postNewTrigger(
   IN inp_triggerlist VARCHAR(500)
)
BEGIN

 START TRANSACTION;


 COMMIT;

END$$

DELIMITER ;



/*
CALL sp_postNewTrigger('Moving House');
*/