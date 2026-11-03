// Render verified SVG sources without translating or redrawing their circuitry.
import fs from 'node:fs/promises';
import path from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire('C:/Users/Donson/.codex/skills/wavedrom-gen/package.json');
const {Resvg}=require('@resvg/resvg-js');
const root=path.resolve(process.argv[2]);
async function render(input,output,view,focusHeaders=false){
 let svg=await fs.readFile(path.join(root,input),'utf8');
 if(focusHeaders){
  // The focus crop keeps EX/MEM/WB titles but omits clipped legend/ID labels.
  // The canonical full SVG and every circuit element remain unchanged.
  svg=svg.replace(/<text\b([^>]*)>[\s\S]*?<\/text>/g,(element,attrs)=>{
   const x=Number(attrs.match(/\bx="([^"]+)"/)?.[1]),y=Number(attrs.match(/\by="([^"]+)"/)?.[1]);
   return y<150||(y<250&&x<view[0])?'':element;
  });
 }
 if(view){svg=svg.replace(/viewBox="[^"]+"/,`viewBox="${view.join(' ')}"`).replace(/width="[^"]+"/,`width="${view[2]}"`).replace(/height="[^"]+"/,`height="${view[3]}"`);}
 const image=new Resvg(svg,{font:{loadSystemFonts:true,defaultFontFamily:'Microsoft YaHei'},fitTo:{mode:'width',value:3600}}).render();
 await fs.writeFile(path.join(root,output),image.asPng());
}
await render('ISA_官网编码表.svg','ISA_官网编码表.png');
await render('CPU_整体架构_中文.svg','CPU_控制区_中文.png',[45,205,2310,620]);
await render('CPU_五级Datapath_中文.svg','CPU_EX_WB路径_中文.png',[865,125,1505,1280],true);
console.log('VERIFIED_SOURCE_ASSETS_RENDERED');
