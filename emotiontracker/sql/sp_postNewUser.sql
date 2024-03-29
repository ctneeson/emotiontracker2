DELIMITER $$

DROP PROCEDURE IF EXISTS sp_postNewUser;

CREATE PROCEDURE IF NOT EXISTS sp_postNewUser(
   IN inp_name VARCHAR(250),
   IN inp_firstname VARCHAR(100),
   IN inp_lastname VARCHAR(100),
   IN inp_email VARCHAR(250),
   IN inp_password VARCHAR(50),
   IN inp_typeid INT,
   OUT ins_rows INT,
   OUT ERR_MESSAGE VARCHAR(500),
   OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_name IS NULL
     OR inp_email IS NULL
	 OR inp_password IS NULL
	) THEN
     SET ERR_MESSAGE = 'Invalid input(s). Username, Email and Password must not be null.', ERR_IND = 1;
 ELSEIF (inp_typeid IS NOT NULL AND (SELECT COUNT(type_id) FROM emotiontracker_userstypes WHERE type_id = inp_typeid) = 0) THEN
     SET ERR_MESSAGE = 'Invalid role type provided', ERR_IND = 1;
 ELSEIF (SELECT CASE WHEN inp_email NOT REGEXP "^[a-zA-Z0-9][a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]*?[a-zA-Z0-9._-]?@[a-zA-Z0-9][a-zA-Z0-9._-]*?[a-zA-Z0-9]?\\.[a-zA-Z]{2,63}$" THEN 0 ELSE 1 END) = 0 THEN
     SET ERR_MESSAGE = 'Invalid email address provided. Email syntax is not correct.', ERR_IND = 1;
 ELSEIF (LENGTH(inp_password) < 3 OR LENGTH(inp_password) > 50) THEN
     SET ERR_MESSAGE = 'Invalid password length.', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 START TRANSACTION;
 
 DROP TEMPORARY TABLE IF EXISTS temp_userenc;

 CREATE TEMPORARY TABLE temp_userenc
 SELECT inp_name AS name, LEFT(UUID(),8) AS salt, LEFT(UUID(),50) AS aes_key;
 
 INSERT INTO emotiontracker_users (name, firstname, lastname, email, password, type_id)
 SELECT inp_name,
        inp_firstname,
		inp_lastname,
		inp_email,
        AES_ENCRYPT(CONCAT(inp_name, inp_password, ue.salt), ue.aes_key),
		inp_typeid
 FROM temp_userenc ue;
 SELECT ROW_COUNT() AS ins_rows;

 -- Create salt for new user and update password to encrypt it
 INSERT INTO `emotiontracker_userauth`
 SELECT u.id, ue.salt, ue.aes_key
 FROM emotiontracker_users u
 JOIN temp_userenc ue
  ON u.name = ue.name
 WHERE u.name = inp_name;
 
 DROP TEMPORARY TABLE IF EXISTS temp_userenc;

 COMMIT;
 
END$$

DELIMITER ;