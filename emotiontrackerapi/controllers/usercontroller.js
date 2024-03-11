const conn = require("./../utils/dbconn");
const mysql = require("mysql2");

///////////////////////////////////////
// USER CALLS:                       //
// VALIDATE USER LOGIN - postLogin   //
// GET ACCOUNT DETAILS - getUsers    //
// GET USER DETAILS - getUserDetails //
// CREATE ACCOUNT - postNewUser      //
// UPDATE ACCOUNT - putUserDetails   //
// DELETE ACCOUNT - deleteUser       //
///////////////////////////////////////

// Called from http://localhost:3000/login
// Validates user ID & password combination to allow login
exports.postLogin = (req, res) => {
  console.log("Executing exports.postLogin...");
  const { username, userpass } = req.body;
  const vals = [username, userpass];

  if (!username || !userpass) {
    console.error("Error: undefined details in the request body.");
    console.log("username:", username);
    console.log("userpass:", userpass);
    res.status(400).json({
      status: "failure",
      message: "Invalid request body",
    });
    return;
  }

  const checkuserSQL = `SELECT id FROM emotiontracker_users
                        WHERE emotiontracker_users.name = '${username}' 
                        AND emotiontracker_users.password = '${userpass}'`;

  console.log("Executing SQL:", checkuserSQL);
  conn.query(checkuserSQL, vals, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      if (rows.length > 0) {
        res.status(200);
        res.json({
          status: "success",
          message: `${rows.length} records retrieved`,
          result: rows,
        });
      } else {
        res.status(401);
        res.json({
          status: "failure",
          message: `Invalid user credentials`,
        });
      }
    }
  });
};

// Called from http://localhost:3000/accountadmin
// Returns user details based on role ('administrator': all users / 'user': individual user)
exports.getUsers = (req, res) => {
  console.log("Executing exports.getUsers...");
  console.log("req.query:", req.query);
  const uid = req.query.id;
  const urole = req.query.role;

  if (!uid || !urole) {
    console.error(
      `Error: undefined query parameters - uid: ${uid}, urole: ${urole}`
    );
    console.log(`uid: ${uid}, urole: ${urole}`);
    res.status(400).json({
      status: "failure",
      message: "Invalid query parameters",
    });
    return;
  }

  const selectSQL = `CALL sp_getUsers(${uid}, "${urole}")`;

  const logMessage = `Executing SQL: ${selectSQL}`;
  console.log(logMessage);

  conn.query(selectSQL, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      const numRows = rows[0].length;
      res.status(200);
      res.json({
        status: "success",
        message: `${numRows} record(s) retrieved`,
        result: rows,
      });
    }
  });
};

exports.getUserDetails = (req, res) => {
  console.log("Executing exports.getUserDetails...");
  const { id } = req.params;

  if (!id) {
    console.error("Error: User ID undefined in the request body.");
    console.log("user id:", id);
    res.status(400).json({
      status: "failure",
      message: "Invalid request body",
    });
    return;
  }

  const getuserSQL = `SELECT emotiontracker_users.name, emotiontracker_userstypes.role 
                      FROM emotiontracker_users
                      INNER JOIN emotiontracker_userstypes
                       ON emotiontracker_users.type_id = emotiontracker_userstypes.type_id
                      WHERE emotiontracker_users.id = '${id}'`;

  console.log("Executing SQL:", getuserSQL);
  conn.query(getuserSQL, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      if (rows.length > 0) {
        res.status(200);
        res.json({
          status: "success",
          message: `${rows.length} record(s) retrieved`,
          result: rows,
        });
      } else {
        res.status(404);
        res.json({
          status: "failure",
          message: `Invalid User ID ${id}`,
        });
      }
    }
  });
};

exports.postNewUser = async (req, res) => {
  console.log("Executing exports.postNewUser...");
  const user_details = {
    inp_name: req.body["user_details[inp_name]"],
    inp_firstname: req.body["user_details[inp_firstname]"],
    inp_lastname: req.body["user_details[inp_lastname]"],
    inp_email: req.body["user_details[inp_email]"],
    inp_password: req.body["user_details[inp_password]"],
    inp_typeid: req.body["user_details[inp_typeid]"],
  };
  console.log("user_details:", user_details);

  if (!user_details) {
    console.error("Error: user_details is undefined in the request body.");
    console.log("user_details:", user_details);
    res.status(400).json({
      status: "failure",
      message: "Invalid request body",
    });
    return;
  }

  const insertSQL =
    "CALL sp_postNewUser(" +
    mysql.escape(user_details.inp_name) +
    ", " +
    mysql.escape(user_details.inp_firstname) +
    ", " +
    mysql.escape(user_details.inp_lastname) +
    ", " +
    mysql.escape(user_details.inp_email) +
    ", " +
    mysql.escape(user_details.inp_password) +
    ", " +
    mysql.escape(user_details.inp_typeid) +
    ", @ins_rows" +
    ")";

  const logMessage = `Executing SQL: ${insertSQL.replace(/\?/g, (match) =>
    conn.escape(user_details.shift())
  )}`;
  console.log(logMessage);

  try {
    const [results] = await conn
      .promise()
      .query({ sql: insertSQL, multipleStatements: true }, user_details);

    const ins_rows = results[0][0].ins_rows;
    console.log("ins_rows:", ins_rows);

    if (ins_rows !== null) {
      res.status(200);
      res.json({
        status: "success",
        message: `New user ${user_details.inp_name} created successfully`,
        ins_rows,
      });
    } else {
      res.status(404);
      res.json({
        status: "failure",
        message: `New user creation failed`,
        ins_rows,
      });
    }
  } catch (error) {
    res.status(500);
    res.json({
      status: "failure",
      message: error.message,
    });
  }
};

exports.putUserDetails = (req, res) => {
  console.log("Executing exports.putUserDetails...");
  const { userid } = req.params;
  console.log("req.params", req.params);
  const { account_details } = req.body;
  console.log("account_details", account_details);

  const updateSQL =
    "CALL sp_updateUser(" +
    mysql.escape(account_details.inp_id) +
    ", " +
    mysql.escape(account_details.inp_name) +
    ", " +
    mysql.escape(account_details.inp_firstname) +
    ", " +
    mysql.escape(account_details.inp_lastname) +
    ", " +
    mysql.escape(account_details.inp_email) +
    ", " +
    mysql.escape(account_details.inp_password) +
    ", " +
    mysql.escape(account_details.inp_role) +
    ", @upd_affectedRows" +
    ")";

  const logMessage = `Executing SQL: ${updateSQL.replace(/\?/g, (match) =>
    conn.escape(account_details.shift())
  )}`;
  console.log(logMessage);

  conn.query(updateSQL, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      if (rows.length > 0) {
        var upd_affectedRows = rows[0][0]["@upd_affectedRows"];
        res.status(200);
        res.json({
          status: "success",
          message: `${upd_affectedRows} record(s) updated`,
          result: rows,
        });
      } else {
        res.status(404);
        res.json({
          status: "failure",
          message: `Invalid User ID ${userid}`,
        });
      }
    }
  });
};

exports.deleteUser = (req, res) => {
  console.log("Executing exports.deleteUser...");
  const username = req.params.name;
  console.log("username", username);

  if (!username) {
    console.error("Error: undefined details in the request body.");
    console.log("username:", username);
    res.status(400).json({
      status: "failure",
      message: "Invalid request body",
    });
    return;
  }

  const deleteuserSQL =
    "CALL sp_deleteUser(" + mysql.escape(username) + ", @del_rows" + ")";

  const logMessage = `Executing SQL: ${deleteuserSQL.replace(/\?/g, (match) =>
    conn.escape(req.body.shift())
  )}`;
  console.log(logMessage);

  conn.query(deleteuserSQL, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      if (rows.length > 0) {
        var deletedRows = rows[0][0].del_rows;
        res.status(200);
        res.json({
          status: "success",
          message: `${deletedRows} record(s) deleted`,
          result: rows,
        });
      } else {
        res.status(401);
        res.json({
          status: "failure",
          message: `Invalid user credentials`,
        });
      }
    }
  });
};
