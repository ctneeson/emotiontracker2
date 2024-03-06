//const conn = require("./../utils/dbconn");
const axios = require("axios");

// SELECT ALL EMOTIONHISTORY SNAPSHOTS
exports.getEmotionHist = async (req, res) => {
  var userinfo = {};
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const endpoint = `http://localhost:3002/useradmin/users/${userid}`;
    console.log(
      `Logged in. Method: getEmotionHist | Calling endpoint: ${endpoint}`
    );
    await axios
      .get(endpoint)
      .then((response) => {
        const data = response.data.result;
        console.log(data);
        const username = data[0].name;
        const userrole = data[0].role;
        const session = req.session;
        session.name = username;
        session.role = userrole;
        console.log(session);
        userinfo = { name: username, role: userrole };
        console.log(userinfo);
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  }

  const endpoint = `http://localhost:3002/emotionhistory`;
  console.log(`Method: getEmotionHist | Calling endpoint: ${endpoint}`);
  await axios
    .get(endpoint)
    .then((response) => {
      const data = response.data.result;
      console.log(data[0]);
      res.render("index", {
        snapshot: data[0],
        loggedin: isloggedin,
        user: userinfo,
      });
    })
    .catch((error) => {
      console.log(`Error making API request: ${error}`);
    });
};

/*exports.getAddNewSnapshot = (req, res) => {
  const { isloggedin } = req.session;
  console.log(`User logged in: ${isloggedin}`);
  if (isloggedin) {
    res.render("addemotionsnapshot");
  } else {
    res.redirect("/");
  }
};*/

// SELECT SINGLE EMOTIONHISTORY SNAPSHOT
exports.getEmotionHistByID = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const { id } = req.params;
    const endpoint = `http://localhost:3002/emotionhistory/${id}`;
    console.log(
      `Logged in. Method: getEmotionHistByID | Calling endpoint: ${endpoint}`
    );

    await axios
      .get(endpoint)
      .then((response) => {
        const data = response.data.result;
        console.log(data[0]);
        res.render("editemotionsnapshot", { details: data[0], role });
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

// ADD NEW EMOTIONHISTORY SNAPSHOT
exports.postNewEmotionHist = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const snapshot_details = {
      snapshot_details: {
        inp_anger: parseInt(req.body.inp_anger),
        inp_contempt: parseInt(req.body.inp_contempt),
        inp_disgust: parseInt(req.body.inp_disgust),
        inp_enjoyment: parseInt(req.body.inp_enjoyment),
        inp_fear: parseInt(req.body.inp_fear),
        inp_sadness: parseInt(req.body.inp_sadness),
        inp_surprise: parseInt(req.body.inp_surprise),
        inp_notes: req.body.inp_notes,
        inp_triggerlist: req.body.inp_triggerlist,
        inp_snapshotdate: req.body.inp_snapshotdate,
        inp_user: req.body.inp_user,
      },
    };
    console.log("req.body:", req.body);
    console.log("snapshot_details:", snapshot_details);
    const endpoint = `http://localhost:3002/emotionhistory/new`;
    console.log(
      `Logged in. Method: postNewEmotionHist | Calling endpoint: ${endpoint}`
    );
    await axios
      .post(endpoint, snapshot_details)
      .then((response) => {
        console.log("response.data:", response.data);
        console.log("response.data.status:", response.data.status);
        res.render("index", { loggedin: true, user: "ctn" });
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

// UPDATE EMOTIONHISTORY SNAPSHOT
exports.updateEmotionHistByID = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const snapshot_id = req.params.id;
    console.log("snapshot_id:", snapshot_id);
    const snapshot_details = {
      snapshot_details: {
        inp_ehid: parseInt(req.body.inp_ehid),
        inp_anger: parseInt(req.body.inp_anger),
        inp_contempt: parseInt(req.body.inp_contempt),
        inp_disgust: parseInt(req.body.inp_disgust),
        inp_enjoyment: parseInt(req.body.inp_enjoyment),
        inp_fear: parseInt(req.body.inp_fear),
        inp_sadness: parseInt(req.body.inp_sadness),
        inp_surprise: parseInt(req.body.inp_surprise),
        inp_notes: req.body.inp_notes.trim(),
        inp_triggerlist: req.body.inp_triggerlist.trim(),
        inp_snapshotdate: req.body.inp_snapshotdate,
        inp_user: req.body.inp_user.trim(),
      },
    };
    console.log("req.body:", req.body);
    console.log("snapshot_details:", snapshot_details);
    const endpoint = `http://localhost:3002/emotionhistory/${snapshot_id}`;
    console.log(
      `Logged in. Method: updateEmotionHistByID | Calling endpoint: ${endpoint}`
    );
    await axios
      .put(endpoint, snapshot_details)
      .then((response) => {
        console.log(response.data);
        res.redirect("/");
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

// DELETE EMOTIONHISTORY SNAPSHOT
exports.deleteEmotionHist = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const snapshot_id = req.params.id;
    const endpoint = `http://localhost:3002/emotionhistory/${snapshot_id}`;
    console.log(
      `Logged in. Method: deleteEmotionHist | Calling endpoint: ${endpoint}`
    );
    await axios
      .delete(endpoint)
      .then((response) => {
        console.log(response.data);
        res.redirect("/");
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

// GET EXISTING TRIGGERS
exports.getTriggers = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const endpoint = `http://localhost:3002/triggers/${userid}`;
    console.log(
      `Logged in. Method: getTriggers | Calling endpoint: ${endpoint}`
    );
    await axios
      .get(endpoint)
      .then((response) => {
        const triggerValues = response.data.result.triggerList;
        console.log("triggerValues:", triggerValues);
        res.render("addemotionsnapshot", { triggerValues, role });
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

// ADD NEW TRIGGER
exports.postNewTrigger = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const vals = ({ new_details, new_date } = req.body);
    const endpoint = `http://localhost:3002/triggers/new`;
    console.log(
      `Logged in. Method: postNewTrigger | Calling endpoint: ${endpoint}`
    );
    await axios
      .post(endpoint, vals)
      .then((response) => {
        const data = response.data;
        console.log(data);
        res.redirect("/");
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

// DELETE TRIGGER
exports.deleteTrigger = async (req, res) => {
  const { isloggedin, userid, role } = req.session;
  console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);

  if (isloggedin) {
    const endpoint = `http://localhost:3002/triggers/${snapshot_id}`;
    console.log(
      `Logged in. Method: deleteTrigger | Calling endpoint: ${endpoint}`
    );
    await axios
      .delete(endpoint)
      .then((response) => {
        console.log(response.data);
        res.redirect("/");
      })
      .catch((error) => {
        console.log(`Error making API request: ${error}`);
      });
  } else {
    console.log(`Not logged in: redirecting to home page.`);
    res.redirect("/");
  }
};

exports.getLogin = (req, res) => {
  const logindata = { status: null };
  res.render("login", { loginsuccess: logindata });
};

exports.postLogin = async (req, res) => {
  const vals = ({ username, userpass } = req.body);
  console.log(vals);
  const endpoint = `http://localhost:3002/useradmin/users`;
  console.log(`Method: postLogin | Calling endpoint: ${endpoint}`);
  await axios
    .post(endpoint, vals, {
      validateStatus: (status) => {
        return status < 500;
      },
    })
    .then((response) => {
      const status = response.status;
      if (status === 200) {
        const data = response.data.result;
        console.log(data);

        const session = req.session;
        session.isloggedin = true;
        session.userid = data[0].id;
        console.log(session);
        res.redirect("/");
      } else {
        const data = response.data;
        console.log(data);
        res.render("login", { loginsuccess: data });
      }
    })
    .catch((error) => {
      console.log(`Error making API request: ${error}`);
    });
};

exports.getLogout = (req, res) => {
  req.session.destroy(() => {
    res.redirect("/");
  });
};

exports.postNewUser = async (req, res) => {
  //const { isloggedin, userid, role } = req.session;
  //console.log(`User: ${userid} | Role: ${role} | Logged in: ${isloggedin}`);
 
  const user_details = {
    user_details: {
      inp_name: req.body.inp_name,
      inp_firstname: req.body.inp_firstname,
      inp_lastname: req.body.inp_lastname,
      inp_email: req.body.inp_email,
      inp_password: req.body.inp_password,
      inp_typeid: 2,
    },
  };
  const endpoint = `http://localhost:3002/useradmin/users/new`;
  console.log(`Method: postNewUser | Calling endpoint: ${endpoint}`);
  await axios
  .post(endpoint, user_details)
  .then((response) => {
    const data = response.data;
    console.log(data);
    res.redirect("/");
  })
  .catch((error) => {
    console.log(`Error making API request: ${error}`);
  });
};