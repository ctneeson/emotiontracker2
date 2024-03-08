const conn = require("./../utils/dbconn");
const mysql = require("mysql2");

exports.getUsers = (req, res) => {
  const selectSQL = `CALL sp_getUsers()`;

  conn.query(selectSQL, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      res.status(200);
      res.json({
        status: "success",
        message: `${rows.length} records retrieved`,
        result: rows,
      });
    }
  });
};

exports.getUserDetails = (req, res) => {
  const { id } = req.params;

  const getuserSQL = `SELECT emotiontracker_users.name, emotiontracker_userstypes.role 
                        FROM emotiontracker_users
                        INNER JOIN emotiontracker_userstypes
                         ON emotiontracker_users.type_id = emotiontracker_userstypes.type_id
                        WHERE emotiontracker_users.id = '${id}'`;

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
          message: `Invalid ID ${id}`,
        });
      }
    }
  });
};

exports.postLogin = (req, res) => {
  const { username, userpass } = req.body;
  const vals = [username, userpass];

  const checkuserSQL = `SELECT id FROM emotiontracker_users
                          WHERE emotiontracker_users.name = '${username}' 
                          AND emotiontracker_users.password = '${userpass}'`;

  conn.query(checkuserSQL, vals, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      console.log(`Length = ${rows.length}`);
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

exports.postNewUser = async (req, res) => {
  const { user_details } = req.body;

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

    const ins_rows = results[0][0]["@ins_rows"];
    console.log("ins_rows:", ins_rows);

    if (ins_rows !== null) {
      res.status(200);
      res.json({
        status: "success",
        message: `New user ${inp_name} created successfully`,
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
