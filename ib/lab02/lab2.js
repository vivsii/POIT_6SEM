const fs = require('fs');

function calculateFrequencies(filePath) {
    const text = fs.readFileSync(filePath, 'utf-8');
    const frequencies = {}; // символ - количество
    let totalChars = 0; // сколько обработано
    const binaryChars = '01';
    const spaceChars = ' ';
    const italianChars = 'AABDEFGHIILMNOPQRSTUUVZaabdefghiilmnopqrstuuvz';
    const chechenChars = 'АБВГӶДЕӘЖЗИЙКӀЛМНОПРСТУФХЦЧШЪЬЮЯабвгӷдеәжзийкӏлмнопрстуфхцчшъьюя';
    const regexString = `[${chechenChars}${italianChars}${spaceChars}${binaryChars}]`;
    const regex = new RegExp(regexString);

    for (const char of text) {
        if (char.match(regex)) { 
            frequencies[char] = (frequencies[char] || 0) + 1;
            totalChars++;
        }
    }

    return { frequencies, totalChars, isBinary: text.split('').every(char => binaryChars.includes(char)) };
}

function calculateProbabilities(frequencies, totalChars) {
    const probabilities = {};
    for (const char in frequencies) {
        probabilities[char] = frequencies[char] / totalChars;
    }
    return probabilities;
}

function calculateEntropy(probabilities) {
    return -Object.values(probabilities)
        .map(p => p * Math.log2(p))
        .reduce((a, b) => a + b, 0);
}

function calculateInformation(entropy, textLength) {
    return entropy * textLength;
}

function calculateConditionalEntropy(errorProb) {
    const q = 1 - errorProb;
    return -errorProb * Math.log2(errorProb) - q * Math.log2(q);
}

function calculateEffectiveEntropy(errorProb, isBinary) {
    if (errorProb === 0.999999999999 && !isBinary) {
        throw new Error("Ошибка: при вероятности ошибки 1 можно вычислять информацию только для бинарного алфавита");
    }
    return 1 - calculateConditionalEntropy(errorProb);
}

function calculateInformationWithError(entropy, textLength, errorProb, isBinary) {
    const effectiveEntropy = calculateEffectiveEntropy(errorProb, isBinary);
    return entropy * textLength * effectiveEntropy;
}

function main(filePath, fullName) {
    try {
        const { frequencies, totalChars, isBinary } = calculateFrequencies(filePath);
        console.log("Частоты символов:", frequencies);
    
        const probabilities = calculateProbabilities(frequencies, totalChars);
        console.log("Вероятности:", probabilities);
    
        const entropy = calculateEntropy(probabilities);
        console.log(`Энтропия алфавита: ${entropy.toFixed(4)} бит`);
    
        const infoAmount = calculateInformation(entropy, fullName.length);
        console.log(`Количество информации (ФИО): ${infoAmount.toFixed(4)} бит`);
    
        [0.1, 0.5, 0.999999999999].forEach(errorProb => {
            try {
                const infoWithError = calculateInformationWithError(entropy, fullName.length, errorProb, isBinary);
                console.log(`Информация с ошибкой ${errorProb}: ${infoWithError.toFixed(12)} бит`);
            } catch (error) {
                console.error(error.message);
            }
        });
    } catch (error) {
        console.error("Произошла ошибка:", error.message);
    }
}

// Evseenko Viktoriya Pavlovna
// Евсеенко Викториа Павловна
// 1100000110010010110000011011001011000001101011111100000110101101110000011010010111000001101011101100000110101110110000011010010100100000110000011010111111000001101000111000001101010111100000110110000110000011010010111000001101100101100000110100011100000110100001001000001100000110100000110000011010010111000001101011111100000110110011110000011010010011000001101011101100000110100001

const filePath = 'mes1.txt'; 
const fullName = 'Evseenko Viktoriya Pavlovna'; 
main(filePath, fullName);