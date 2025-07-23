const germanAlphabet = 'abcdefghijklmnopqrstuvwxyzäöüß';

function caesarCipherEncrypt(text, k) {
    let result = '';
    text = text.toLowerCase();

    for (let i = 0; i < text.length; i++) {
        let char = text[i];
        let index = germanAlphabet.indexOf(char);

        if (index !== -1) {
            let newIndex = (index + k) % germanAlphabet.length;
            result += germanAlphabet[newIndex];
        } else {
            result += char;
        }
    }
    return result;
}

function caesarCipherDecrypt(text, k) {
    let result = '';
    text = text.toLowerCase();

    for (let i = 0; i < text.length; i++) {
        let char = text[i];
        let index = germanAlphabet.indexOf(char);

        if (index !== -1) {
            let newIndex = (index - k + germanAlphabet.length) % germanAlphabet.length;
            result += germanAlphabet[newIndex];
        } else {
            result += char;
        }
    }
    return result;
}

const text = "Gutenmorgen";
const key = 7;
let startTime, endTime;
startTime = performance.now();
const encryptedText = caesarCipherEncrypt(text, key);
endTime = performance.now();
console.log('Зашифрованный текст: ', encryptedText);
console.log(`Время шифрования: ${(endTime - startTime).toFixed(4)} мс`);

startTime = performance.now();
const decryptedText = caesarCipherDecrypt(encryptedText, key);
endTime = performance.now();
console.log('Расшифрованный текст: ', decryptedText);
console.log(`Время расшифрования: ${(endTime - startTime).toFixed(4)} мс`);
