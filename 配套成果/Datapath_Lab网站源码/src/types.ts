export type Port = { id:string; signal:string; width:number; label:string; role:'in'|'out'; side:'EAST'|'WEST'; y:number };
export type Node = {id:string;title:string;rtl:string;category:string;zone:string;notes:string[];x:number;y:number;width:number;height:number;reverse?:boolean;ins:Port[];outs:Port[];pairs?:[string,string][]};
export type Net = {id:string;signal:string;width:number;sourceNode:string;targets:{node:string;signal:string;port:string;width:number;slice?:[number,number]|null}[];bounds:{x:number;y:number;width:number;height:number}};
export type Rule = {node:string;input:string;output:string;rhs:string};
export type Guide = {id:string;name:string;instruction:string;assumption:string;steps:[string,string,string,string][]};
export type Semantic = {name:string;purpose:string;how:string[];questions:string[];source:{file:string;start:number;text:string};role:string;extraSources?:{file:string;start:number;text:string}[]};
export type AppModel = {nodes:Node[];nets:Net[];captureRules:Rule[];aliases:Record<string,string>;guides:Guide[];semantics:Record<string,Semantic>;width:number;height:number;offset:{x:number;y:number};connectionCount:number;sourceHashes:Record<string,string>;review:{registerFields:number;sourceDate:string;version:string;isaVersion:string;changedRoutes:number;scope:string}};
export type Selection = {kind:'node'|'net';id:string};
export type Camera = {x:number;y:number;w:number;h:number};
declare global {interface Window {CPU_MODEL:AppModel;CPU_SVG:string;__CPU_TEST__?:unknown}}
