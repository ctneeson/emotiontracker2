const express = require("express");
const morgan = require("morgan");
const dotenv = require("dotenv").config({ path: "./config.env" });
const session = require("express-session");
const router = require("./routes/emotionroutes");
const userRouter = require("./routes/userroutes");
const path = require("path");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(morgan("tiny"));
app.use(express.static(path.join(__dirname, "/public")));
app.use(express.urlencoded({ extended: true }));

app.use(
  session({
    secret: "mysecretstring1234",
    resave: false,
    saveUninitialized: false,
  })
);

app.use("/", router);
app.use("/useradmin", userRouter);
app.set("view engine", "ejs");

app.listen(process.env.PORT, (err) => {
  if (err) return console.log(err);

  console.log(`Express listening on port ${process.env.PORT}`);
});
