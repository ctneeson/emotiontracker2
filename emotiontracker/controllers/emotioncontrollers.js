const axios = require("axios");

/////////////////////////////////////
// LOGIN CALLS:                    //
// SEND LOGIN DETAILS - postLogin  //
// VALIDATE LOGIN - getLogin       //
// VALIDATE LOGOUT - getLogout     //
/////////////////////////////////////
exports.getLogin = (req, res) => {
  const logindata = { status: null };
  res.render("login", { loginsuccess: logindata });
};

exports.postLogin = async (req, res) => {
  const vals = ({ username, userpass } = req.body);
  console.log("vals:", vals);
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
        console.log("data:", data);

        const session = req.session;
        session.isloggedin = true;
        session.userid = data[0][0].id;
        session.userName = data[0][0].name;
        session.role = data[0][0].role;
        console.log(
          `postLogin|User: ${session.userid} | Username: ${session.userName} | Role: ${session.role} | Logged in: ${session.isloggedin}`
        );

        var orig_route = session.route;
        if (!orig_route) {
          orig_route = "/";
        }
        console.log("postLogin|orig_route:", orig_route);

        res.redirect(
          `${orig_route}?user=${encodeURIComponent(session.userName)}`
        );
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

//////////////////////////////////////////////////////
// EMOTIONHISTORY CALLS:                            //
// GET ALL SNAPSHOTS FOR USER - getEmotionHist      //
// GET SINGLE SNAPSHOT - getEmotionHistByID         //
// ADD NEW SNAPSHOT - postNewEmotionHist            //
// UPDATE EXISTING SNAPSHOT - updateEmotionHistByID //
//////////////////////////////////////////////////////
exports.getEmotionHist = async (req, res) => {
  const { isloggedin, userid, role, userName } = req.session;
  console.log(
    `User: ${userid} | Username: ${userName} | Role: ${role} | Logged in: ${isloggedin}`
  );

  if (!isloggedin) {
    return res.render("index", { loggedin: false });
  }

  const emotionEndpoint = `http://localhost:3002/emotionhistory/?id=${userid}&role=${role}`;

  try {
    const queryParams = {
      inp_userid: userid,
      inp_role: role,
    };
    console.log("queryParams:", queryParams);

    const emotionResponse = await axios.get(emotionEndpoint, {
      params: queryParams,
    });
    const emotionData = emotionResponse.data.result;
    console.log("emotionData[0]:", emotionData[0]);

    res.render("index", {
      snapshot: emotionData[0],
      loggedin: isloggedin,
      user: { name: userName, role: role },
      role,
      userName,
    });
  } catch (error) {
    console.log(`Error making API request: ${error}`);
  }
};

exports.getEmotionHistByID = async (req, res) => {
  const { isloggedin, userid, role, userName } = req.session;
  console.log(
    `User: ${userid} | Username: ${userName} | Role: ${role} | Logged in: ${isloggedin}`
  );

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
      res.render("editemotionsnapshot", { details: data[0], role, userName });
    })
    .catch((error) => {
      console.log(`Error making API request: ${error}`);
    });
};

exports.postNewEmotionHist = async (req, res) => {
  const { isloggedin, userid, role, userName } = req.session;
  console.log(
    `User: ${userid} | Username: ${userName} | Role: ${role} | Logged in: ${isloggedin}`
  );

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
};

exports.updateEmotionHistByID = async (req, res) => {
  const { isloggedin, userid, role, userName } = req.session;
  console.log(
    `User: ${userid} | Username: ${userName} | Role: ${role} | Logged in: ${isloggedin}`
  );

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
      console.log("response.data:", response.data);
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
};

// DELETE EMOTIONHISTORY SNAPSHOT
exports.deleteEmotionHist = async (req, res) => {
  const { isloggedin, userid, role, userName } = req.session;
  console.log(
    `User: ${userid} | Username: ${userName} | Role: ${role} | Logged in: ${isloggedin}`
  );

  console.log("req.params:", req.params);
  console.log("req.body:", req.body);
  const snapshot_id = req.body.inp_ehid;
  console.log("snapshot_id:", snapshot_id);
  const user = req.body.inp_user;
  console.log("user:", user);
  const endpoint = `http://localhost:3002/emotionhistory/?id=${snapshot_id}&user=${user}`;
  console.log(
    `Logged in. Method: deleteEmotionHist | Calling endpoint: ${endpoint}`
  );
  await axios
    .delete(endpoint)
    .then((response) => {
      console.log("response.data:", response.data);
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
};

// GET EXISTING TRIGGERS
exports.getTriggers = async (req, res) => {
  const { isloggedin, userid, role, userName } = req.session;
  console.log(
    `User: ${userid} | Username: ${userName} | Role: ${role} | Logged in: ${isloggedin}`
  );

  const endpoint = `http://localhost:3002/triggers/${userid}`;
  console.log(`Logged in. Method: getTriggers | Calling endpoint: ${endpoint}`);
  await axios
    .get(endpoint)
    .then((response) => {
      const triggerValues = response.data.result.triggerList;
      console.log("triggerValues:", triggerValues);
      res.render("addemotionsnapshot", { triggerValues, role, userName });
    })
    .catch((error) => {
      console.log(`Error making API request: ${error}`);
    });
};
