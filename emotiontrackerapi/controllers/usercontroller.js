const conn = require("./../utils/dbconn");

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
          message: `${rows.length} records retrieved`,
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
