import express from 'express';
import { createClient } from 'webdav';
import fs from 'fs';
import path from 'path';
import multer from 'multer';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

if (!fs.existsSync('uploads')) {
    fs.mkdirSync('uploads');
}
if (!fs.existsSync('downloads')) {
    fs.mkdirSync('downloads');
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, req.params.filename);
    }
});

const upload = multer({
    storage: storage,
    fileFilter: (req, file, cb) => {
        cb(null, true);
    }
}).any(); 

const url = 'https://webdav.yandex.ru';
const username = 'vivsiii';
const password = 'zoahopioekddjatl';

console.log(`Username: ${username}, Password: ${password}`); 

const client = createClient(url, {
    username: username,
    password: password
});

app.use(express.json());

// 1. Создать директорий
app.post('/md/:dirname', async (req, res) => {
    try {
        const dirExists = await client.exists(`/${req.params.dirname}`);
        if (dirExists) {
            return res.status(408).send('Directory already exists');
        }
        await client.createDirectory(`/${req.params.dirname}`);
        res.status(200).send('Directory created successfully');
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// 2. Удалить директорий
app.post('/rd/:dirname', async (req, res) => {
    try {
        const dirExists = await client.exists(`/${req.params.dirname}`);
        if (!dirExists) {
            return res.status(408).send('Directory does not exist');
        }
        await client.deleteFile(`/${req.params.dirname}`);
        res.status(200).send('Directory deleted successfully');
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// 3. Загрузить файл
app.post('/up/:filename', (req, res) => {
    upload(req, res, async (err) => {
        if (err) {
            return res.status(400).send(err.message);
        }

        try {
            if (!req.files || req.files.length === 0) {
                return res.status(400).send('No file uploaded');
            }

            const uploadedFile = req.files[0];
            const fileStream = fs.createReadStream(uploadedFile.path);
            
            await client.putFileContents(`/${req.params.filename}`, fileStream, { overwrite: true });
            
            res.status(200).send('File uploaded successfully');
        } catch (error) {
            if (req.files && req.files[0] && fs.existsSync(req.files[0].path)) {
                fs.unlinkSync(req.files[0].path);
            }
            res.status(408).send(error.message);
        }
    });
});

// 4. Скачать файл
app.post('/down/:filename', async (req, res) => {
    try {
        const exists = await client.exists(`/${req.params.filename}`);
        if (!exists) {
            return res.status(404).send('File not found');
        }

        if (!fs.existsSync(path.join(__dirname, 'downloads'))) {
            fs.mkdirSync(path.join(__dirname, 'downloads'));
        }
        const downloadPath = path.join(__dirname, 'downloads', req.params.filename);
        const fileContent = await client.getFileContents(`/${req.params.filename}`, { 
            format: 'binary'
        });
        
        fs.writeFileSync(downloadPath, fileContent);
        console.log(`File saved to: ${downloadPath}`);
        
        res.download(downloadPath, req.params.filename, (err) => {
            if (err) {
                console.error('Error sending file:', err);
            }
        });
    } catch (error) {
        console.error('Download error:', error);
        res.status(500).send(error.message);
    }
});

// 5. Удалить файл
app.post('/del/:filename', async (req, res) => {
    try {
        const exists = await client.exists(`/${req.params.filename}`);
        if (!exists) {
            return res.status(404).send('File not found');
        }
        await client.deleteFile(`/${req.params.filename}`);
        res.status(200).send('File deleted successfully');
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// 6. Копировать файл
app.post('/copy/:source/:destination', async (req, res) => {
    try {
        const exists = await client.exists(`/${req.params.source}`);
        if (!exists) {
            return res.status(404).send('Source file not found');
        }
        await client.copyFile(`/${req.params.source}`, `/${req.params.destination}`);
        res.status(200).send('File copied successfully');
    } catch (error) {
        res.status(408).send(error.message);
    }
});

// 7. Переместить файл
app.post('/move/:source/:destination', async (req, res) => {
    try {
        const exists = await client.exists(`/${req.params.source}`);
        if (!exists) {
            return res.status(404).send('Source file not found');
        }
        await client.moveFile(`/${req.params.source}`, `/${req.params.destination}`);
        res.status(200).send('File moved successfully');
    } catch (error) {
        res.status(408).send(error.message);
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

