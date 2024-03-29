const express = require("express");
const controller = require("../controllers/usercontroller");

const router = express.Router();

router.get("/users/:id", controller.getUserDetails);
router.get("/accountadmin", controller.getUsers);
router.post("/users/", controller.postLogin);
router.post("/users/new", controller.postNewUser);
router.put("/users/:id", controller.putUserDetails);
router.post("/users/:name", controller.deleteUser);

module.exports = router;
