"""Frozen 48 directed vectors; no random seed or native execution side effects."""
from .isa_reference import ins,oracle

cases=[]
def add(label,words,dm=None,rf=None,flags=None,stalls=-1,cycles=-1,reset=0):
    image=[0xb000]*256
    for p,w in (words.items() if isinstance(words,dict) else enumerate(words)):
        if not 0<=p<256:raise ValueError('Program too long')
        image[p]=w
    memory=[(i*0x103+0xa55a)%65536 for i in range(256)]
    for p,w in (dm or {}).items(): memory[p]=w
    r=rf or [0,0,0,0];f=flags or [0,0,0]
    expected=oracle(image,memory,r,f)
    cases.append(dict(label=label,image=image,initial_dm=memory,initial_rf=r,initial_flags=f,expected=expected,stalls=stalls,cycles=cycles,reset=reset))

add('THREE_WRITERS_R0',[ins(1,0,b=1),ins(5,0,b=1),ins(5,0,b=1),ins(0,1,0),ins(4,0,1),ins(14)],stalls=0,cycles=10)
add('LATEST_LOAD_MANY_CONSUMERS',[ins(1,3,b=32),ins(1,0,b=1),ins(5,0,b=2),ins(8,0,3),ins(5,0,b=1),ins(0,1,0),ins(4,2,0),ins(9,2,3,1),ins(14)],dm={32:0x7fff},stalls=1,cycles=14)
add('STR_DATA_LOAD_W_BASE_M',[ins(1,3,b=32),ins(8,0,3),ins(1,1,b=33),ins(9,0,1),ins(8,2,1),ins(10,2,0),ins(13,b=1),ins(15),ins(14)],dm={32:0xbeef},stalls=1)
add('STR_DATA_M_BASE_W',[ins(1,1,b=33),ins(1,0,b=85),ins(9,0,1),ins(8,2,1),ins(14)],stalls=0,cycles=9)
add('LOAD_R0_RD_RS_SAME',[ins(1,3,b=32),ins(8,0,3),ins(9,0,0),ins(8,1,0),ins(10,1,0),ins(13,b=1),ins(11),ins(14)],dm={32:33},stalls=2)
add('FALSE_IMMEDIATE_RS',[ins(1,3,b=32),ins(8,0,3),ins(5,2,0,255),ins(7,1,0,255),ins(1,0,0,7),ins(14)],stalls=0,cycles=10)
add('WB_ID_AND_OVERWRITES',[ins(1,0,b=1),ins(1,1,b=2),ins(1,2,b=3),ins(5,0,b=1),ins(5,0,b=1),ins(0,3,0),ins(14)],stalls=0,cycles=11)
add('CMP_101_JZ',[ins(1,1,b=1),ins(10,0,0),ins(10,0,1),ins(10,1,1),ins(13,b=1),ins(9,1,0),ins(14)],stalls=0)
add('CMP_010_JZ',[ins(1,1,b=1),ins(10,0,1),ins(10,0,0),ins(10,0,1),ins(13,b=1),ins(1,2,b=85),ins(14)],stalls=0,cycles=11)
add('CMP_ACROSS_ALU_STORE_LOAD',[ins(1,3,b=32),ins(8,0,3),ins(10,0,0),ins(5,0,b=1),ins(7,0,b=1),ins(9,0,3,1),ins(8,1,3,1),ins(13,b=1),ins(15),ins(14)],dm={32:1},stalls=1)
add('CMP_LOAD_JZ_W_FALLBACK',[ins(1,3,b=32),ins(10,0,0),ins(8,0,3),ins(13,b=1),ins(9,0,3),ins(14)],dm={32:0xff55},stalls=0)
add('REFETCH_CANCELLED_HALT',[ins(10,0,0),ins(13,b=1),ins(9,0,0),ins(14),ins(9,0,0),ins(15)],stalls=0,cycles=9)
add('REFETCH_CANCELLED_STR',[ins(1,3,b=32),ins(1,0,b=85),ins(12,b=4),ins(14),ins(9,0,3),ins(14),ins(15)],stalls=0,cycles=11)
add('REFETCH_CANCELLED_RESERVED',[ins(12,b=2),ins(14),ins(15),ins(9,0,0)],stalls=0,cycles=8)
add('LOAD_BEFORE_HALT',[ins(1,3,b=32),ins(8,0,3),ins(14),ins(9,0,3,1)],dm={32:0x1234},stalls=0,cycles=7)
add('LEGAL_STR_BEFORE_HALT',[ins(1,3,b=32),ins(1,0,b=85),ins(9,0,3),ins(14),ins(9,1,3)],stalls=0,cycles=8)
add('MEM_FAULT_OVER_BRANCH',[ins(1,1,b=255),ins(5,0,b=1),ins(8,2,1,1),ins(12,b=5),ins(9,0,0),ins(14)],stalls=0)
add('MEM_FAULT_OVER_JZ',[ins(10,0,0),ins(1,1,b=255),ins(8,2,1,1),ins(13,b=1),ins(9,0,0),ins(14)],stalls=0)
add('MEM_FAULT_WITH_LOAD_USE',[ins(1,3,b=32),ins(1,0,b=255),ins(8,0,0,1),ins(8,1,3),ins(0,2,1),ins(14)],dm={32:7})
add('STR_BEFORE_MEM_FAULT',[ins(1,3,b=255),ins(1,0,b=85),ins(9,0,3),ins(8,1,3,1),ins(12,b=6),ins(9,1,0),ins(14)],stalls=0)
add('STR_BEFORE_RESERVED',[ins(1,3,b=32),ins(1,0,b=85),ins(9,0,3),ins(11),ins(15),ins(9,1,3)],stalls=0,cycles=8)
add('CONSECUTIVE_RESERVED',[ins(1,0,b=1),ins(15),ins(11),ins(14)],stalls=0,cycles=6)
add('EA_UPPER_FAULT_NO_ALIAS',[ins(1,1,b=255),ins(1,0,b=85),ins(9,0,1,1),ins(14)],dm={0:0xcafe,255:0xbeef},stalls=0)
add('EA_NEGATIVE_FAULT_NO_ALIAS',[ins(1,0,b=85),ins(9,0,1,-1),ins(14)],dm={255:0xbeef},stalls=0)
add('EA_MODULO_WRAP',[ins(1,3,b=32),ins(8,1,3),ins(1,0,b=85),ins(9,0,1,1),ins(8,2,1,1),ins(14)],dm={32:65535},stalls=0,cycles=10)
add('JZ_S8_LOW_PC_WRAP',[ins(10,0,0),ins(13,b=-128)],stalls=0)
add('FETCH_256_CORRECT_PATH',{0:ins(12,b=255),255:ins(1,0,b=1)},stalls=0,cycles=9)
add('FETCH_256_SQUASH',{0:ins(12,b=255),255:ins(12,b=2),2:ins(14)},stalls=0,cycles=11)

long=[ins(1,3,b=32),ins(1,0,b=1)]
for n in range(18):
    long += [ins(9,0,3,n%8),ins(8,1,3,n%8),ins(5,1,b=1),ins(10,1,0),ins(13,b=1),ins(5,0,b=1),ins(10,0,1),ins(13,b=1),ins(15),ins(2,0,1),ins(3,0,1)]
long += [ins(14)]
add('LONG_ALTERNATING_18_ROUNDS',long,stalls=18)
add('LONG_LOOP_MEMORY_CONSUMERS',[ins(1,3,b=32),ins(1,0,b=15),ins(1,1,b=0),ins(9,0,3),ins(8,2,3),ins(5,2,b=1),ins(5,2,b=1),ins(10,2,0),ins(13,b=5),ins(7,0,b=1),ins(10,0,1),ins(13,b=2),ins(12,b=3),ins(15),ins(14)],stalls=15)
add('FLAGS_CV_Z_LONG_LIFETIMES',[ins(1,3,b=32),ins(8,0,3),ins(8,1,3,1),ins(4,0,1),ins(10,1,1),ins(9,0,3,3),ins(8,2,3,3),ins(2,2,0),ins(3,2,1),ins(13,b=1),ins(15),ins(6,0,1),ins(14)],dm={32:0x7fff,33:1},stalls=2)
add('IGNORED_FIELDS_BOTH_SIGNS',[ins(1,3,2,32),ins(1,0,1,255),ins(0,1,0,255),ins(5,1,3,255),ins(7,1,2,255),ins(2,0,1,255),ins(3,0,1,128),ins(10,0,1,255),ins(13,3,3,1),ins(15),ins(14,3,3,255)],stalls=0)
add('SUPP_MOV_ALU_TO_CMP',[ins(1,1,b=1),ins(1,0,b=1),ins(10,0,1),ins(13,b=1),ins(15),ins(14)],stalls=0,cycles=11)
add('SUPP_G1_INTERVENING_LOAD_STALL',[ins(1,3,b=32),ins(8,0,3),ins(8,1,0),ins(4,2,0),ins(14)],dm={32:33,33:5},stalls=1,cycles=10)

# The four formal Buffer/Interlock tables intentionally use their stated RF fixtures.
add('DOC_ADD_ADD',[0x4100,0x4800,0xe000],rf=[1,2,4,0],stalls=0,cycles=7)
add('DOC_LOAD_STR',[0x8300,0x9100,0xe000],rf=[0,33,0,32],dm={32:7},stalls=1,cycles=8)
add('DOC_CMP_JZ',[0xa100,0xd001,0x9300,0xe000],rf=[1,1,0,32],stalls=0,cycles=9)
add('DOC_STR_HALT',[0x9100,0xe000,0x9900],rf=[0xbeef,33,0x1234,0],stalls=0,cycles=6)

# Reset tests run a checked prefix, then discard in-flight instructions and restart.
reset_program=[ins(1,3,b=32),ins(1,0,b=85),ins(9,0,3),ins(1,2,b=0),ins(8,1,3),ins(5,1,b=1),ins(10,1,0),ins(13,b=1),ins(12,b=10),ins(15),ins(14)]
for code,label in [(1,'RESET_LOAD_USE'),(2,'RESET_REDIRECT'),(3,'RESET_DRAIN_HALT'),(4,'RESET_BEFORE_STORE'),(5,'RESET_AFTER_STORE'),(6,'RESET_HALT_WB')]:
    add(label,reset_program,reset=code)
for code,label in [(7,'RESET_DRAIN_FAULT'),(8,'RESET_FAULT_WB'),(9,'RESET_HALTED'),(10,'RESET_FAULTED')]:
    add(label,[ins(1,0,b=1),ins(11) if code in (7,8,10) else ins(14),ins(9,0,0)],reset=code)
