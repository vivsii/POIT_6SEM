class User {
    constructor(id, name, email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    static #users = [
        new User(1, 'vivsi', 'vivsi@gmail.ru'),
        new User(2, 'meow', 'meow@mail.ru')
    ];

    static getAll() {
        return this.#users;
    }

    static getById(id) {
        return this.#users.find(user => user.id === id);
    }

    static create(userData) {
        const newUser = new User(
            this.#users.length + 1,
            userData.name,
            userData.email
        );
        this.#users.push(newUser);
        return newUser;
    }

    static update(id, userData) {
        const user = this.getById(id);
        if (!user) return null;

        user.name = userData.name || user.name;
        user.email = userData.email || user.email;
        return user;
    }

    static delete(id) {
        const initialLength = this.#users.length;
        this.#users = this.#users.filter(user => user.id !== id);
        return initialLength !== this.#users.length;
    }
}

module.exports = User; 