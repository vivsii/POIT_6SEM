function NOD(a, b){
    while (b !== 0)
    {
        let temp = b
        b = a % b
        a = temp
    }
    return a
}

function NOD3(a, b, c){
    return NOD(NOD(a,b), c)
}

function findPrimes(a, b) {
    let primes = [];
    for (let i = Math.max(2, a); i <= b; i++) {
        let isPrime = true;
        for (let j = 2; j * j <= i; j++) {
            if (i % j === 0) {
                isPrime = false;
                break;
            }
        }
        if (isPrime) primes.push(i);
    }
    return primes;
}

//console.log(`НОД двух чисел равен: ${NOD(2, 457)}`);
//console.log(`НОД трех чисел равен: ${NOD3(48, 18, 30)}`);
console.log(`Простые числа: ${findPrimes(2, 457)}`);
console.log(`Простые числа: ${findPrimes(421, 457)}`);