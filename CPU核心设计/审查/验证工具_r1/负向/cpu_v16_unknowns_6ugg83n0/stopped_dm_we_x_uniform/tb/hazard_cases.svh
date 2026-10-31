// Included only by EXTENDED mode; uses main reference/run_program tasks.
// 9 producers x 16 single source roles x 4 registers x 3 distances = 1728.
// 9 x 6 two-source consumers x 4 identical register pairs x 3 = 648.
for(hp=0;hp<=8;hp++)for(hc=0;hc<=10;hc++)begin
 if(hc!=1)for(hrole=0;hrole<3;hrole++)begin
  if((hrole==0&&(hc==2||hc==3||hc==4||hc==5||hc==6||hc==7||hc==9||hc==10))||
     (hrole==1&&(hc==0||hc==2||hc==3||hc==4||hc==6||hc==8||hc==9||hc==10))||
     (hrole==2&&(hc==2||hc==3||hc==4||hc==6||hc==9||hc==10)))begin
   for(hr=0;hr<4;hr++)for(hg=0;hg<3;hg++)begin
    generated_label=$sformatf("RAW_P%0h_C%0h_R%0d_S%0d_G%0d",hp,hc,hr,hrole,hg);clear_case(generated_label);
    hother=(hr+1)%4;hfill=(hr+2)%4;
    for(i=0;i<4;i++)initial_r[i]=32;
    case(hp)
     4:begin initial_r[hr]=16;initial_r[hother]=16;end
     5:initial_r[hr]=31;
     6:begin initial_r[hr]=33;initial_r[hother]=1;end
     7:initial_r[hr]=33;
    endcase
    dut.dm.mem[32]=32;
    load(0,16'((hp<<12)|(hr<<10)|(hother<<8)|((hp==1)?32:((hp==5||hp==7)?1:0))));
    for(i=0;i<hg;i++)load(i+1,16'((1<<12)|(hfill<<10)|15));
    hcrd=(hrole==0||hrole==2)?hr:hother;
    hcrs=(hrole==1||hrole==2)?hr:hother;
    load(hg+1,16'((hc<<12)|(hcrd<<10)|(hcrs<<8)|((hc==5||hc==7)?1:0)));
    load(hg+2,16'he000);
    hazard_pc=hg+1;hsel=(hg==0&&hp!=8)?1:((hg<=1)?2:0);
    hazard_rdsel=(hrole==0||hrole==2)?hsel:-1;
    hazard_rssel=(hrole==1||hrole==2)?hsel:-1;hazard_zsel=-1;
    run_program(-1,(hp==8&&hg==0)?1:0);raw_cases++;
   end
  end
 end
end
// LDR followed by MOV immediate: both raw register fields match variants,
// neither is an actual source. Each R0..R3 participates.
hazard_pc=-1;hazard_rdsel=-1;hazard_rssel=-1;
for(hr=0;hr<4;hr++)for(hcrd=0;hcrd<4;hcrd++)for(hcrs=0;hcrs<4;hcrs++)begin
 generated_label=$sformatf("FALSE_MOV_D%0d_R%0d_S%0d",hr,hcrd,hcrs);clear_case(generated_label);
 hother=(hr+1)%4;initial_r[hother]=32;dut.dm.mem[32]=7;
 load(0,16'h8000|(hr<<10)|(hother<<8));
 load(1,16'h1005|(hcrd<<10)|(hcrs<<8));load(2,16'he000);
 run_program(7,0);false_cases++;
end
// LDR overwrites the following LDR destination, but its base differs.
for(hr=0;hr<4;hr++)begin
 generated_label=$sformatf("FALSE_LDR_DEST_R%0d",hr);clear_case(generated_label);
 hother=(hr+1)%4;initial_r[hother]=32;dut.dm.mem[32]=7;dut.dm.mem[33]=9;
 load(0,16'h8000|(hr<<10)|(hother<<8));load(1,16'h8001|(hr<<10)|(hother<<8));load(2,16'he000);
 run_program(7,0);false_cases++;
end
// CMP/JZ equal and unequal for all register pairs and all 3 distances.
for(hcrd=0;hcrd<4;hcrd++)for(hcrs=0;hcrs<4;hcrs++)for(hg=0;hg<3;hg++)for(hrole=0;hrole<2;hrole++)begin
 if(!(hrole==1&&hcrd==hcrs))begin
  generated_label=$sformatf("FLAG_D%0d_S%0d_G%0d_NE%0d",hcrd,hcrs,hg,hrole);clear_case(generated_label);
  for(i=0;i<4;i++)initial_r[i]=1;
  if(hrole)initial_r[hcrs]=2;
  load(0,16'ha000|(hcrd<<10)|(hcrs<<8));
  for(i=0;i<hg;i++)load(i+1,16'h5801); // ADD changes C/V, not Z.
  load(hg+1,16'hd001);load(hg+2,16'h1c55);load(hg+3,16'he000);
  hazard_pc=hg+1;hazard_rdsel=-1;hazard_rssel=-1;hazard_zsel=(hg==0)?1:((hg==1)?2:0);
  run_program(-1,0);z_cases++;
 end
end
hazard_pc=-1;hazard_zsel=-1;
// Every younger side-effect class is canceled by a branch. The second young
// slot is STR, so both ID and IF cancellations must inhibit memory writes.
for(hc=0;hc<16;hc++)begin
 generated_label=$sformatf("FLUSH_CLASS_%0h",hc);clear_case(generated_label);
 initial_r[0]=1;initial_r[1]=32;initial_z=1;initial_c=1;initial_v=1;
 load(0,16'hc003);load(1,16'((hc<<12)|16'h0101));load(2,16'h9100);load(3,16'he000);
 run_program(8,0);cross_cases++;
end
// Back-to-back stores/loads: one DM port and one write per edge.
clear_case("MEM_BACK_TO_BACK");initial_r[0]=16'hcafe;initial_r[1]=32;
load(0,16'h9100);load(1,16'h9101);load(2,16'h8900);load(3,16'h8d01);load(4,16'he000);
run_program(9,0);cross_cases++;
clear_case("STR_THEN_HALT");initial_r[0]=16'hbeef;initial_r[1]=32;
load(0,16'h9100);load(1,16'he000);load(2,16'h9101);run_program(6,0);cross_cases++;
clear_case("STR_BEFORE_MEM_LOAD_FAULT");initial_r[0]=16'hcafe;initial_r[1]=255;
load(0,16'h9100);load(1,16'h8901);load(2,16'h1002);run_program(6,0);cross_cases++;
clear_case("MEM_FAULT_WITH_LOAD_USE");initial_r[0]=255;initial_r[1]=32;dut.dm.mem[32]=7;
load(0,16'h8001);load(1,16'h8500);load(2,16'h0100);load(3,16'he000);run_program(5,1);cross_cases++;
// Structured multi-writer sequences, newest load must not expose old WB.
clear_case("NEW_LOAD_AFTER_TWO_WRITERS");initial_r[3]=32;dut.dm.mem[32]=16'h005a;
load(0,16'h1001);load(1,16'h1002);load(2,16'h8300);load(3,16'h0400);load(4,16'he000);
hazard_pc=3;hazard_rssel=2;run_program(10,1);cross_cases++;
clear_case("CHAIN_R0");hazard_pc=-1;hazard_rssel=-1;
load(0,16'h1001);load(1,16'h5001);load(2,16'h5001);load(3,16'h4000);load(4,16'he000);
run_program(9,0);cross_cases++;
for(j=0;j<=12;j++)reset_probe(j,0);
for(j=4;j<=6;j++)reset_probe(j,1);
if(raw_cases!=2376||false_cases!=68||z_cases!=84||cross_cases!=22||reset_probes!=16)$fatal(1,"Hazard matrix count");
$display("HAZARDS_PASS raw=2376 false=68 flags=84 cross=22 total=2550 reset=16 failures=0");
