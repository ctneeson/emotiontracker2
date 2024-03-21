DELIMITER $$

DROP PROCEDURE IF EXISTS sp_updateUser;

CREATE PROCEDURE IF NOT EXISTS sp_updateUser(
   IN inp_id INT,
   IN inp_name VARCHAR(250),
   IN inp_firstname VARCHAR(100),
   IN inp_lastname VARCHAR(100),
   IN inp_email VARCHAR(250),
   IN inp_password VARCHAR(50),
   IN inp_role VARCHAR(100),
   OUT upd_affectedRows INT,
   OUT ERR_MESSAGE VARCHAR(500),
   OUT ERR_IND BIT
)
BEGIN

 DECLARE exit_handler CONDITION FOR SQLSTATE '45000';
 SET ERR_IND = 0;
 IF (inp_id IS NULL
     OR inp_name IS NULL
     OR inp_email IS NULL
     OR inp_password IS NULL
     OR inp_role IS NULL
	) THEN
     SET ERR_MESSAGE = 'Invalid input provided: Username, email address, password and role must not be null.', ERR_IND = 1;
 ELSEIF (inp_id NOT IN (SELECT id FROM emotiontracker_users)) THEN
     SET ERR_MESSAGE = 'Invalid User ID provided', ERR_IND = 1;
 ELSEIF (inp_role NOT IN (SELECT role FROM emotiontracker_userstypes)) THEN
     SET ERR_MESSAGE = 'Invalid role provided', ERR_IND = 1;
 ELSEIF (LENGTH(inp_password) < 3 OR LENGTH(inp_password) > 50) THEN
     SET ERR_MESSAGE = 'Invalid password length.', ERR_IND = 1;
 ELSEIF (SELECT CASE WHEN inp_email NOT REGEXP "^[a-zA-Z0-9][a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]*?[a-zA-Z0-9._-]?@[a-zA-Z0-9][a-zA-Z0-9._-]*?[a-zA-Z0-9]?\\.[a-zA-Z]{2,63}$" THEN 0 ELSE 1 END) = 0 THEN
     SET ERR_MESSAGE = 'Invalid email address provided. Email syntax is not correct.', ERR_IND = 1;
 ELSEIF (inp_name = (SELECT name FROM emotiontracker_users WHERE id = inp_id)
         AND inp_firstname = (SELECT firstname FROM emotiontracker_users WHERE id = inp_id)
         AND inp_lastname = (SELECT lastname FROM emotiontracker_users WHERE id = inp_id)
         AND AES_ENCRYPT(CONCAT(inp_name, inp_password, (SELECT salt FROM emotiontracker_userauth WHERE id = inp_id)),
                         (SELECT aes_key FROM emotiontracker_userauth WHERE id = inp_id))
			 = (SELECT password FROM emotiontracker_users WHERE id = inp_id)
         AND inp_role = (SELECT ut.role
		                 FROM emotiontracker_userstypes ut
						 JOIN emotiontracker_users u
						 ON ut.type_id = u.type_id
						 AND u.id = inp_id)
        ) THEN
     SET ERR_MESSAGE = 'Update rejected. No input details have changed.', ERR_IND = 1;
 END IF;
 
 IF ERR_IND = 1 THEN
    SIGNAL exit_handler SET MESSAGE_TEXT = ERR_MESSAGE;
 END IF;

 START TRANSACTION;
 
 UPDATE emotiontracker_users
 SET
  name = inp_name,
  firstname = inp_firstname,
  lastname = inp_lastname,
  email = inp_email,
  password = AES_ENCRYPT(CONCAT(inp_name, inp_password, (SELECT salt FROM emotiontracker_userauth WHERE id = inp_id)),
                         (SELECT aes_key FROM emotiontracker_userauth WHERE id = inp_id)),
  type_id = (SELECT type_id FROM emotiontracker_userstypes WHERE role = inp_role)
 WHERE id = inp_id;
 SELECT ROW_COUNT() AS upd_affectedRows;

 COMMIT;
 
END$$

DELIMITER ;