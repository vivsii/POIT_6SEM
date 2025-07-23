import express from 'express';
import {bbs, RC4encrypt} from "./stream-cipher";
const app = express();

app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.set('view engine', 'ejs');

app.get("/", (req, res) => {
    res.redirect('/bbs');
});

app.get("/bbs", (req, res) => {
    res.render('bbs');
});

app.get("/rc4", (req, res) => {
    res.render('rc4');
});

app.post("/bbs", (req, res) => {
    const {seed, length} = req.body;
    const sequence: number[] = bbs(seed, length);
    res.status(200).json(sequence.join(', '));
});

app.post("/rc4", (req, res) => {
    const text = req.body.text;
    const {result, generationTime} = RC4encrypt(text);
    const decrypted: string = RC4encrypt(result).result;
    res.status(200).json({result, decrypted, generationTime});
});


app.listen(3000, () => console.log(`Server is running at http://localhost:3000`));  