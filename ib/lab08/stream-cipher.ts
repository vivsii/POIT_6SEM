export const bbs = (seed: number, sequenceLength: number) => {
    // p and q are primes congruent to 3 mod 4
    const p: number = 19;  // 19 mod 4 = 3
    const q: number = 31;  // 31 mod 4 = 3
    const n: number = p * q; // n = 589

    // Ensure seed is coprime with n
    if (gcd(seed, n) !== 1) {
        throw new Error('Seed must be coprime with n');
    }

    const sequence: number[] = [];
    let x = (seed * seed) % n; // x0 = x^2 mod n

    for (let i = 0; i < sequenceLength; i++) {
        x = (x * x) % n; // xt = (xt-1)^2 mod n
        const bit = x & 1; // Get least significant bit
        sequence.push(bit);
    }

    return sequence;
}

// Helper function to calculate greatest common divisor
const gcd = (a: number, b: number): number => {
    while (b !== 0) {
        const temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

export const RC4encrypt = (data: string)  => {
    const n: number = 8;
    const key: number[] = [12, 13, 90, 91, 240];

    const m: number = Math.pow(2, n);
    let x: number = 0;
    let y: number;
    const box: number[] = [...Array(m).keys()];

    let startTime: number = performance.now();
    for (let i = 0; i < m; i++) {
        x = (x + box[i] + key[i % key.length]) % m;
        [box[i], box[x]] = [box[x], box[i]];
    }
    let endTime: number = performance.now();
    const generationTime: string = (endTime - startTime).toFixed(4);

    x = y = 0;
    const out: string[] = [];

    for (const char of data) {
        x = (x + 1) % m;
        y = (y + box[x]) % m;
        [box[x], box[y]] = [box[y], box[x]];
        out.push(String.fromCharCode(char.charCodeAt(0) ^ box[(box[x] + box[y]) % m]));
    }

    return {result: out.join(''), generationTime};
}
