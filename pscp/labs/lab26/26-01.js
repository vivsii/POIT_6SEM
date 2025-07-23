const fs = require('fs')

const buf = fs.readFileSync('./code.wasm')
WebAssembly.instantiate(new Uint8Array(buf)).then(({instance})=>{
    console.log(instance.exports.sum(2,3))
    console.log(instance.exports.mul(2,3))
    console.log(instance.exports.sub(2,3))

})