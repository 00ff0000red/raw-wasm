const fs = require('fs');
const buffer = fs.readFileSync('inflate.wasm');
const mod = new WebAssembly.Module(buffer);
const instance = new WebAssembly.Instance(mod);

const arrbuf = instance.exports.mem.buffer;
const u8arr = new Uint8Array(arrbuf);

// const gzip = fs.readFileSync('alice.gz');
// const skip = 16;  // skip gzip header
const gzip = fs.readFileSync('inflate.py.gz');
const skip = 21;  // skip gzip header
const src = 2000;
const dst = 2000 + gzip.byteLength;

u8arr.set(gzip.slice(skip), src);

const dstend = instance.exports.inflate(src, dst);
console.log(u8arr.slice(dst, dstend).reduce((p,c)=>p+String.fromCharCode(c),''));
