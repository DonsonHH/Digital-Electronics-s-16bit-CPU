`timescale 1ns/1ps
// Unit regression for specification v1.4. Counts printed at end are actual
// tested ranges, not a claim of 2^33 CLA16 or 2^35 ALU input exhaustion.
module tb_units;
    reg clk=0;
    integer i,j,k,s,mode,old,mask,input_bits,word,pat;
    integer cla4_count=0,cla16_count=0,addsub_count=0,alu_count=0;
    integer decode_count=0,imm_count=0,flags_count=0,rf_count=0;
    integer pc_count=0,target_count=0;
    integer fd;
    reg [31:0] rng=32'h4C413134;

    reg [3:0] a4,b4;
    reg cin4;
    wire [3:0] sum4;
    wire cout4,P4,G4;
    cla4_pg u_cla4(.a(a4),.b(b4),.cin(cin4),.sum(sum4),.cout(cout4),.P(P4),.G(G4));

    reg [15:0] a,b;
    reg cin,sub;
    reg [2:0] op;
    wire [15:0] sum16,arithmetic_result,alu_result;
    wire cout16,arith_c,arith_v,eq,illegal,alu_c,alu_v;
    cla16 u_cla16(.a(a),.b(b),.cin(cin),.sum(sum16),.cout(cout16));
    addsub16_cla u_addsub(.a(a),.b(b),.sub(sub),.result(arithmetic_result),
        .carry(arith_c),.overflow(arith_v));
    alu16 u_alu(.a(a),.b(b),.op(op),.result(alu_result),.eq(eq),
        .illegal(illegal),.carry(alu_c),.overflow(alu_v));

    reg [15:0] inst;
    wire [1:0] rd,rs,asel,bsel;
    wire [7:0] imm;
    wire [2:0] aluop;
    wire urd,urs,isigned,rw,mr,mw,zw,cvw,wb,ja,jz,halt,bad;
    wire [19:0] actual_control={urd,urs,asel,bsel,aluop,isigned,
        rw,mr,mw,zw,cvw,wb,ja,jz,halt,bad};
    reg [19:0] expected_control;
    isa_decode u_decode(.inst(inst),.rd(rd),.rs(rs),.imm(imm),
        .use_rd(urd),.use_rs(urs),.alu_a_sel(asel),.alu_b_sel(bsel),
        .alu_op(aluop),.imm_signed(isigned),.reg_write(rw),.mem_read(mr),
        .mem_write(mw),.z_write(zw),.cv_write(cvw),.wb_sel(wb),
        .jump_abs(ja),.jump_z(jz),.halt(halt),.illegal(bad));

    reg [7:0] ext_imm;
    reg ext_signed;
    wire [15:0] ext_value;
    imm_ext16 u_ext(.imm(ext_imm),.sign_mode(ext_signed),.value(ext_value));
    reg [15:0] branch_pc;
    reg [7:0] branch_imm;
    reg relative;
    wire [15:0] target;
    branch_target16 u_target(.branch_pc(branch_pc),.imm(branch_imm),
        .relative(relative),.target(target));

    reg flag_rst=1,z_we=0,cv_we=0,z_in=0,c_in=0,v_in=0;
    wire Z,C,V;
    reg [2:0] expected_flags;
    flags_reg u_flags(.clk(clk),.rst(flag_rst),.z_we(z_we),.cv_we(cv_we),
        .z_in(z_in),.c_in(c_in),.v_in(v_in),.Z(Z),.C(C),.V(V));

    reg rf_rst=1,rf_we=0;
    reg [1:0] waddr,ra,rb;
    reg [15:0] wdata;
    wire [15:0] rda,rdb;
    reg [15:0] rf_ref[0:3];
    regfile4x16 u_rf(.clk(clk),.rst(rf_rst),.we(rf_we),.waddr(waddr),
        .wdata(wdata),.raddr_a(ra),.raddr_b(rb),.rdata_a(rda),.rdata_b(rdb));

    reg pc_rst=1,pc_hold=0,pc_redirect=0;
    reg [15:0] pc_target;
    wire [15:0] pc;
    reg [15:0] expected_pc;
    pc16 u_pc(.clk(clk),.rst(pc_rst),.hold(pc_hold),.redirect(pc_redirect),
        .target(pc_target),.pc(pc));

    task automatic pulse;
        begin clk=0; #1; clk=1; #1; clk=0; #1; end
    endtask

    function automatic [31:0] random_next(input [31:0] x);
        reg [31:0] t;
        begin t=x^(x<<13);t=t^(t>>17);random_next=t^(t<<5);end
    endfunction

    // Independent arithmetic oracle: integer exact signed range for V,
    // unsigned comparison for SUB no-borrow; not the DUT Boolean V formula.
    task automatic arithmetic_oracle(input [15:0] x,y,input subtract,
        output [15:0] r,output c,v);
        integer exact_unsigned,signed_x,signed_y,exact_signed;
        begin
            signed_x=x[15] ? integer'(x)-65536 : integer'(x);
            signed_y=y[15] ? integer'(y)-65536 : integer'(y);
            if(subtract) begin
                exact_unsigned=integer'(x)+65536-integer'(y);
                exact_signed=signed_x-signed_y;
                c=(x>=y);
            end else begin
                exact_unsigned=integer'(x)+integer'(y);
                exact_signed=signed_x+signed_y;
                c=(exact_unsigned>65535);
            end
            r=exact_unsigned%65536;
            v=(exact_signed < -32768 || exact_signed > 32767);
        end
    endtask

    task automatic check_pair(input [15:0] x,y);
        integer f,t;
        reg [16:0] expected_sum;
        reg [15:0] expected_result;
        reg expected_c,expected_v,expected_bad;
        begin
            a=x;b=y;
            for(t=0;t<2;t=t+1) begin
                cin=t;sub=t;
                expected_sum={1'b0,x}+{1'b0,y}+t;
                arithmetic_oracle(x,y,t,expected_result,expected_c,expected_v);
                #1;
                if({cout16,sum16} !== expected_sum)
                    $fatal(1,"CLA16 a=%h b=%h cin=%0d got=%h expected=%h",x,y,t,{cout16,sum16},expected_sum);
                if({arith_c,arith_v,arithmetic_result} !== {expected_c,expected_v,expected_result})
                    $fatal(1,"ADD/SUB a=%h b=%h sub=%0d got=%h C/V=%b%b expected=%h C/V=%b%b",x,y,t,arithmetic_result,arith_c,arith_v,expected_result,expected_c,expected_v);
                cla16_count=cla16_count+1;addsub_count=addsub_count+1;
            end
            for(f=0;f<8;f=f+1) begin
                op=f;expected_c=0;expected_v=0;expected_bad=0;
                case(f)
                    0: expected_result=y;
                    1: arithmetic_oracle(x,y,0,expected_result,expected_c,expected_v);
                    2: arithmetic_oracle(x,y,1,expected_result,expected_c,expected_v);
                    3: expected_result=x&y;
                    4: expected_result=x|y;
                    default: begin expected_result=0;expected_bad=1;end
                endcase
                #1;
                if({illegal,alu_c,alu_v,alu_result} !== {expected_bad,expected_c,expected_v,expected_result} || eq !== (x==y))
                    $fatal(1,"ALU a=%h b=%h op=%0d got=%h C/V=%b%b illegal=%b eq=%b",x,y,f,alu_result,alu_c,alu_v,illegal,eq);
                alu_count=alu_count+1;
            end
        end
    endtask

    function automatic [19:0] control_oracle(input [3:0] opcode);
        // Packed independently from both specification control tables.
        // {use[2], A[2], B[2], op[3], sign, RW/MR/MW/ZW/CVW/wb[6],
        //  jump_abs/jump_z/halt/illegal[4]}.
        begin
            case(opcode)
                0: control_oracle={2'b01,2'd0,2'd1,3'd0,1'b0,6'b100000,4'b0000};
                1: control_oracle={2'b00,2'd0,2'd2,3'd0,1'b0,6'b100000,4'b0000};
                2: control_oracle={2'b01,2'd2,2'd2,3'd1,1'b1,6'b110001,4'b0000};
                3: control_oracle={2'b11,2'd2,2'd2,3'd1,1'b1,6'b001000,4'b0000};
                4: control_oracle={2'b11,2'd1,2'd1,3'd1,1'b0,6'b100010,4'b0000};
                5: control_oracle={2'b10,2'd1,2'd2,3'd1,1'b0,6'b100010,4'b0000};
                6: control_oracle={2'b11,2'd1,2'd1,3'd2,1'b0,6'b100010,4'b0000};
                7: control_oracle={2'b10,2'd1,2'd2,3'd2,1'b0,6'b100010,4'b0000};
                8: control_oracle={2'b11,2'd1,2'd1,3'd3,1'b0,6'b100000,4'b0000};
                9: control_oracle={2'b11,2'd1,2'd1,3'd4,1'b0,6'b100000,4'b0000};
                10:control_oracle={2'b11,2'd1,2'd1,3'd0,1'b0,6'b000100,4'b0000};
                12:control_oracle={2'b00,2'd0,2'd0,3'd0,1'b0,6'b000000,4'b1000};
                13:control_oracle={2'b00,2'd0,2'd0,3'd0,1'b1,6'b000000,4'b0100};
                14:control_oracle={2'b00,2'd0,2'd0,3'd0,1'b0,6'b000000,4'b0010};
                default:control_oracle={2'b00,2'd0,2'd0,3'd0,1'b0,6'b000000,4'b0001};
            endcase
        end
    endfunction

    reg [4:0] cla4_wide,cla4_zero;
    reg saved_P,saved_G;
    reg [15:0] b_pattern,expected_ext,expected_target;
    integer signed_offset;
    initial begin
        // No all-vector waveform logging: this regression retains counts.
        // A short illustrative waveform belongs to the core demo TB.
        a4=0;b4=0;cin4=0;a=0;b=0;cin=0;sub=0;op=0;
        inst=0;ext_imm=0;ext_signed=0;
        branch_pc=0;branch_imm=0;relative=0;
        ra=0;rb=0;waddr=0;wdata=0;pc_target=0;
        pulse();rf_rst=0;pc_rst=0;flag_rst=0;
        for(i=0;i<4;i=i+1) rf_ref[i]=0;

        for(i=0;i<16;i=i+1) for(j=0;j<16;j=j+1) begin
            a4=i;b4=j;
            cla4_zero=i+j;
            for(k=0;k<2;k=k+1) begin
                cin4=k;cla4_wide=i+j+k;#1;
                if({cout4,sum4} !== cla4_wide || P4 !== (&(a4^b4)) || G4 !== cla4_zero[4])
                    $fatal(1,"CLA4 sum/P/G mismatch a=%h b=%h cin=%0d",a4,b4,k);
                if(k==0) begin saved_P=P4;saved_G=G4;end
                else if(P4 !== saved_P || G4 !== saved_G)
                    $fatal(1,"CLA4 P/G depends on cin");
                cla4_count=cla4_count+1;
            end
        end

        for(word=0;word<65536;word=word+1) begin
            inst=word;expected_control=control_oracle(word>>12);#1;
            if(actual_control !== expected_control || rd !== inst[11:10] || rs !== inst[9:8] || imm !== inst[7:0])
                $fatal(1,"v1.4 decode word=%h control=%h expected=%h",inst,actual_control,expected_control);
            decode_count=decode_count+1;
        end
        for(mode=0;mode<2;mode=mode+1) for(i=0;i<256;i=i+1) begin
            ext_imm=i;ext_signed=mode;
            expected_ext=(mode && i>=128)?(i+65280):i;#1;
            if(ext_value !== expected_ext) $fatal(1,"immediate extension mismatch");
            imm_count=imm_count+1;
        end

        // 8 states x 2 reset values x 4 masks x 8 input values = 512.
        // Establishing an old state is deliberately not counted as a trial.
        for(old=0;old<8;old=old+1) for(s=0;s<2;s=s+1)
        for(mask=0;mask<4;mask=mask+1) for(input_bits=0;input_bits<8;input_bits=input_bits+1) begin
            flag_rst=0;z_we=1;cv_we=1;{z_in,c_in,v_in}=old[2:0];pulse();
            if({Z,C,V} !== old[2:0]) $fatal(1,"cannot establish old flag state");
            flag_rst=s;z_we=mask[1];cv_we=mask[0];{z_in,c_in,v_in}=input_bits[2:0];
            expected_flags=old[2:0];
            if(s) expected_flags=0;
            else begin
                if(mask[1]) expected_flags[2]=input_bits[2];
                if(mask[0]) expected_flags[1:0]=input_bits[1:0];
            end
            pulse();
            if({Z,C,V} !== expected_flags) $fatal(1,"flags state transition mismatch");
            flags_count=flags_count+1;
        end
        flag_rst=0;z_we=0;cv_we=0;

        // All 16-bit A values paired with four B patterns. This is NOT all B.
        for(i=0;i<65536;i=i+1) for(pat=0;pat<4;pat=pat+1) begin
            case(pat)
                0:b_pattern=0;
                1:b_pattern=1;
                2:b_pattern=16'hFFFF;
                3:b_pattern=~i[15:0];
            endcase
            check_pair(i[15:0],b_pattern);
        end
        for(i=0;i<20000;i=i+1) begin
            rng=random_next(rng);a=rng[15:0];
            rng=random_next(rng);b=rng[15:0];
            check_pair(a,b);
        end
        // Signed C/V examples, equality and long cross-group carries.
        check_pair(16'h8000,16'h8000);
        check_pair(16'h7FFF,16'hFFFF);
        check_pair(16'h1234,16'h1234);
        check_pair(16'h0005,16'h0003);
        check_pair(16'h0FFF,16'h0001);
        check_pair(16'hFFFF,16'h0001);

        // RF: every wdata at every write address, explicit pre-edge bypass
        // and post-edge stored value; other register is checked unchanged.
        for(j=0;j<4;j=j+1) for(i=0;i<65536;i=i+1) begin
            waddr=j;wdata=i;rf_we=1;ra=j;rb=(j+1)%4;#1;
            if(rda !== wdata || rdb !== rf_ref[(j+1)%4])
                $fatal(1,"RF WB-to-ID bypass or unrelated value mismatch");
            pulse();rf_ref[j]=i;rf_we=0;#1;
            if(rda !== rf_ref[j] || rdb !== rf_ref[(j+1)%4])
                $fatal(1,"RF stored write mismatch");
            rf_count=rf_count+1;
        end
        rf_we=0;wdata=16'hDEAD;pulse();
        for(i=0;i<4;i=i+1) for(j=0;j<4;j=j+1) begin
            ra=i;rb=j;#1;
            if(rda !== rf_ref[i] || rdb !== rf_ref[j]) $fatal(1,"RF read pair mismatch");
            rf_count=rf_count+1;
        end
        rf_rst=1;rf_we=1;wdata=16'hBEEF;ra=0;rb=3;pulse();
        if(rda !== 0 || rdb !== 0) $fatal(1,"RF reset must mask bypass and clear storage");
        rf_rst=0;rf_we=0;rf_count=rf_count+1;

        // PC: every sequential old-PC value (including FFFF wrap) plus
        // representative redirect/hold/reset priorities.
        pc_rst=1;pulse();pc_rst=0;pc_hold=0;pc_redirect=0;
        for(i=0;i<65536;i=i+1) begin
            expected_pc=(i+1)%65536;pulse();
            if(pc !== expected_pc) $fatal(1,"PC increment/wrap mismatch");
            pc_count=pc_count+1;
        end
        pc_hold=1;pc_redirect=1;pc_target=16'hACE1;pulse();pc_count=pc_count+1;
        if(pc !== 16'hACE1) $fatal(1,"redirect must win over hold");
        pc_redirect=0;pulse();pc_count=pc_count+1;
        if(pc !== 16'hACE1) $fatal(1,"hold must retain PC");
        pc_rst=1;pc_redirect=1;pc_target=16'hABCD;pulse();pc_count=pc_count+1;
        if(pc !== 0) $fatal(1,"reset must win over redirect/hold");
        pc_rst=0;pc_hold=1;pc_redirect=0;

        for(pat=0;pat<7;pat=pat+1) begin
            case(pat)
                0:branch_pc=0;1:branch_pc=1;2:branch_pc=16'h007F;
                3:branch_pc=16'h00FF;4:branch_pc=16'h7FFF;
                5:branch_pc=16'hFF80;6:branch_pc=16'hFFFF;
            endcase
            for(i=0;i<256;i=i+1) for(mode=0;mode<2;mode=mode+1) begin
                branch_imm=i;relative=mode;
                signed_offset=(i>=128)?i-256:i;
                expected_target=mode ? (integer'(branch_pc)+1+signed_offset) : i;#1;
                if(target !== expected_target) $fatal(1,"branch target mismatch");
                target_count=target_count+1;
            end
        end

        $display("UNITS_PASS CLA4=%0d CLA16=%0d ADD_SUB=%0d ALU=%0d DECODE=%0d IMM=%0d FLAGS=%0d RF=%0d PC=%0d TARGET=%0d",cla4_count,cla16_count,addsub_count,alu_count,decode_count,imm_count,flags_count,rf_count,pc_count,target_count);
        fd=$fopen("unit_results.json","w");
        if(!fd) $fatal(1,"cannot write unit_results.json");
        $fdisplay(fd,"{\"status\":\"PASS\",\"failures\":0,\"spec_version\":\"1.4\",\"cla4_exhaustive\":%0d,\"cla16_cases\":%0d,\"addsub_cases\":%0d,\"alu_cases\":%0d,\"decode_exhaustive\":%0d,\"immediate_exhaustive\":%0d,\"flags_transitions_exhaustive\":%0d,\"rf_transactions\":%0d,\"pc_transitions\":%0d,\"branch_target_cases\":%0d,\"arithmetic_scope\":\"all 65536 A values times four B patterns, 20000 deterministic random pairs, six directed pairs; both CLA cin and addsub modes, all eight ALU ops; not full pairwise input exhaustion\"}",cla4_count,cla16_count,addsub_count,alu_count,decode_count,imm_count,flags_count,rf_count,pc_count,target_count);
        $fclose(fd);
        $finish;
    end
endmodule
