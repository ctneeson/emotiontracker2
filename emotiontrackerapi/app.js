const express = require("express");
const morgan = require("morgan");
const dotenv = require("dotenv").config({ path: "./config.env" });
const emotionrouter = require("./routes/emotionroutes");
const userrouter = require("./routes/userroutes");

const app = express();

app.use(morgan("tiny"));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

app.use("/", emotionrouter);
/////////////////////////////////
app.use("/useradmin", userrouter); // <<< CHECK THIS ONE
/////////////////////////////////

app.listen(process.env.PORT, (err) => {
  if (err) return console.log(err);

  console.log(`Express listening on port ${process.env.PORT}`);
});
