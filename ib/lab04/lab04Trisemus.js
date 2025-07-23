const { performance } = require('perf_hooks'); 
const germanAlphabet = 'abcdefghijklmnopqrstuvwxyzäöüß';
function createTrisemusTable(key) {
    let table = '';
    let usedChars = new Set();

    for (let char of key.toLowerCase()) {
        if (!usedChars.has(char) && germanAlphabet.includes(char)) {
            table += char;
            usedChars.add(char);
        }
    }

    for (let char of germanAlphabet) {
        if (!usedChars.has(char)) {
            table += char;
            usedChars.add(char);
        }
    }

    return table;
}

function trisemusEncrypt(text, key) {
    let table = createTrisemusTable(key);
    let result = '';

    text = text.toLowerCase().replace(/\s+/g, 'x');

    for (let i = 0; i < text.length; i += 2) {
        let pair = text.substring(i, i + 2);
        if (pair.length < 2) pair += 'x';

        let firstPos = table.indexOf(pair[0]);
        let secondPos = table.indexOf(pair[1]);

        let firstRow = Math.floor(firstPos / 5);
        let firstCol = firstPos % 5;
        let secondRow = Math.floor(secondPos / 5);
        let secondCol = secondPos % 5;

        if (firstRow === secondRow) {
            result += table[firstRow * 5 + (firstCol + 1) % 5];
            result += table[secondRow * 5 + (secondCol + 1) % 5];
        } else if (firstCol === secondCol) {
            result += table[((firstRow + 1) % 5) * 5 + firstCol];
            result += table[((secondRow + 1) % 5) * 5 + secondCol];
        } else {
            result += table[firstRow * 5 + secondCol];
            result += table[secondRow * 5 + firstCol];
        }
    }

    return result;
}

function trisemusDecrypt(text, key) {
    let table = createTrisemusTable(key);
    let result = '';

    for (let i = 0; i < text.length; i += 2) {
        let pair = text.substring(i, i + 2);

        let firstPos = table.indexOf(pair[0]);
        let secondPos = table.indexOf(pair[1]);

        let firstRow = Math.floor(firstPos / 5);
        let firstCol = firstPos % 5;
        let secondRow = Math.floor(secondPos / 5);
        let secondCol = secondPos % 5;

        if (firstRow === secondRow) {
            result += table[firstRow * 5 + (firstCol - 1 + 5) % 5];
            result += table[secondRow * 5 + (secondCol - 1 + 5) % 5];
        } else if (firstCol === secondCol) {
            result += table[((firstRow - 1 + 5) % 5) * 5 + firstCol];
            result += table[((secondRow - 1 + 5) % 5) * 5 + secondCol];
        } else {
            result += table[firstRow * 5 + secondCol];
            result += table[secondRow * 5 + firstCol];
        }
    }

    if (result[result.length - 1] === 'x') result = result.slice(0, -1); 

    return result;
}

const text = "Gutenmorgen";
const key = "enigma";
let startTime, endTime;
startTime = performance.now();
const encryptedText = trisemusEncrypt(text, key);
endTime = performance.now();
console.log('Зашифрованный текст (Трисемус):', encryptedText);
console.log(`Время шифрования: ${(endTime - startTime).toFixed(4)} мс`);

startTime = performance.now();
const decryptedText = trisemusDecrypt(encryptedText, key);
endTime = performance.now();
console.log('Расшифрованный текст (Трисемус):', decryptedText);
console.log(`Время расшифрования: ${(endTime - startTime).toFixed(4)} мс`);
