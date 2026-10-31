import React from 'react';
import type {Node,Semantic} from './types';
import {tabKeys} from '../../src/tab-keys';
export type DetailPane='explain'|'connections'|'source';
type Props={node:Node;semantic:Semantic;pane:DetailPane;onPane:(pane:DetailPane)=>void;onWbData:()=>void;source:React.ReactNode;inputs:React.ReactNode;outputs:React.ReactNode};
export function ModuleInfo({node,semantic,pane,onPane,onWbData,source,inputs,outputs}:Props){
 const panes=[['explain','工作原理'],['connections','输入与输出'],['source','当前源码']] as const;
 return <><div className="inspector-heading"><h2>{node.title.split('|')[0].trim()}</h2><p>{semantic.name}</p></div><div className="inspector-tabs" role="tablist" aria-label="模块详情内容" onKeyDown={event=>tabKeys(event,index=>onPane(panes[index][0]))}>{panes.map(([key,title])=><button role="tab" key={key} id={node.id+'-tab-'+key} aria-controls={node.id+'-detail-pane'} aria-selected={pane===key} tabIndex={pane===key?0:-1} className={pane===key?'active':''} onClick={()=>onPane(key)}>{title}</button>)}</div><div role="tabpanel" id={node.id+'-detail-pane'} aria-labelledby={node.id+'-tab-'+pane}>
 {pane==='source'?source:pane==='connections'?<>{inputs}{outputs}</>:<><p className="purpose">{semantic.purpose}</p><ol className="behavior">{semantic.how.map((text,i)=><li key={i}>{text}</li>)}</ol><div className="detail-path-summary"><span>{node.ins.length} 条输入</span><span>{node.outs.length} 条输出</span><button onClick={()=>onPane('connections')}>查看连接 →</button></div>{node.id==='rf'&&<button className="wide-button" onClick={onWbData}>查看 wb_data 全部分支 →</button>}</>}
 </div></>;
}
