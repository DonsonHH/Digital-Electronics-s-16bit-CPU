import type {AppModel,Camera,Selection} from './types';
import {selectionFocus} from './domain';
export class CircuitCanvas {
 svg:SVGSVGElement;layer:SVGGElement;camera:Camera;selected:Selection|null=null; cleanup:(()=>void)[]=[];
 private drag:{x:number;y:number;base:Camera;id:number;moved:boolean}|null=null;private suppress=false;
 private pending:{x:number;y:number;w:number;h:number}|null=null;
 private pendingNode:string|null=null;
 private focusedNode:string|null=null;private fullView=false;
 private navLabels=new Map<string,SVGTextElement>();private navWidths=new Map<string,number>();
 private netEls:Map<string,Element[]>;private nodeEls:Map<string,Element>;private onCamera:(c:Camera)=>void;
 constructor(public host:HTMLElement,public model:AppModel,svgText:string,onSelect:(s:Selection)=>void,onCamera:(c:Camera)=>void){
  host.innerHTML=svgText;this.svg=host.querySelector('svg')!;this.layer=this.svg.querySelector('.graph')!;this.onCamera=onCamera;
  // Page chrome already supplies the title and help. Remove the print-sheet
  // microtext around the graph, leaving the actual circuit untouched.
  for(const el of [...this.svg.children])if(['text','path'].includes(el.tagName.toLowerCase()))el.remove();
  const brief:Record<string,string[]>={sys:['SYS'],zero:['0'],pc:['PC'],im_guard:['IF','guard'],im:['IM'],dreg:['IF/ID'],decode:['Decode'],dfault:['D fault'],rf:['RF'],ext:['Imm'],xreg:['ID/EX'],mfwd_fault:['M fault'],fwd_select:['FWD','match'],fwd_rd:['Rd FWD'],fwd_rs:['Rs FWD'],a_mux:['A MUX'],b_mux:['B MUX'],alu:['ALU'],mreg:['EX/MEM'],mem_guard:['MEM','guard'],dm:['DM'],wreg:['MEM/WB'],wb_mux:['WB MUX'],wb_gates:['WB gate'],flags:['Flags'],z_select:['Z MUX'],branch:['Target'],hazard:['Load','use'],x_illegal:['EX','check'],events:['Event','priority'],fetch_ctl:['Fetch','control'],occupancy:['Valid','Fault'],stop:['Stop','token'],drain:['Drain'],mode:['Run','state'],status:['I/O'],trace:['Observe']};
  for(const n of model.nodes){const el=this.svg.querySelector(`[data-node="${n.id}"]`)!;const label=document.createElementNS('http://www.w3.org/2000/svg','text');label.classList.add('nav-label');label.setAttribute('text-anchor','middle');label.setAttribute('x',String(n.x+n.width/2));label.setAttribute('pointer-events','none');for(const [i,line]of (brief[n.id]||[n.id]).entries()){const t=document.createElementNS(label.namespaceURI,'tspan');t.textContent=line;t.setAttribute('x',String(n.x+n.width/2));t.setAttribute('dy',i?'1.25em':'0');label.append(t);}el.append(label);label.style.display='block';label.setAttribute('font-size','100');label.setAttribute('font-weight','700');this.navWidths.set(n.id,Math.max(...[...label.children].map(t=>(t as SVGTSpanElement).getComputedTextLength()))/100);label.style.removeProperty('display');this.navLabels.set(n.id,label);}
  this.svg.setAttribute('role','img');this.svg.setAttribute('aria-label','完整 CPU 数据通路图，可点击模块和连线；也可用左侧列表进行键盘操作');
  this.camera={x:0,y:0,w:model.width,h:model.height};this.netEls=new Map();
  this.svg.querySelectorAll('[data-net]').forEach(el=>{const id=(el as HTMLElement).dataset.net!;if(!this.netEls.has(id))this.netEls.set(id,[]);this.netEls.get(id)!.push(el);});
  this.nodeEls=new Map([...this.svg.querySelectorAll('[data-node]')].map(e=>[(e as HTMLElement).dataset.node!,e]));
  const listen=(target:EventTarget,type:string,fn:EventListener,opts?:AddEventListenerOptions)=>{target.addEventListener(type,fn,opts);this.cleanup.push(()=>target.removeEventListener(type,fn,opts));};
  listen(host,'wheel',((e:WheelEvent)=>{e.preventDefault();const r=host.getBoundingClientRect();this.zoom(Math.exp(e.deltaY*.001),e.clientX-r.left,e.clientY-r.top);}) as EventListener,{passive:false});
  listen(host,'pointerdown',((e:PointerEvent)=>{if(e.button||this.drag)return;this.drag={x:e.clientX,y:e.clientY,id:e.pointerId,base:{...this.camera},moved:false};}) as EventListener);
  listen(host,'pointermove',((e:PointerEvent)=>{const d=this.drag;if(!d||d.id!==e.pointerId)return;const dx=e.clientX-d.x,dy=e.clientY-d.y;if(Math.abs(dx)+Math.abs(dy)>5){d.moved=true;if(!host.hasPointerCapture(e.pointerId))host.setPointerCapture(e.pointerId);}if(d.moved){this.focusedNode=null;this.fullView=false;this.camera={...d.base,x:d.base.x-dx/host.clientWidth*d.base.w,y:d.base.y-dy/host.clientHeight*d.base.h};this.update();}}) as EventListener);
  listen(host,'pointerup',((e:PointerEvent)=>{if(this.drag&&this.drag.id!==e.pointerId)return;this.suppress=!!this.drag?.moved;this.drag=null;if(host.hasPointerCapture(e.pointerId))host.releasePointerCapture(e.pointerId);setTimeout(()=>this.suppress=false,0);}) as EventListener);
  listen(host,'pointercancel',(()=>{this.drag=null;this.suppress=false;}) as EventListener);
  listen(host,'lostpointercapture',(()=>{this.drag=null;}) as EventListener);
  listen(window,'pointerup',(()=>{this.drag=null;}) as EventListener);
  listen(this.svg,'click',((e:MouseEvent)=>{if(this.suppress)return;const el=e.target as Element;const n=el.closest('[data-net]'),b=el.closest('[data-node]');if(n)onSelect({kind:'net',id:(n as HTMLElement).dataset.net!});else if(b)onSelect({kind:'node',id:(b as HTMLElement).dataset.node!});}) as EventListener);
  const ro=new ResizeObserver(()=>{if(host.clientWidth&&host.clientHeight){if(this.pendingNode){const id=this.pendingNode;this.pendingNode=null;this.focusNode(id);}else if(this.focusedNode){this.focusNode(this.focusedNode);}else if(this.fullView){this.overview();}else{const b=this.pending||this.camera;this.pending=null;this.fit(b.x,b.y,b.w,b.h);}}});ro.observe(host);this.cleanup.push(()=>ro.disconnect());
  this.focusNode('pc');
 }
 update(){const c=this.camera,scale=this.host.clientWidth/c.w;this.svg.setAttribute('viewBox',`${c.x} ${c.y} ${c.w} ${c.h}`);this.svg.classList.toggle('low-detail',scale<.9);for(const n of this.model.nodes){const label=this.navLabels.get(n.id)!;const size=Math.min(16/scale,(n.width-24)/this.navWidths.get(n.id)!,(n.height-14)/(label.children.length*1.25));label.setAttribute('font-size',String(size));label.setAttribute('font-weight','700');label.setAttribute('y',String(n.y+n.height/2-(label.children.length>1?size*.25:-size*.3)));}this.onCamera({...c});}
 fit(x:number,y:number,w:number,h:number){const r=this.host.clientWidth/this.host.clientHeight;if(!r||!Number.isFinite(r)){this.pending={x,y,w,h};return;}this.pending=null;const cw=Math.max(w,h*r);this.camera={x:x+(w-cw)/2,y:y+(h-cw/r)/2,w:cw,h:cw/r};this.update();}
 overview(){this.focusedNode=null;this.pendingNode=null;this.fullView=true;const bs=[...this.model.nets.map(n=>n.bounds),...this.model.nodes];const x=Math.min(...bs.map(b=>b.x)),y=Math.min(...bs.map(b=>b.y)),r=Math.max(...bs.map(b=>b.x+b.width)),d=Math.max(...bs.map(b=>b.y+b.height));this.fit(x+80-50,y+285-50,r-x+100,d-y+100);}
 focusNode(id:string){const n=this.model.nodes.find(n=>n.id===id);if(!n)return;this.focusedNode=id;this.fullView=false;if(!this.host.clientWidth||!this.host.clientHeight){this.pendingNode=id;return;}this.pendingNode=null;this.pending=null;const hw=this.host.clientWidth,hh=this.host.clientHeight;const fitScale=Math.min(hw/(n.width+120),hh/(n.height+120));const scale=Math.max(.92,Math.min(1.1,fitScale)),w=hw/scale,h=hh/scale;this.camera={x:n.x+80+(n.width+80>w?-24:(n.width-w)/2),y:n.y+285+(n.height+120>h?-45:(n.height-h)/2),w,h};this.update();}
 fitNodes(ids:string[]){this.focusedNode=null;this.pendingNode=null;this.fullView=false;const ns=this.model.nodes.filter(n=>ids.includes(n.id));if(!ns.length)return;const x=Math.min(...ns.map(n=>n.x)),y=Math.min(...ns.map(n=>n.y));this.fit(x+80-120,y+285-120,Math.max(...ns.map(n=>n.x+n.width))-x+240,Math.max(...ns.map(n=>n.y+n.height))-y+240);}
 fitNet(id:string){this.focusedNode=null;this.pendingNode=null;this.fullView=false;const n=this.model.nets.find(n=>n.id===id);if(n){const b=n.bounds;this.fit(b.x+80-100,b.y+285-100,Math.max(350,b.width+200),Math.max(250,b.height+200));}}
 zoom(f:number,x=this.host.clientWidth/2,y=this.host.clientHeight/2){if(!this.host.clientWidth||!this.host.clientHeight)return;this.focusedNode=null;this.pendingNode=null;this.fullView=false;const c=this.camera;f=Math.max(400/c.w,Math.min(this.model.width*1.6/c.w,f));const px=c.x+x/this.host.clientWidth*c.w,py=c.y+y/this.host.clientHeight*c.h;this.camera={x:px-x/this.host.clientWidth*c.w*f,y:py-y/this.host.clientHeight*c.h*f,w:c.w*f,h:c.h*f};this.update();}
 panTo(x:number,y:number){this.focusedNode=null;this.pendingNode=null;this.fullView=false;this.camera={...this.camera,x:x-this.camera.w/2,y:y-this.camera.h/2};this.update();}
 restore(c:Camera){this.focusedNode=null;this.pendingNode=null;this.fullView=false;this.fit(c.x,c.y,c.w,c.h);}
 select(s:Selection|null){
  this.selected=s;
  const focus=selectionFocus(this.model,s),nets=new Set(focus.nets),nodes=new Set(focus.nodes);
  this.layer.classList.toggle('selected',nodes.size>0);
  this.layer.classList.toggle('net-selection',s?.kind==='net');
  for(const [id,els]of this.netEls)els.forEach(el=>el.classList.toggle('active',nets.has(id)));
  for(const [id,el]of this.nodeEls){
   el.classList.toggle('active',nodes.has(id));
   el.classList.toggle('picked',s?.kind==='node'&&s.id===id);
  }
 }
 emphasis(value:string){this.layer.classList.toggle('data-focus',value==='data');this.layer.classList.toggle('control-focus',value==='control');}
 exportSvg(){const clone=this.svg.cloneNode(true) as SVGSVGElement;clone.classList.remove('low-detail');clone.querySelectorAll('.nav-label').forEach(e=>e.remove());clone.setAttribute('viewBox',`0 0 ${this.model.width} ${this.model.height}`);clone.setAttribute('width',String(this.model.width));clone.setAttribute('height',String(this.model.height));clone.querySelectorAll('.selected,.active,.picked,.net-selection,.data-focus,.control-focus').forEach(e=>e.classList.remove('selected','active','picked','net-selection','data-focus','control-focus'));return new XMLSerializer().serializeToString(clone);}
 destroy(){this.cleanup.forEach(f=>f());this.host.innerHTML='';}
}
