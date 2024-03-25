### USERS ###
#CALL sp_getUsers(1, 'administrator', @ERR_MESSAGE, @ERR_IND);
#CALL sp_postNewUser('jakeblues', 'Jake', 'Blues', 'jake@blues.com', 'chicago123', 2, @ins_rows, @ERR_MESSAGE, @ERR_IND);
#CALL sp_updateUser(4, 'jakeblues', 'Jake', 'Blues', 'jake@blues.net', 'chicago123', 'user', @upd_affectedRows, @ERR_MESSAGE, @ERR_IND);
#CALL sp_deleteUser('jakeblues', @u_delRows, @ua_delRows, @eh_delRows, @et_delRows, @tr_delRows, @ERR_MESSAGE, @ERR_IND);

### TRIGGERS ###
#CALL sp_getTriggers(2, @ERR_MESSAGE, @ERR_IND);

### EMOTIONHISTORY ###
#CALL sp_getEmotionHist(4, 'user', @ERR_MESSAGE, @ERR_IND);
#CALL sp_getEmotionHistByID(2, @ERR_MESSAGE, @ERR_IND);
#CALL sp_postNewEmotionHist(7, 7, 7, 7, 7, 7, 7, 'Notes - Seven', 'Work Stress,Seven', '2024-02-03 02:49', 'jakeblues', @eh_affectedRows, @tr_affectedRows, @ERR_MESSAGE, @ERR_IND);
#CALL sp_deleteEmotionHistByID(1, 'user', @eh_delRows, @et_delRows, @tr_delRows, @ERR_MESSAGE, @ERR_IND);
#CALL sp_updateEmotionHistByID(5, 5, 5, 5, 5, 5, 5, 5, '', 'Five,Six', '2024-03-18T19:58', 'user', @eh_affectedRows, @et_affectedRows_ins, @et_affectedRows_del, @tr_affectedRows_ins, @tr_affectedRows_del, @ERR_MESSAGE, @ERR_IND);
#CALL sp_getUserPostLogin('user', 'user123', @ERR_MESSAGE, @ERR_IND);
#CALL sp_getEmotionHist(5, 'administrator', @ERR_MESSAGE, @ERR_IND);
