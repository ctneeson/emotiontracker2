const express = require("express");
const userController = require("./../controllers/usercontrollers");
const userRouter = express.Router();
const { isAuth } = require("./../middleware/auth");

/////////////////////////////////////
// USER CALLS:                     //
// GET ACCOUNT DETAILS - getUsers  //
// CREATE ACCOUNT - postNewUser    //
// UPDATE ACCOUNT - putUserDetails //
// DELETE ACCOUNT - deleteUser     //
/////////////////////////////////////
userRouter.get("/createaccount", (req, res) => {
  res.render("createaccount");
});
userRouter.get("/accountadmin", isAuth, async (req, res) => {
  await userController.getUsers(req, res, { userName: req.session.userName });
});
userRouter.post("/users/new", userController.postNewUser);
userRouter.put("/users/:id", isAuth, userController.putUserDetails);
userRouter.post("/users/:name", isAuth, userController.deleteUser);

module.exports = userRouter;
