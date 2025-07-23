import express, { Request, Response } from 'express';
import crypto from 'crypto';
import { performance } from 'perf_hooks';

const app = express();
const PORT = 3000;

app.set('view engine', 'ejs');
app.use(express.json());

app.get('/', (_req: Request, res: Response): void => {
    res.redirect('/sha');
});

app.get('/sha', (_req: Request, res: Response): void => {
    res.render('sha');
});

app.get('/md5', (_req: Request, res: Response): void => {
    res.render('md5');
});

app.post('/sha', (req: Request, res: Response): void => {
    const message = req.body.message as string;
    if (!message) {
        res.status(400).json({ error: 'Message is required' });
        return;
    }
    const startTime = performance.now();
    const hash = crypto.createHash('sha256').update(message).digest('hex');
    const endTime = performance.now();
    const hashingTime = endTime - startTime;
    const length = hash.length / 2;
    res.json({ hash, length, hashingTime });
});

app.post('/md5', (req: Request, res: Response): void => {
    const message = req.body.message as string;
    if (!message) {
        res.status(400).json({ error: 'Message is required' });
        return;
    }
    const startTime = performance.now();
    const hash = crypto.createHash('md5').update(message).digest('hex');
    const endTime = performance.now();
    const hashingTime = endTime - startTime;
    const length = hash.length / 2;
    res.json({ hash, length, hashingTime });
});

app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
});
