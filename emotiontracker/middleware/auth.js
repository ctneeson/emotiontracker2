exports.isAuth = (req, res, next) => {
  const { isloggedin, userid, role, userName } = req.session;

  if (!isloggedin) {
    req.session.route = req.originalUrl;
    console.log(`Not logged in: redirecting to login page.`);
    return res.redirect("/login");
  }
  next();
};
