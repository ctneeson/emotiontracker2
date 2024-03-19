const express = require("express");
const controller = require("../controllers/emotioncontroller");

const router = express.Router();

router.get("/emotionhistory", controller.getEmotionHist);
router.get("/emotionhistory/:id", controller.getEmotionHistByID);
router.get("/triggers/:id", controller.getTriggers);

router.post("/emotionhistory/new", controller.postNewEmotionHist);
router.put("/emotionhistory/:id", controller.updateEmotionHistByID);
router.delete("/emotionhistory", controller.deleteEmotionHistByID);

module.exports = router;
