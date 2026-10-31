`timescale 1ns/1ps
// ISA v1.4. Outputs are intent; core qualifies writes with valid/fault/reset.
// Unused raw fields remain visible but use masks prevent false dependencies.
module isa_decode(
    input [15:0] inst,
    output [1:0] rd, rs,
    output [7:0] imm,
    output reg use_rd, use_rs,
    output reg [1:0] alu_a_sel, alu_b_sel,
    output reg [2:0] alu_op,
    output reg imm_signed,
    output reg reg_write, mem_read, mem_write, z_write, cv_write,
    output reg wb_sel, jump_abs, jump_z, halt, illegal
);
    assign rd = inst[11:10];
    assign rs = inst[9:8];
    assign imm = inst[7:0];
    always @* begin
        use_rd = 0; use_rs = 0;
        alu_a_sel = 0; alu_b_sel = 0; alu_op = 0;
        imm_signed = 0;
        reg_write = 0; mem_read = 0; mem_write = 0;
        z_write = 0; cv_write = 0; wb_sel = 0;
        jump_abs = 0; jump_z = 0; halt = 0; illegal = 0;
        case (inst[15:12])
            4'h0: begin // MOV Rd,Rs
                use_rs=1; alu_b_sel=1; reg_write=1;
            end
            4'h1: begin // MOV Rd,#u8
                alu_b_sel=2; reg_write=1;
            end
            4'h2: begin // LDR: only Rs is a source
                use_rs=1; alu_a_sel=2; alu_b_sel=2; alu_op=1;
                imm_signed=1; reg_write=1; mem_read=1; wb_sel=1;
            end
            4'h3: begin // STR: Rd=data, Rs=base; Rd is not ALU a
                use_rd=1; use_rs=1; alu_a_sel=2; alu_b_sel=2;
                alu_op=1; imm_signed=1; mem_write=1;
            end
            4'h4: begin
                use_rd=1; use_rs=1; alu_a_sel=1; alu_b_sel=1;
                alu_op=1; reg_write=1; cv_write=1;
            end
            4'h5: begin
                use_rd=1; alu_a_sel=1; alu_b_sel=2;
                alu_op=1; reg_write=1; cv_write=1;
            end
            4'h6: begin
                use_rd=1; use_rs=1; alu_a_sel=1; alu_b_sel=1;
                alu_op=2; reg_write=1; cv_write=1;
            end
            4'h7: begin
                use_rd=1; alu_a_sel=1; alu_b_sel=2;
                alu_op=2; reg_write=1; cv_write=1;
            end
            4'h8: begin
                use_rd=1; use_rs=1; alu_a_sel=1; alu_b_sel=1;
                alu_op=3; reg_write=1;
            end
            4'h9: begin
                use_rd=1; use_rs=1; alu_a_sel=1; alu_b_sel=1;
                alu_op=4; reg_write=1;
            end
            4'hA: begin // CMP: PASS_B output unused; eq compares Rd/Rs
                use_rd=1; use_rs=1; alu_a_sel=1; alu_b_sel=1;
                z_write=1;
            end
            4'hC: jump_abs=1;
            4'hD: begin jump_z=1; imm_signed=1; end
            4'hE: halt=1;
            default: illegal=1; // B/F and unknown opcodes never request writes
        endcase
    end
endmodule
