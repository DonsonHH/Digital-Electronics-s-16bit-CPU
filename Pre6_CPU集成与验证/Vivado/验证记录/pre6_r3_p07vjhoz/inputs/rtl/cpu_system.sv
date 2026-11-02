`timescale 1ns/1ps
// Minimal file-boot system. rst is synchronous and active high, as in the core.
// Board clocks/button synchronization and physical IO belong to a later wrapper.
module cpu_system #(
    parameter IM_INIT_FILE="programs/all_ops_im.mem",
    parameter DM_INIT_FILE="programs/all_ops_dm.mem"
)(
    input wire clk, rst,
    output wire halted, fault,
    output wire observe_wb_valid, observe_wb_fault, observe_wb_halt, observe_wb_store,
    output wire observe_rf_we, observe_z_we, observe_cv_we,
    output wire [1:0] observe_wb_rd,
    output wire [15:0] observe_wb_pc, observe_wb_data,
    output wire [2:0] observe_wb_flags,
    output wire observe_stall, observe_redirect,
    output wire [15:0] observe_fetch_pc,
    output wire [3:0] observe_pipeline_valid,
    output wire [2:0] observe_flags,
    output wire stop_valid, stop_pc_valid,
    output wire [15:0] stop_pc,
    output wire [2:0] stop_reason,
    output wire last_completed_valid,
    output wire [15:0] last_completed_pc,
    output wire [63:0] rf_snapshot,
    output wire observe_mem_en, observe_mem_we,
    output wire [15:0] observe_mem_addr, observe_mem_data,
    output reg last_store_valid,
    output reg [15:0] last_store_addr, last_store_data
);
    wire [15:0] im_addr,im_dout,dm_dout;
    wire im_en;
    datapath_core core(
        .clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),
        .dm_addr(observe_mem_addr),.dm_en(observe_mem_en),.dm_we(observe_mem_we),
        .dm_din(observe_mem_data),.dm_dout(dm_dout),.halted(halted),.fault(fault),
        .observe_wb_valid(observe_wb_valid),.observe_wb_fault(observe_wb_fault),
        .observe_wb_halt(observe_wb_halt),.observe_wb_store(observe_wb_store),
        .observe_rf_we(observe_rf_we),.observe_z_we(observe_z_we),.observe_cv_we(observe_cv_we),
        .observe_wb_rd(observe_wb_rd),.observe_wb_pc(observe_wb_pc),.observe_wb_data(observe_wb_data),
        .observe_wb_flags(observe_wb_flags),.observe_stall(observe_stall),.observe_redirect(observe_redirect),
        .observe_fetch_pc(observe_fetch_pc),.observe_pipeline_valid(observe_pipeline_valid),.observe_flags(observe_flags),
        .stop_valid(stop_valid),.stop_pc_valid(stop_pc_valid),.stop_pc(stop_pc),.stop_reason(stop_reason),
        .last_completed_valid(last_completed_valid),.last_completed_pc(last_completed_pc)
    );
    // Core qualifies the FULL 16-bit address before this physical 8-bit index.
    instruction_memory #(.INIT_FILE(IM_INIT_FILE)) im(
        .clk(clk),.en(im_en),.addr(im_addr[7:0]),.dout(im_dout));
    data_memory #(.INIT_FILE(DM_INIT_FILE)) dm(
        .clk(clk),.en(observe_mem_en),.we(observe_mem_we),.addr(observe_mem_addr[7:0]),
        .din(observe_mem_data),.dout(dm_dout));

    // Debug shadow mirrors qualified committed writes; it is NOT an RF port
    // and has no influence on operands or any execution decision.
    reg [15:0] rf_shadow[0:3];
    integer i;
    assign rf_snapshot={rf_shadow[3],rf_shadow[2],rf_shadow[1],rf_shadow[0]};
    always @(posedge clk) begin
        if(rst) begin
            for(i=0;i<4;i=i+1) rf_shadow[i]<=0;
            last_store_valid<=0;last_store_addr<=0;last_store_data<=0;
        end else begin
            if(observe_rf_we) rf_shadow[observe_wb_rd]<=observe_wb_data;
            if(observe_mem_we) begin
                last_store_valid<=1;
                last_store_addr<=observe_mem_addr;
                last_store_data<=observe_mem_data;
            end
        end
    end
endmodule
