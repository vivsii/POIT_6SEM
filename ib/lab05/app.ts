const express = require('express');
const fs = require('fs');
const path = require('path');
import { Request, Response } from 'express';

const { GERMAN_ALPHABET, calculateSymbolsFrequency, clearText, exportHistogram, factorizeNumber, formEncryptionTable, formSortedTable, multipleTranspositionDecode, multipleTranspositionEncode, routeTranspositionDecode, routeTranspositionEncode } = require("./cipher");

const app = express();

app.set('view engine', 'ejs');

app.get("/", (req: Request, res: Response) => {
    return res.redirect("/transposition");
})

app.get('/transposition', async (req: Request, res: Response) => {
    const originalFilePath = path.join(__dirname, "files", "german.txt");
    const encodedFilePath = path.join(__dirname, "files", "german_transposition.txt");

    let text = fs.readFileSync(originalFilePath, {encoding: "utf-8"});
    text = text.toLowerCase();
    text = clearText(text);

    let originalFrequency = calculateSymbolsFrequency(originalFilePath, GERMAN_ALPHABET);
    await exportHistogram('german.xlsx', originalFrequency.resultFrequency, GERMAN_ALPHABET);

    let tableSize = factorizeNumber(text.length);

    let startTime = performance.now();
    let encodedText: string = routeTranspositionEncode(text, tableSize);
    let endTime = performance.now();
    const encodingTime = (endTime - startTime).toFixed(4);

    fs.writeFileSync(encodedFilePath, encodedText, {encoding: 'utf8'});
    let encodedFrequency = calculateSymbolsFrequency(encodedFilePath, GERMAN_ALPHABET);
    await exportHistogram('transposition.xlsx', encodedFrequency.resultFrequency, GERMAN_ALPHABET);

    startTime = performance.now();
    let originalText = routeTranspositionDecode(encodedText, tableSize);
    endTime = performance.now();
    const decodingTime = (endTime - startTime).toFixed(4);

    res.render('routeTransposition', {
        encodedText: encodedText,
        encodingTime: encodingTime,
        originalText: originalText,
        decodingTime: decodingTime
    });
});

app.get('/multiple-transposition', async (req: Request, res: Response) => {
    const originalFilePath = path.join(__dirname, "files", "german.txt");
    const encodedFilePath = path.join(__dirname, "files", "german_multransposition.txt");

    let text = fs.readFileSync(originalFilePath, {encoding: "utf-8"});
    text = text.toLowerCase();
    text = clearText(text);

    let originalFrequency = calculateSymbolsFrequency(originalFilePath, GERMAN_ALPHABET);
    await exportHistogram('german.xlsx', originalFrequency.resultFrequency, GERMAN_ALPHABET);

    let tableSize = factorizeNumber(text.length);
    let table = formEncryptionTable(text, tableSize);

    let startTime = performance.now();
    let sorted = formSortedTable(tableSize, table);
    let encodedText: string = multipleTranspositionEncode(text, sorted);
    let endTime = performance.now();
    const encodingTime = (endTime - startTime).toFixed(4);

    fs.writeFileSync(encodedFilePath, encodedText, {encoding: 'utf8'});
    let encodedFrequency = calculateSymbolsFrequency(encodedFilePath, GERMAN_ALPHABET);
    await exportHistogram('multransposition.xlsx', encodedFrequency.resultFrequency, GERMAN_ALPHABET);

    startTime = performance.now();
    let originalText = multipleTranspositionDecode(tableSize, sorted);
    endTime = performance.now();
    const decodingTime = (endTime - startTime).toFixed(4);

    res.render('multipleTransposition', {
        encodedText: encodedText,
        encodingTime: encodingTime,
        originalText: originalText,
        decodingTime: decodingTime
    });
});


app.listen(3000, () => console.log(`Server is running at http://localhost:3000`));