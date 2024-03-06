const express = require("express");
const controller = require("../controllers/usercontroller");

const router = express.Router();

router.get("/users/:id", controller.getUserDetails);
router.post("/users/", controller.postLogin);
router.post("/users/new", controller.postNewUser); // Add new user account

module.exports = router;
