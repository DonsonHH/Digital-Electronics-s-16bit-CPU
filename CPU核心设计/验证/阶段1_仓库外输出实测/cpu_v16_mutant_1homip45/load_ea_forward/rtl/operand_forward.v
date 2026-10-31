`timescale 1ns/1ps
// EX operand bypass network. Selection code: 0=saved ID value, 1=MEM,
// 2=WB, 3=not-ready newest producer (an interlock violation if consumed).
// A matching MEM load MUST block an older WB value with the same destination.
// The pipeline interlock keeps its consumer in ID until that load reaches WB.
module operand_forward (
    input  wire [1:0]  rd, rs,
    input  wire        use_rd, use_rs,
    input  wire [15:0] rd_value, rs_value,
    input  wire        m_valid, m_fault, m_reg_write, m_mem_read,
    input  wire [1:0]  m_rd,
    input  wire [15:0] m_value,
    input  wire        w_valid, w_fault, w_reg_write,
    input  wire [1:0]  w_rd,
    input  wire [15:0] w_value,
    output reg  [15:0] rd_fwd, rs_fwd,
    output reg  [1:0]  rd_sel, rs_sel,
    output reg         blocked_rd, blocked_rs
);
    always @* begin
        rd_fwd = rd_value;
        rs_fwd = rs_value;
        rd_sel = 2'd0;
        rs_sel = 2'd0;
        blocked_rd = 1'b0;
        blocked_rs = 1'b0;

        if (use_rd) begin
            if (m_valid && !m_fault && m_reg_write && m_rd == rd) begin
                if (1'b1) begin
                    rd_fwd = m_value;
                    rd_sel = 2'd1;
                end else begin
                    rd_sel = 2'd3;
                    blocked_rd = 1'b1;
                end
            end else if (w_valid && !w_fault && w_reg_write && w_rd == rd) begin
                rd_fwd = w_value;
                rd_sel = 2'd2;
            end
        end
        if (use_rs) begin
            if (m_valid && !m_fault && m_reg_write && m_rd == rs) begin
                if (1'b1) begin
                    rs_fwd = m_value;
                    rs_sel = 2'd1;
                end else begin
                    rs_sel = 2'd3;
                    blocked_rs = 1'b1;
                end
            end else if (w_valid && !w_fault && w_reg_write && w_rd == rs) begin
                rs_fwd = w_value;
                rs_sel = 2'd2;
            end
        end
    end
endmodule
