import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {descriptions} from './semantics.mjs';
import {guides} from '../pre4_20261008/continuous_datapath_20261010/guide_data.mjs';
import {groupOf} from '../pre4_20261008/continuous_datapath_20261010/ui_groups.mjs';
const previous=path.resolve('../pre4_20261008/continuous_datapath_20261010/build');
const rtl='D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre4_数据通路设计与验证/Vivado/rtl';
const read=n=>JSON.parse(fs.readFileSync(path.join(previous,n),'utf8'));
const graph=read('layout.json'),nets=read('display_nets.json'),audit=read('source_audit.json'),portAudit=read('rtl_port_audit.json');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const [name,expected]of Object.entries(audit.sourceHashes))if(hash(fs.readFileSync(path.join(rtl,name)))!==expected)throw Error('Source changed: '+name);
const semantics={};
for(const n of graph.children){
 const spec=descriptions[n.id];if(!spec)throw Error('No explanation: '+n.id);
 const [name,purpose,how,questions,anchor,count]=spec;
 const lines=fs.readFileSync(path.join(rtl,n.rtl),'utf8').split(/\r?\n/);
 const start=lines.findIndex(l=>l.includes(anchor));if(start<0)throw Error('Missing source anchor: '+n.id+' '+anchor);
 const role=['sys','zero','status','trace'].includes(n.id)?'连接图中的输入、常量或观察终点':n.pairs?'实际流水寄存器字段':n.rtl==='datapath_core.sv'?'datapath_core 内部组合逻辑的功能分组':['fwd_select','fwd_rd','fwd_rs'].includes(n.id)?'operand_forward 内部逻辑展开':'RTL 实例模块';
 semantics[n.id]={name,purpose,how,questions,role,source:{file:n.rtl,start:start+1,text:lines.slice(start,start+count).join('\n')}};
}
for(const g of guides)for(const [signal,node]of g.steps)if(!nets.some(n=>n.signal===signal)||!graph.children.some(n=>n.id===node))throw Error('Invalid guide '+g.id);
const model={nodes:graph.children.map(n=>({...n,zone:groupOf(n)})),nets,captureRules:portAudit.registerFieldAssignments,aliases:audit.aliases,guides,semantics,width:graph.width+160,height:graph.height+480,offset:{x:80,y:285},connectionCount:graph.edges.length,sourceHashes:audit.sourceHashes,review:{formalPorts:portAudit.formalPortsCovered,registerFields:portAudit.registerFieldAssignments.length,routes:12,sourceDate:'2026-10-11'}};
const svg=fs.readFileSync(path.join(previous,'datapath_continuous.svg'),'utf8');
// The original generated SVG has only authored graphics/style/title content.
if(/<script\b|<foreignObject\b|\bon\w+=|(?:href|src)\s*=\s*["']https?:/i.test(svg))throw Error('Unexpected active/external SVG content');
fs.mkdirSync('data',{recursive:true});fs.writeFileSync('data/model.json',JSON.stringify(model));fs.writeFileSync('data/schematic.svg',svg);
fs.writeFileSync('data/provenance.json',JSON.stringify({graphSha256:hash(fs.readFileSync(path.join(previous,'source_graph.json'))),svgSha256:hash(svg),sourceHashes:audit.sourceHashes,prepared:'2026-10-11',nodes:model.nodes.length,nets:nets.length,connections:graph.edges.length},null,2));
console.log(JSON.stringify({nodes:model.nodes.length,nets:nets.length,explanations:Object.keys(semantics).length,captures:model.captureRules.length}));
