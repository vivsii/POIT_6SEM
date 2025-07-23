class UserView {
    static renderUser(user) {
        return {
            id: user.id,
            name: user.name,
            email: user.email,
            links: {
                self: `/api/users/${user.id}`,
                delete: `/api/users/${user.id}`,
                update: `/api/users/${user.id}`
            }
        };
    }

    static renderUsers(users) {
        return {
            count: users.length,
            users: users.map(user => this.renderUser(user)),
            links: {
                self: '/api/users',
                create: '/api/users'
            }
        };
    }

    static renderError(message) {
        return {
            error: true,
            message: message
        };
    }

    static renderSuccess(message, data = null) {
        return {
            success: true,
            message: message,
            data: data
        };
    }
}

module.exports = UserView; 