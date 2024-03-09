const express = require("express");
const controller = require("./../controllers/emotioncontrollers");
const router = express.Router();

/////////////////////////////////////
// EMOTIONHISTORY CALLS
/////////////////////////////////////
router.get("/new", async (req, res) => {
  await controller.getTriggers(req, res);
});
router.get("/", controller.getEmotionHist); // Get full history
router.get("/edit/:id", controller.getEmotionHistByID); // Get individual snapshot
router.post("/new", controller.postNewEmotionHist); // Post new snapshot
router.post("/edit/:id", controller.updateEmotionHistByID); // Update existing snapshot
router.post("/del/:id", controller.deleteEmotionHist); // Delte existing snapshot

/////////////////////////////////////
// TRIGGER CALLS
/////////////////////////////////////
router.post("/triggers/new", controller.postNewTrigger); // Post new trigger
router.post("/triggers/del/:id", controller.deleteTrigger); // Delete trigger

/////////////////////////////////////
// LOGIN CALLS
/////////////////////////////////////
router.post("/login", controller.postLogin);
router.get("/login", controller.getLogin);
router.get("/logout", controller.getLogout);

/////////////////////////////////////
// USER CALLS:                     //
// GET ACCOUNT DETAILS - getUsers  //
// CREATE ACCOUNT - postNewUser    //
// UPDATE ACCOUNT - putUserDetails //
// DELETE ACCOUNT - deleteUser     //
/////////////////////////////////////
router.get("/createaccount", (req, res) => {
  res.render("createaccount");
});
router.get("/accountadmin", controller.getUsers);
router.post("/useradmin/users/new", controller.postNewUser);
router.put("/useradmin/users/:id", controller.putUserDetails);
router.delete("/useradmin/users/:id", controller.deleteUser);

module.exports = router;
