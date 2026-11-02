`timescale 1ns/1ps
// Public synchronous application boundary; vendor debug/clock IP is outside.
module ees331_application #(
    parameter IM_INIT_FILE="programs/dut_im.mem",DM_INIT_FILE="programs/dut_dm.mem",
    parameter RELEASE_BITS=21,
    parameter [63:0] BUILD_ID=64'd0
)(input wire clk,reset_btn_n,debug_reset,
  output wire[255:0]state_probe,output wire[159:0]perf_probe,
  output wire[127:0]event_probe,output wire[7:0]led,output reg core_reset=1);
    // EES-331 S1 closes to GND. Synchronize the human request, then register
    // the effective core reset. No asynchronously controlled FF drives a RAM
    // enable. A store before effective reset may commit and is not rolled back.
    // Release requires a full stable interval after the synchronized request.
    wire async_request=!reset_btn_n||debug_reset;
    (* ASYNC_REG="TRUE", SHREG_EXTRACT="NO" *) reg[2:0] request_sync=3'b111;
    reg[RELEASE_BITS-1:0] release_count=0;
    always @(posedge clk)begin
        request_sync<={request_sync[1:0],async_request};
        if(request_sync[2])begin release_count<=0;core_reset<=1;end
        else if(core_reset)begin
            if(&release_count)core_reset<=0;
            else release_count<=release_count+1'b1;
        end
    end

    wire halted,fault,wb_valid,wb_fault,wb_halt,wb_store,rw,zw,cvw,stall,redirect;
    wire[1:0] rd;wire[15:0]pc,data,fetch_pc,stop_pc,last_pc,mem_addr,mem_data,last_addr,last_data;
    wire[2:0] wb_flags,flags,reason;wire[3:0]pipeline;
    wire stop_valid,pc_valid,last_valid,mem_en,mem_we,last_store_valid;wire[63:0]rf;
    cpu_system #(.IM_INIT_FILE(IM_INIT_FILE),.DM_INIT_FILE(DM_INIT_FILE)) system_i(
        .clk(clk),.rst(core_reset),.halted(halted),.fault(fault),
        .observe_wb_valid(wb_valid),.observe_wb_fault(wb_fault),.observe_wb_halt(wb_halt),.observe_wb_store(wb_store),
        .observe_rf_we(rw),.observe_z_we(zw),.observe_cv_we(cvw),.observe_wb_rd(rd),.observe_wb_pc(pc),.observe_wb_data(data),.observe_wb_flags(wb_flags),
        .observe_stall(stall),.observe_redirect(redirect),.observe_fetch_pc(fetch_pc),.observe_pipeline_valid(pipeline),.observe_flags(flags),
        .stop_valid(stop_valid),.stop_pc_valid(pc_valid),.stop_pc(stop_pc),.stop_reason(reason),.last_completed_valid(last_valid),.last_completed_pc(last_pc),
        .rf_snapshot(rf),.observe_mem_en(mem_en),.observe_mem_we(mem_we),.observe_mem_addr(mem_addr),.observe_mem_data(mem_data),
        .last_store_valid(last_store_valid),.last_store_addr(last_addr),.last_store_data(last_data));
    reg[31:0] cycles=0,completed=0,stalls=0,redirects=0,stores=0;
    always @(posedge clk)begin
        if(core_reset)begin cycles<=0;completed<=0;stalls<=0;redirects<=0;stores<=0;end
        else if(!halted&&!fault)begin
            cycles<=cycles+1'b1;
            if(wb_valid&&!wb_fault)completed<=completed+1'b1;
            if(stall)stalls<=stalls+1'b1;
            if(redirect)redirects<=redirects+1'b1;
            if(mem_we)stores<=stores+1'b1;
        end
    end
    reg[25:0] heartbeat=0;
    always @(posedge clk)heartbeat<=heartbeat+1'b1;
    // Stable fields only at stop; live heartbeat and reset are explicitly separate.
    assign state_probe={BUILD_ID,50'd0,heartbeat[25],core_reset,last_data,last_addr,last_store_valid,
                        last_pc,last_valid,fault,halted,pc_valid,stop_valid,reason,stop_pc,flags,rf};
    assign perf_probe={stores,redirects,stalls,completed,cycles};
    assign event_probe={27'd0,core_reset,fetch_pc,pipeline,redirect,stall,mem_data,mem_addr,mem_we,mem_en,
                        wb_flags,data,pc,rd,cvw,zw,rw,wb_store,wb_halt,wb_fault,wb_valid};
    assign led={reason,fault,halted,stop_valid,core_reset,heartbeat[25]};
endmodule
