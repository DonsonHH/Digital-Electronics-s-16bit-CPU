from pathlib import Path
import json
work=Path(__file__).parent
d=json.loads((work/'figure_semantics.json').read_text(encoding='utf-8'))
issues=[]
for f in d['figures']:
 for net in f['nets']:
  for a,b in zip(net['points'],net['points'][1:]):
   for n in f['nodes']:
    if n['container']:continue
    x,y,w,h=[n[k] for k in ['x','y','width','height']]
    if a[0]==b[0]:cross=x+2<a[0]<x+w-2 and max(min(a[1],b[1]),y+2)<min(max(a[1],b[1]),y+h-2)
    elif a[1]==b[1]:cross=y+2<a[1]<y+h-2 and max(min(a[0],b[0]),x+2)<min(max(a[0],b[0]),x+w-2)
    else:raise AssertionError('Non-orthogonal path')
    if cross:issues.append((f['file'],net['id'],n['id'],a,b))
print('INTERIOR_CROSSINGS',len(issues))
for v in issues:print(v)
text_issues=[]
for f in d['figures']:
 for net in f['nets']:
  for a,b in zip(net['points'],net['points'][1:]):
   for t in f['text_boxes']:
    x1,y1,x2,y2=t['bbox'];pad=2
    if a[0]==b[0]:cross=x1-pad<a[0]<x2+pad and max(min(a[1],b[1]),y1-pad)<min(max(a[1],b[1]),y2+pad)
    else:cross=y1-pad<a[1]<y2+pad and max(min(a[0],b[0]),x1-pad)<min(max(a[0],b[0]),x2+pad)
    if cross:text_issues.append((f['file'],net['id'],t['text'],a,b))
print('TEXT_CROSSINGS',len(text_issues))
for v in text_issues:print(v)
overlaps=[];border=[];bounds=[]
for f in d['figures']:
 for i,t in enumerate(f['text_boxes']):
  a,b,c,e=t['bbox']
  if a<0 or b<0 or c>f['width'] or e>f['height']:bounds.append((f['file'],t['text']))
  for u in f['text_boxes'][i+1:]:
   x1,y1,x2,y2=u['bbox']
   if min(c,x2)-max(a,x1)>3 and min(e,y2)-max(b,y1)>3:overlaps.append((f['file'],t['text'],u['text']))
  for n in f['nodes']:
   if not n['container'] or n.get('stroke')=='none':continue
   x,y,w,h=[n[k] for k in ['x','y','width','height']]
   hit=any(a+1<xx<c-1 and max(b+1,y)<min(e-1,y+h) for xx in [x,x+w]) or any(b+1<yy<e-1 and max(a+1,x)<min(c-1,x+w) for yy in [y,y+h])
   if hit:border.append((f['file'],n['id'],t['text']))
print('TEXT_OVERLAPS',len(overlaps),'BORDER_TEXT',len(border),'TEXT_BOUNDS',len(bounds))
for v in overlaps+border+bounds:print(v)
(work/'route_review.json').write_text(json.dumps({'crossings':issues,'text_crossings':text_issues,'text_overlaps':overlaps,'border_text_crossings':border,'text_bounds':bounds},ensure_ascii=False,indent=2),encoding='utf-8')
