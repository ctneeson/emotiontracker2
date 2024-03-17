const conn = require("../utils/dbconn");
const mysql = require("mysql2");

exports.getEmotionHist = (req, res) => {
  console.log("Executing exports.getEmotionHist...");
  console.log("req.query:", req.query);
  const uid = req.query.id;
  const urole = req.query.role;
  const selectSQL = `CALL sp_getEmotionHist(${uid}, "${urole}")`;
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
      console.log(rows[0]);
      res.status(200);
      res.json({
        status: "success",
        message: `${rows[0].length} records retrieved`,
        result: rows,
      });
    }
  });
};

exports.getEmotionHistByID = (req, res) => {
  console.log("Executing exports.getEmotionHistByID...");
  const { id } = req.params;
  const selectSQL = `CALL sp_getEmotionHistByID(${id})`;

  conn.query(selectSQL, (err, rows) => {
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
          message: `Record ID ${id} retrieved`,
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

exports.postNewEmotionHist = async (req, res) => {
  console.log("Executing exports.postNewEmotionHist...");
  const { snapshot_details } = req.body;

  if (!snapshot_details) {
    console.error("Error: new_details is undefined in the request body.");
    console.log("new_details:", snapshot_details);
    res.status(400).json({
      status: "failure",
      message: "Invalid request body",
    });
    return;
  }
  console.log("req.body:", req.body);

  const insertSQL =
    "CALL sp_postNewEmotionHist(" +
    mysql.escape(snapshot_details.inp_anger) +
    ", " +
    mysql.escape(snapshot_details.inp_contempt) +
    ", " +
    mysql.escape(snapshot_details.inp_disgust) +
    ", " +
    mysql.escape(snapshot_details.inp_enjoyment) +
    ", " +
    mysql.escape(snapshot_details.inp_fear) +
    ", " +
    mysql.escape(snapshot_details.inp_sadness) +
    ", " +
    mysql.escape(snapshot_details.inp_surprise) +
    ", " +
    mysql.escape(snapshot_details.inp_notes) +
    ", " +
    mysql.escape(snapshot_details.inp_triggerlist) +
    ", " +
    mysql.escape(snapshot_details.inp_snapshotdate) +
    ", " +
    mysql.escape(snapshot_details.inp_user) +
    ", @eh_affectedRows, @tr_affectedRows" +
    ")";

  const logMessage = `Executing SQL: ${insertSQL.replace(/\?/g, (match) =>
    conn.escape(snapshot_details.shift())
  )}`;
  console.log(logMessage);

  try {
    const [results] = await conn
      .promise()
      .query({ sql: insertSQL, multipleStatements: true }, snapshot_details);

    const affectedRows = results[0][0];
    console.log("affectedRows", affectedRows);

    const eh_affectedRows = affectedRows["@eh_affectedRows"];
    const tr_affectedRows = affectedRows["@tr_affectedRows"];

    // Continue with the rest of your response logic
    console.log("res:", res);
    if (eh_affectedRows > 0 || tr_affectedRows > 0) {
      res.status(200);
      res.json({
        status: "success",
        message: `New snapshot added successfully`,
        eh_affectedRows,
        tr_affectedRows,
      });
    } else {
      res.status(404);
      res.json({
        status: "failure",
        message: `New snapshot insertion failed`,
        eh_affectedRows,
        tr_affectedRows,
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

exports.updateEmotionHistByID = async (req, res) => {
  console.log("Executing exports.updateEmotionHistByID...");
  const id = req.params.id;
  const { snapshot_details } = req.body;

  if (!snapshot_details) {
    console.error("Error: snapshot_details is undefined in the request body.");
    console.log("snapshot_details:", snapshot_details);
    res.status(400).json({
      status: "failure",
      message: "Invalid request body",
    });
    return;
  }
  console.log("req.body:", req.body);

  const updateSQL =
    "CALL sp_updateEmotionHistByID(" +
    mysql.escape(snapshot_details.inp_ehid) +
    ", " +
    mysql.escape(snapshot_details.inp_anger) +
    ", " +
    mysql.escape(snapshot_details.inp_contempt) +
    ", " +
    mysql.escape(snapshot_details.inp_disgust) +
    ", " +
    mysql.escape(snapshot_details.inp_enjoyment) +
    ", " +
    mysql.escape(snapshot_details.inp_fear) +
    ", " +
    mysql.escape(snapshot_details.inp_sadness) +
    ", " +
    mysql.escape(snapshot_details.inp_surprise) +
    ", " +
    mysql.escape(snapshot_details.inp_notes) +
    ", " +
    mysql.escape(snapshot_details.inp_triggerlist) +
    ", " +
    mysql.escape(snapshot_details.inp_snapshotdate) +
    ", " +
    mysql.escape(snapshot_details.inp_user) +
    ", @eh_affectedRows, @et_affectedRows_ins, @et_affectedRows_del, @tr_affectedRows_ins, @tr_affectedRows_del" +
    ")";

  const logMessage = `Executing SQL: ${updateSQL.replace(/\?/g, (match) =>
    conn.escape(snapshot_details.shift())
  )}`;
  console.log(logMessage);

  try {
    const [results] = await conn
      .promise()
      .query({ sql: updateSQL, multipleStatements: true }, snapshot_details);

    console.log("results:", results);
    const affectedRows = results[0][0];
    console.log("affectedRows:", affectedRows);

    const eh_affectedRows = affectedRows["@eh_affectedRows"];
    const et_affectedRows_ins = affectedRows["@et_affectedRows_ins"];
    const et_affectedRows_del = affectedRows["@et_affectedRows_del"];
    const tr_affectedRows_ins = affectedRows["@tr_affectedRows_ins"];
    const tr_affectedRows_del = affectedRows["@tr_affectedRows_del"];

    // Continue with the rest of your response logic
    if (
      eh_affectedRows > 0 ||
      et_affectedRows_ins > 0 ||
      et_affectedRows_del > 0 ||
      tr_affectedRows_ins > 0 ||
      tr_affectedRows_del > 0
    ) {
      res.status(200);
      res.json({
        status: "success",
        message: `Snapshot ID ${id} updated`,
        eh_affectedRows,
        et_affectedRows_ins,
        et_affectedRows_del,
        tr_affectedRows_ins,
        tr_affectedRows_del,
      });
    } else if (
      eh_affectedRows == 0 &&
      et_affectedRows_ins == 0 &&
      et_affectedRows_del == 0 &&
      tr_affectedRows_ins == 0 &&
      tr_affectedRows_del == 0
    ) {
      res.status(200);
      res.json({
        status: "success",
        message: `Request successful. No updates processed for Snapshot ID ${id}`,
        eh_affectedRows,
        et_affectedRows_ins,
        et_affectedRows_del,
        tr_affectedRows_ins,
        tr_affectedRows_del,
      });
    } else {
      res.status(404);
      res.json({
        status: "failure",
        message: `Invalid Snapshot ID ${id}`,
        eh_affectedRows,
        et_affectedRows_ins,
        et_affectedRows_del,
        tr_affectedRows_ins,
        tr_affectedRows_del,
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

exports.deleteEmotionHistByID = (req, res) => {
  console.log("Executing exports.deleteEmotionHistByID...");
  const run_id = req.params.id;

  const deleteSQL = `CALL sp_deleteEmotionHistByID(${run_id}, @del_affectedRows)`;

  conn.query(deleteSQL, (err, rows) => {
    console.log(res);
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      if (res.affectedRows > 0) {
        res.status(200);
        res.json({
          status: "success",
          message: `Record ID ${run_id} deleted`,
        });
      } else {
        res.status(404);
        res.json({
          status: "failure",
          message: `Invalid ID ${run_id}`,
        });
      }
    }
  });
};

//////////////
// TRIGGERS //
//////////////
exports.getTriggers = (req, res) => {
  console.log("Executing exports.getTriggers...");
  const userid = req.params.id;

  const selectSQL = `CALL sp_getTriggers(${userid})`;

  conn.query(selectSQL, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      console.log(rows[0][0]);
      res.status(200);
      res.json({
        status: "success",
        message: `${rows[0].length} record(s) retrieved`,
        result: rows[0][0],
      });
    }
  });
};

exports.postNewTrigger = (req, res) => {
  console.log("Executing exports.postNewTrigger...");
  const { new_details, new_date } = req.body;
  const vals = [new_details, new_date];

  const insertSQL = `INSERT INTO triggers (description) VALUES (?)`;

  conn.query(insertSQL, vals, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      res.status(201);
      res.json({
        status: "success",
        message: `Record ID ${rows.insertId} added to triggers`,
      });
    }
  });
};

exports.deleteTrigger = (req, res) => {
  console.log("Executing exports.deleteTrigger...");
  const run_id = req.params.id;

  const deleteSQL = `DELETE FROM triggers WHERE id = ${run_id}`;

  conn.query(deleteSQL, (err, rows) => {
    if (err) {
      res.status(500);
      res.json({
        status: "failure",
        message: err,
      });
    } else {
      if (rows.affectedRows > 0) {
        res.status(200);
        res.json({
          status: "success",
          message: `Record ID ${run_id} deleted`,
        });
      } else {
        res.status(404);
        res.json({
          status: "failure",
          message: `Invalid ID ${run_id}`,
        });
      }
    }
  });
};
