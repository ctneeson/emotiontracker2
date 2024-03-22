const express = require("express");
const controller = require("./../controllers/emotioncontrollers");
const router = express.Router();
const { isAuth } = require("./../middleware/auth");

/////////////////////////////////////
// EMOTIONHISTORY CALLS
/////////////////////////////////////
router.get("/new", isAuth, async (req, res) => {
  await controller.getTriggers(req, res);
});
router.get("/", isAuth, controller.getEmotionHist); // Get full history
router.get("/edit/:id", isAuth, controller.getEmotionHistByID); // Get individual snapshot
router.post("/new", isAuth, controller.postNewEmotionHist); // Post new snapshot
router.post("/edit/:id", isAuth, controller.updateEmotionHistByID); // Update existing snapshot
router.post("/del/:id", isAuth, controller.deleteEmotionHist); // Delete existing snapshot

/////////////////////////////////////
// LOGIN CALLS
/////////////////////////////////////
router.post("/login", controller.postLogin);
router.get("/login", controller.getLogin);
router.get("/logout", controller.getLogout);

module.exports = router;
