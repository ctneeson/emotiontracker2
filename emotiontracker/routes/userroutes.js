const express = require("express");
const userController = require("./../controllers/usercontrollers");
const userRouter = express.Router();

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
userRouter.get("/accountadmin", async (req, res) => {
  await userController.getUsers(req, res);
});
//userRouter.get("/useradmin/accountadmin", userController.getUsers);
//userRouter.get("/useradmin/users", userController.getUsers);
userRouter.post("/useradmin/users/new", userController.postNewUser);
userRouter.put("/users/:id", userController.putUserDetails);
userRouter.delete("/useradmin/users/:id", userController.deleteUser);

module.exports = userRouter;
