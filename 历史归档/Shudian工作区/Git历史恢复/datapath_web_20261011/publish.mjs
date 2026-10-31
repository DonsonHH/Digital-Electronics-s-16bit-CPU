import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

// Refresh only the exact local artifact files recorded by the previous delivery.
const target='D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre4_数据通路设计与验证/Datapath_Lab_20261011';
const legacy='D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre4_数据通路设计与验证/diagrams/Datapath_Continuous_20261010/Datapath_Trace_Viewer.html';
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const reports=Object.fromEntries(['model','web','readability','focus'].map(k=>[k,JSON.parse(fs.readFileSync(`review/${k}-tests.json`))]));
for(const [name,report]of Object.entries(reports))if(!report.pass)throw Error('Review failed: '+name);
const built=hash('dist/index.html');
if(['web','readability','focus'].some(k=>reports[k].buildSha256!==built))throw Error('Tests do not describe this exact HTML build.');
const previous=JSON.parse(fs.readFileSync('review/delivery.json'));
for(const name of ['index.html','Datapath_Continuous.svg']){
 const dst=path.join(target,name),record=previous.files.find(f=>path.resolve(f.path)===path.resolve(dst));
 if(!record||hash(dst)!==record.sha256)throw Error('Delivery changed outside this task: '+name);
}
if(path.resolve(previous.legacyEntry.path)!==path.resolve(legacy)||hash(legacy)!==previous.legacyEntry.sha256)throw Error('Legacy entry changed outside this task.');
if(hash('dist/Datapath_Continuous.svg')!==hash(path.join(target,'Datapath_Continuous.svg')))throw Error('UI revision must not change the audited standalone SVG.');
if(previous.sourceArchive&&hash(path.join(target,'Datapath_Lab_source.zip'))!==previous.sourceArchive.sha256)throw Error('Source archive changed outside this task.');
if(previous.usageNotesSha256&&hash(path.join(target,'使用说明.md'))!==previous.usageNotesSha256)throw Error('Usage notes changed outside this task.');

const stamp=new Date().toISOString().replace(/[:.]/g,'-');
const backup=path.resolve('review','published_backup_'+stamp),bundle=path.resolve('review','source_bundle_'+stamp);
fs.mkdirSync(backup,{recursive:true});
for(const name of ['index.html','Datapath_Continuous.svg','Datapath_Lab_source.zip','使用说明.md'])fs.copyFileSync(path.join(target,name),path.join(backup,name),fs.constants.COPYFILE_EXCL);
fs.copyFileSync(legacy,path.join(backup,'Datapath_Trace_Viewer.html'),fs.constants.COPYFILE_EXCL);
fs.copyFileSync('review/delivery.json',path.join(backup,'delivery.json'),fs.constants.COPYFILE_EXCL);
const sourceArchiveBefore=hash(path.join(target,'Datapath_Lab_source.zip'));
fs.mkdirSync(path.join(bundle,'data'),{recursive:true});
for(const f of ['package.json','pnpm-lock.yaml','tsconfig.json','build.mjs','README.md','REVIEW.md','CONTEXT.md','semantics.mjs','prepare.mjs','serve.mjs'])fs.copyFileSync(f,path.join(bundle,f));
fs.cpSync('src',path.join(bundle,'src'),{recursive:true});
fs.cpSync('tests',path.join(bundle,'tests'),{recursive:true});
for(const f of ['model.json','schematic.svg','provenance.json'])fs.copyFileSync(path.join('data',f),path.join(bundle,'data',f));
fs.mkdirSync(path.join(bundle,'review'),{recursive:true});
for(const f of ['model-tests.json','web-tests.json','readability-tests.json','focus-tests.json'])fs.copyFileSync(path.join('review',f),path.join(bundle,'review',f));

for(const dst of [path.join(target,'index.html'),legacy]){
 fs.copyFileSync('dist/index.html',dst);
 if(hash(dst)!==built)throw Error('Copy mismatch: '+dst);
}
const files=['index.html','Datapath_Continuous.svg'].map(name=>{const dst=path.join(target,name);return {path:dst,sha256:hash(dst),bytes:fs.statSync(dst).size};});
const record={date:'2026-10-11',revision:'selection-focus',status:'produced_reviewed_not_user_validated',files,legacyEntry:{path:legacy,sha256:hash(legacy)},testCounts:Object.fromEntries(Object.entries(reports).map(([k,r])=>[k,r.checks.length])),backup,sourceBundle:bundle,sourceArchiveBefore,localOnly:true};
fs.writeFileSync('review/delivery.json',JSON.stringify(record,null,2));console.log(JSON.stringify(record,null,2));
