import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve('dist');
http.createServer((req,res)=>{const url=new URL(req.url,'http://127.0.0.1');const file=path.resolve(root,'.'+decodeURIComponent(url.pathname==='/'?'/index.html':url.pathname));if(!file.startsWith(root+path.sep)||!fs.existsSync(file)){res.writeHead(404);res.end('Not found');return;}res.setHeader('Content-Type',file.endsWith('.svg')?'image/svg+xml':'text/html; charset=utf-8');res.setHeader('Cache-Control','no-store');fs.createReadStream(file).pipe(res);}).listen(8844,'127.0.0.1',()=>console.log('Local preview: http://127.0.0.1:8844'));
