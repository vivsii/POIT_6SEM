const express = require('express');
const passport = require('passport');
const BasicStrategy = require('passport-http').BasicStrategy;
const users = require('./users.json'); 

const app = express();
const PORT = 3000;

passport.use(new BasicStrategy((username, password, done) => {
    const user = users.find(u => u.username === username && u.password === password);
    if (!user) {
        return done(null, false);
    }
    return done(null, user);
}));

const authenticate = passport.authenticate('basic', { session: false });

app.use((req, res, next) => {
    if (!['/login', '/resource', '/logout'].includes(req.path)) {
        return res.status(404).send('Not Found');
    }
    next();
});

app.get('/login', authenticate, (req, res) => {
    res.send('Authenticated successfully');
});

app.get('/logout', (req, res) => {
    res.status(401).send('Logged out');
});

app.get('/resource', authenticate, (req, res) => {
    res.send('RESOURCE');
});

app.use((req, res, next) => {
    if (!req.isAuthenticated || !req.isAuthenticated()) {
        return res.redirect('/login');
    }
    next();
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
