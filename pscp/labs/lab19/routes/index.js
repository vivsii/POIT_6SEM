const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

const routes = [
    { path: '/api/users', method: 'GET', action: userController.getUsers },
    { path: '/api/users/:id', method: 'GET', action: userController.getUser },
    { path: '/api/users', method: 'POST', action: userController.createUser },
    { path: '/api/users/:id', method: 'PUT', action: userController.updateUser },
    { path: '/api/users/:id', method: 'DELETE', action: userController.deleteUser }
];

routes.forEach(route => {
    router[route.method.toLowerCase()](route.path, route.action);
});

module.exports = router; 