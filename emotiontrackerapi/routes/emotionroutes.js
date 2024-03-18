const express = require("express");
const controller = require("../controllers/emotioncontroller");

const router = express.Router();

router.get("/emotionhistory", controller.getEmotionHist); // Get full history
router.get("/emotionhistory/:id", controller.getEmotionHistByID); // Get individual history by ID
router.get("/triggers/:id", controller.getTriggers); // Get current triggers
router.post("/emotionhistory/new", controller.postNewEmotionHist); // Add new emotion snapshot
router.put("/emotionhistory/:id", controller.updateEmotionHistByID); // Update existing emotion snapshot
router.delete("/emotionhistory", controller.deleteEmotionHistByID); // Delete emotion snapshot
router.post("/triggers/new", controller.postNewTrigger); // Add new trigger
router.delete("/triggers/:id", controller.deleteTrigger); // Delete existing trigger

module.exports = router;
