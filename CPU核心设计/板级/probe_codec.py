"""Public VIO snapshot decoding; no device access and no assumption of successful execution."""
import re
def probe_integer(value,width):
 text=str(value).strip().lower().replace('_','')
 if text.startswith('0b'):
  text=text[2:]
  if not re.fullmatch('[01]+',text):raise ValueError('Invalid binary probe value')
  number=int(text,2)
 else:
  if text.startswith('0x'):text=text[2:]
  if not re.fullmatch('[0-9a-f]+',text):raise ValueError('Probe contains unknown/unrecognized values')
  number=int(text,16)
 if number.bit_length()>width:raise ValueError('Probe width exceeded')
 return number
def decode(state,perf):
 state=probe_integer(state,256);perf=probe_integer(perf,160)
 return {'build_id':f'{state>>192:016x}','rf':[(state>>(16*i))&0xffff for i in range(4)],
  'flags':[(state>>66)&1,(state>>65)&1,(state>>64)&1],'stop_pc':(state>>67)&0xffff,
  'stop_reason':(state>>83)&7,'stop_valid':(state>>86)&1,'stop_pc_valid':(state>>87)&1,
  'halted':(state>>88)&1,'fault':(state>>89)&1,'last_completed_valid':(state>>90)&1,
  'last_completed_pc':(state>>91)&0xffff,'last_store_valid':(state>>107)&1,
  'last_store_addr':(state>>108)&0xffff,'last_store_data':(state>>124)&0xffff,
  'core_reset':(state>>140)&1,'heartbeat':(state>>141)&1,'reserved':(state>>142)&((1<<50)-1),
  **dict(zip(['cycles','completed','stalls','redirects','stores'],[(perf>>(32*i))&0xffffffff for i in range(5)]))}
