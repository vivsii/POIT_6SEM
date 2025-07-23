const express = require('express');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(express.json());

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Phone Directory API',
      version: '1.0.0',
      description: 'REST API for phone directory management',
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Development server',
      },
    ],
  },
  apis: ['./28-01.js'],
};

const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

function readContacts() {
    try {
        const data = fs.readFileSync('contacts.json', 'utf8');
        return JSON.parse(data).contacts;
    } catch (error) {
        return [];
    }
}

function writeContacts(contacts) {
    try {
        fs.writeFileSync('contacts.json', JSON.stringify({ contacts }, null, 4));
    } catch (error) {
        console.error('Error writing to file:', error);
    }
}

/**
 * @swagger
 * /TS:
 *   get:
 *     summary: Get all phone directory entries
 *     responses:
 *       200:
 *         description: List of phone directory entries
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                   name:
 *                     type: string
 *                   phone:
 *                     type: string
 */
app.get('/TS', (req, res) => {
    const contacts = readContacts();
    res.json(contacts);
});

/**
 * @swagger
 * /TS:
 *   post:
 *     summary: Add a new phone directory entry
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - phone
 *             properties:
 *               name:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       201:
 *         description: Entry created successfully
 */
app.post('/TS', (req, res) => {
    const contacts = readContacts();
    const newEntry = {
        id: contacts.length + 1,
        ...req.body
    };
    contacts.push(newEntry);
    writeContacts(contacts);
    res.status(201).json(newEntry);
});

/**
 * @swagger
 * /TS:
 *   put:
 *     summary: Update a phone directory entry
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - id
 *             properties:
 *               id:
 *                 type: integer
 *               name:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       200:
 *         description: Entry updated successfully
 *       404:
 *         description: Entry not found
 */
app.put('/TS', (req, res) => {
    const contacts = readContacts();
    const { id } = req.body;
    const index = contacts.findIndex(entry => entry.id === id);
    
    if (index === -1) {
        return res.status(404).json({ message: 'Entry not found' });
    }
    
    contacts[index] = { ...contacts[index], ...req.body };
    writeContacts(contacts);
    res.json(contacts[index]);
});

/**
 * @swagger
 * /TS:
 *   delete:
 *     summary: Delete a phone directory entry
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - id
 *             properties:
 *               id:
 *                 type: integer
 *     responses:
 *       200:
 *         description: Entry deleted successfully
 *       404:
 *         description: Entry not found
 */
app.delete('/TS', (req, res) => {
    const contacts = readContacts();
    const { id } = req.body;
    const index = contacts.findIndex(entry => entry.id === id);
    
    if (index === -1) {
        return res.status(404).json({ message: 'Entry not found' });
    }
    
    const updatedContacts = contacts.filter(entry => entry.id !== id);
    writeContacts(updatedContacts);
    res.json({ message: 'Entry deleted successfully' });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  console.log(`Swagger documentation available at http://localhost:${PORT}/api-docs`);
}); 