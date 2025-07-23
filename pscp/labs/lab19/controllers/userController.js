const User = require('../models/User');
const UserView = require('../views/userViews');

const userController = {
    // GET /api/users
    getUsers: (req, res) => {
        const users = User.getAll();
        res.json(UserView.renderUsers(users));
    },

    // GET /api/users/:id
    getUser: (req, res) => {
        const user = User.getById(parseInt(req.params.id));
        if (!user) {
            return res.status(404).json(UserView.renderError('User not found'));
        }
        res.json(UserView.renderUser(user));
    },

    // POST /api/users
    createUser: (req, res) => {
        const newUser = User.create({
            name: req.body.name,
            email: req.body.email
        });
        res.status(201).json(UserView.renderSuccess('User created successfully', UserView.renderUser(newUser)));
    },

    // PUT /api/users/:id
    updateUser: (req, res) => {
        const updatedUser = User.update(parseInt(req.params.id), {
            name: req.body.name,
            email: req.body.email
        });
        
        if (!updatedUser) {
            return res.status(404).json(UserView.renderError('User not found'));
        }
        
        res.json(UserView.renderSuccess('User updated successfully', UserView.renderUser(updatedUser)));
    },

    // DELETE /api/users/:id
    deleteUser: (req, res) => {
        const deleted = User.delete(parseInt(req.params.id));
        if (!deleted) {
            return res.status(404).json(UserView.renderError('User not found'));
        }
        res.status(200).json(UserView.renderSuccess('User deleted successfully'));
    }
};

module.exports = userController; 