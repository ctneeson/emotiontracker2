const express = require("express");
const controller = require("./../controllers/emotioncontrollers");
const router = express.Router();

router.get("/", controller.getEmotionHist); // Get full history

router.get("/new", async (req, res) => {
  await controller.getTriggers(req, res);
});
router.get("/createaccount", (req, res) => {
  res.render("createaccount");
});
router.get("/edit/:id", controller.getEmotionHistByID); // Get individual snapshot
router.get("/login", controller.getLogin);
router.get("/logout", controller.getLogout);
router.get("/accountadmin", controller.getUsers);

router.post("/new", controller.postNewEmotionHist); // Post new snapshot
router.post("/edit/:id", controller.updateEmotionHistByID); // Update existing snapshot
router.post("/del/:id", controller.deleteEmotionHist); // Delte existing snapshot
router.post("/triggers/new", controller.postNewTrigger); // Post new trigger
router.post("/triggers/del/:id", controller.deleteTrigger); // Delete trigger
router.post("/login", controller.postLogin);
router.post("/useradmin/users/new", controller.postNewUser);

module.exports = router;
