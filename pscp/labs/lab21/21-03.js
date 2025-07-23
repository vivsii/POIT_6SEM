const express = require('express');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const bodyParser = require('body-parser');
const session = require('express-session');
const users = require('./users.json'); 

const app = express();
const PORT = 3000;

passport.use(new LocalStrategy(
  (username, password, done) => {
    const user = users.find(u => u.username === username && u.password === password);
    if (!user) {
      return done(null, false, { message: 'Invalid credentials' });
    }
    return done(null, user);
  }
));

passport.serializeUser((user, done) => {
  done(null, user.username);
});

passport.deserializeUser((username, done) => {
  const user = users.find(u => u.username === username);
  done(null, user);
});

app.use(bodyParser.urlencoded({ extended: false }));

app.use(session({
  secret: 'yourSecretKey', 
  resave: false,
  saveUninitialized: true
}));

app.use(passport.initialize());
app.use(passport.session());

app.use((req, res, next) => {
    if (!['/login', '/resource', '/logout'].includes(req.path) && 
        !req.path.startsWith('/login')) { 
        return res.status(404).send('Not Found');
    }
    next();
});

// GET /login 
app.get('/login', (req, res) => {
  if (req.isAuthenticated()) {
    return res.redirect('/resource');
  }
  res.send(`
    <form method="POST" action="/login">
      <label>Username:</label>
      <input type="text" name="username" required><br>
      <label>Password:</label>
      <input type="password" name="password" required><br>
      <button type="submit">Login</button>
    </form>
  `);
});

// POST /login 
app.post('/login', passport.authenticate('local', { successRedirect: '/resource', failureRedirect: '/login' }));

// GET /logout 
app.get('/logout', (req, res) => {
  req.logout((err) => {
    if (err) {
      return res.status(500).send('Error during logout');
    }
    res.redirect('/login');
  });
});

// GET /resource 
app.get('/resource', (req, res) => {
  if (!req.isAuthenticated()) {
    return res.redirect('/login'); 
  }
  res.send('RESOURCE');
});

app.use((req, res, next) => {
  if (!req.isAuthenticated || !req.isAuthenticated()) {
    return res.redirect('/login');
  }
  next();
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
