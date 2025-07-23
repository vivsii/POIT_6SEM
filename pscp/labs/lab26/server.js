const express = require('express')
const path = require('path')

const app = express();

app.use(express.static(path.join(__dirname)));

app.get('/wasm',(req,res)=>{
    res.set('Content-Type', 'application/wasm');
    res.sendFile(path.join(__dirname,'code.wasm'))
})

app.listen(3000,()=>{
    console.log('http://localhost:3000');
})