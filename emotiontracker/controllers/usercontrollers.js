const axios = require("axios");

/////////////////////////////////////
// USER CALLS:                     //
// GET ACCOUNT DETAILS - getUsers  //
// CREATE ACCOUNT - postNewUser    //
// UPDATE ACCOUNT - putUserDetails //
// DELETE ACCOUNT - deleteUser     //
/////////////////////////////////////
exports.getUsers = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const endpoint = `http://localhost:3002/useradmin/accountadmin/?id=${userid}&role=${role}`;
    console.log(`Logged in. Method: getUsers | Calling endpoint: ${endpoint}`);

    await axios
      .get(endpoint)
      .then((response) => {
        const data = response.data.result;
        console.log(data[0]);
        res.render("accountadmin", {
          details: data[0],
          loggedin: isloggedin,
          role,
        });
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

exports.postNewUser = async (req, res) => {
  const user_details = {
    user_details: {
      inp_name: req.body.inp_name.trim(),
      inp_firstname: req.body.inp_firstname.trim(),
      inp_lastname: req.body.inp_lastname.trim(),
      inp_email: req.body.inp_email.trim(),
      inp_password: req.body.inp_password.trim(),
      inp_typeid: 2,
    },
  };
  const endpoint = `http://localhost:3002/useradmin/users/new`;
  console.log(`Method: postNewUser | Calling endpoint: ${endpoint}`);
  console.log(`Parameters: user_details: ${user_details}`);
  await axios
    .post(endpoint, user_details)
    .then((response) => {
      const data = response.data;
      console.log(data);
      res.render("login", {
        popupMessage: data["message"],
      });
    })
    .catch((error) => {
      console.log(`Error making API request: ${error}`);
      res.status(500).json({ error: "Internal Server Error" });
    });
};

exports.putUserDetails = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);
  const selectedUserId = req.params.id;

  if (isloggedin) {
    const user_details = {
      user_details: {
        inp_id: parseInt(req.body.inp_id),
        inp_name: req.body.inp_name.trim(),
        inp_firstname: req.body.inp_firstname.trim(),
        inp_lastname: req.body.inp_lastname.trim(),
        inp_email: req.body.inp_email.trim(),
        inp_password: req.body.inp_password.trim(),
        inp_role: req.body.inp_role,
      },
    };
    console.log("req.body:", req.body);
    const endpoint = `http://localhost:3002/useradmin/users/${selectedUserId}`;
    console.log(`Method: putUserDetails | Calling endpoint: ${endpoint}`);
    console.log(`Parameters: selectedUserId: ${selectedUserId}`);
    console.log(`Parameters: user_details: ${user_details}`);
    await axios
      .put(endpoint, user_details)
      .then((response) => {
        const data = response.data;
        console.log(data);
        res.json({
          redirectURL: `http://localhost:3000/useradmin/accountadmin?status=${
            data.status
          }&message=${encodeURIComponent(data.message)}`,
        });
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

exports.deleteUser = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);
  const username = req.params.name;

  if (isloggedin) {
    const endpoint = `http://localhost:3002/useradmin/users/${username}`;
    console.log(`Method: deleteUser | Calling endpoint: ${endpoint}`);

    await axios
      .post(endpoint)
      .then((response) => {
        const data = response.data;
        console.log(data);
        res.json({
          status: response.data.status,
          message: response.data.message,
        });
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
        res.json({
          status: "error",
          message: `Error making API request: ${error}`,
        });
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};
