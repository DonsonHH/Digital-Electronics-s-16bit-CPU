const fs=require('fs');
const path=require('path');
const sharp=require('C:/Users/Donson/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
(async()=>{
 const root=path.join(__dirname,'figures');
 for(const f of fs.readdirSync(root).filter(x=>x.endsWith('.svg'))){
  await sharp(path.join(root,f)).resize({width:3600}).png().toFile(path.join(root,f.replace('.svg','.png')));
 }
 console.log('PNG_RENDER_COMPLETE width=3600 aspect_preserved');
})();
