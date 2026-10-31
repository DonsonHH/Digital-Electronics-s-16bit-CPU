`timescale 1ns/1ps
// Experimental WB/MEM store-data bypass; stable AC1 is not modified.
// ISA v1.5. Every surviving instruction still reaches WB.
// External IM/DM each have ONE synchronous-read cycle and hold dout when en=0.
// IM dout itself is the IF/ID instruction boundary; DM dout is the WB load
// boundary. Adding another same-edge IR/MDR here would misalign the tags.
// The core includes just enough hardwired control to execute and validate the
// datapath. Stops are tokens which reach WB, not a serial IF-to-WB controller.
module datapath_core (
    input  wire        clk,
    input  wire        rst,
    output wire [15:0] im_addr,
    output wire        im_en,
    input  wire [15:0] im_dout,
    output wire [15:0] dm_addr,
    output wire        dm_en,
    output wire        dm_we,
    output wire [15:0] dm_din,
    input  wire [15:0] dm_dout,
    output wire        halted,
    output wire        fault,
    // Observation-only interface; none of these signals feed execution.
    output wire observe_wb_valid, observe_wb_fault, observe_wb_halt, observe_wb_store,
    output wire observe_rf_we, observe_z_we, observe_cv_we,
    output wire [1:0] observe_wb_rd,
    output wire [15:0] observe_wb_pc, observe_wb_data,
    output wire [2:0] observe_wb_flags,
    output wire observe_stall, observe_redirect,
    output wire [15:0] observe_fetch_pc,
    output wire [3:0] observe_pipeline_valid,
    output wire [2:0] observe_flags,
    output reg stop_valid, stop_pc_valid,
    output reg [15:0] stop_pc,
    output reg [2:0] stop_reason,
    output reg last_completed_valid,
    output reg [15:0] last_completed_pc
);
    localparam [2:0] RUN         = 3'd0;
    localparam [2:0] DRAIN_HALT  = 3'd1;
    localparam [2:0] DRAIN_FAULT = 3'd2;
    localparam [2:0] HALTED      = 3'd3;
    localparam [2:0] FAULTED     = 3'd4;

    reg [2:0] mode, mode_next;
    wire mode_active = (mode == RUN || mode == DRAIN_HALT || mode == DRAIN_FAULT);
    wire stop_pending = (mode == DRAIN_HALT || mode == DRAIN_FAULT);
    assign halted = (mode == HALTED);
    assign fault = (mode == FAULTED);

    // IF: PC is the request address. In-range means the whole 16-bit address
    // fits the 256-word physical memory; never silently truncate to 8 bits.
    wire [15:0] PC_fetch;
    wire pc_hold, qualified_redirect;
    wire [15:0] branch_target;
    wire fetch_in_range = (PC_fetch[15:8] == 8'h00);
    wire fetch_accept;
    assign im_addr = PC_fetch;
    assign im_en = fetch_accept && fetch_in_range;
    pc16 u_pc (.clk(clk), .rst(rst), .hold(pc_hold),
               .redirect(qualified_redirect), .target(branch_target), .pc(PC_fetch));

    // IF/ID stores tags and valid, not a second copy of synchronous IM dout.
    reg d_valid, d_fetch_fault;
    reg [15:0] d_pc;
    wire [15:0] d_inst = im_dout;
    wire [1:0] d_rd, d_rs, d_alu_a_sel, d_alu_b_sel;
    wire [7:0] d_imm;
    wire [2:0] d_alu_op;
    wire d_use_rd, d_use_rs, d_imm_signed;
    wire d_reg_write, d_mem_read, d_mem_write, d_z_write, d_cv_write;
    wire d_wb_sel, d_jump_abs, d_jump_z, d_halt, d_illegal;
    wire d_fault = d_fetch_fault || d_illegal;
    wire [15:0] d_rd_value, d_rs_value, d_imm_ext;
    isa_decode u_decode (
        .inst(d_inst), .rd(d_rd), .rs(d_rs), .imm(d_imm),
        .use_rd(d_use_rd), .use_rs(d_use_rs),
        .alu_a_sel(d_alu_a_sel), .alu_b_sel(d_alu_b_sel), .alu_op(d_alu_op),
        .imm_signed(d_imm_signed), .reg_write(d_reg_write),
        .mem_read(d_mem_read), .mem_write(d_mem_write),
        .z_write(d_z_write), .cv_write(d_cv_write), .wb_sel(d_wb_sel),
        .jump_abs(d_jump_abs), .jump_z(d_jump_z), .halt(d_halt), .illegal(d_illegal)
    );
    imm_ext16 u_ext (.imm(d_imm), .sign_mode(d_imm_signed), .value(d_imm_ext));

    // ID/EX: data, control and PC always belong to the same instruction.
    reg x_valid, x_fault;
    reg [15:0] x_pc, x_rd_value, x_rs_value, x_imm_ext;
    reg [1:0] x_rd, x_rs, x_alu_a_sel, x_alu_b_sel;
    reg [2:0] x_alu_op;
    reg x_use_rd, x_use_rs;
    reg x_reg_write, x_mem_read, x_mem_write, x_z_write, x_cv_write;
    reg x_wb_sel, x_jump_abs, x_jump_z, x_halt;

    // EX/MEM: exec_value is either the ALU value or effective address.
    // STR data uses its own path, independently forwarded from Rd.
    reg m_valid, m_fault;
    reg m_store_pending; // Reuses m_rd as the STR data-source identity.
    reg [15:0] m_pc, m_exec_value, m_store_data;
    reg [1:0] m_rd;
    reg m_cmp_z, m_c, m_v;
    reg m_reg_write, m_mem_read, m_mem_write, m_z_write, m_cv_write;
    reg m_wb_sel, m_halt;

    // MEM/WB: load data is the external synchronous DM output.
    reg w_valid, w_fault;
    (* keep = "true" *) reg w_store; // instruction type for completion/debug
    reg [15:0] w_pc, w_exec_value;
    reg [1:0] w_rd;
    reg w_cmp_z, w_c, w_v;
    reg w_reg_write, w_z_write, w_cv_write, w_wb_sel, w_halt;
    wire [15:0] w_load_data = dm_dout;
    wire [15:0] wb_data = w_wb_sel ? w_load_data : w_exec_value;
    wire wb_ok = mode_active && w_valid && !w_fault;
    // Store already carries zero RW/ZW/CVW masks. Do not add a redundant
    // store-type gate to every RF/flag write-enable critical path.
    wire rf_we = !rst && wb_ok && w_reg_write;
    wire z_we = !rst && wb_ok && w_z_write;
    wire cv_we = !rst && wb_ok && w_cv_write;
    // C/V are architectural state even though this ISA has no JC/JO yet.
    // Preserve these nets for hardware debug and the synthesis review.
    (* keep = "true" *) wire Z, C, V;
    regfile4x16 u_rf (
        .clk(clk), .rst(rst), .we(rf_we), .waddr(w_rd), .wdata(wb_data),
        .raddr_a(d_rd), .raddr_b(d_rs), .rdata_a(d_rd_value), .rdata_b(d_rs_value)
    );
    flags_reg u_flags (
        .clk(clk), .rst(rst), .z_we(z_we), .cv_we(cv_we),
        .z_in(w_cmp_z), .c_in(w_c), .v_in(w_v), .Z(Z), .C(C), .V(V)
    );

    // Forwarding: M non-load > W selected writeback data > ID-captured value.
    // Registered M faults remain ineligible. A non-load RF producer cannot
    // access DM in this ISA, so MEM range checking need not gate its data MUX.
    // A matching M load still blocks WB; an access fault cancels younger EX
    // through m_fault_event before any of that EX result can become valid.
    wire [15:0] rd_fwd, rs_fwd;
    wire [1:0] rd_fwd_sel, rs_fwd_sel;
    wire blocked_rd, blocked_rs;
    wire m_address_in_range = (m_exec_value[15:8] == 8'h00);
    wire m_access_fault = m_valid && (m_mem_read || m_mem_write)
                       && (m_fault || !m_address_in_range);
    reg m_store_data_ready;
    always @* begin
        m_store_data_ready = 1'b0;
        if (mode_active && w_valid && !w_fault && w_reg_write && w_wb_sel
            && !w_store && !w_halt && !w_z_write && !w_cv_write && w_rd == m_rd)
            m_store_data_ready = 1'b1;
    end
    wire m_store_data_fault = m_valid && m_mem_write && m_store_pending
                           && !m_store_data_ready;
    // With fixed immediate EX/MEM fault detection, accepting HALT means all
    // older fault opportunities have already been checked. Therefore a new
    // MEM fault cannot appear in DRAIN_HALT. A variable-latency/error memory
    // would require a revised interface and stop-state transition contract.
    wire m_fault_event = !rst && mode == RUN && (m_access_fault || m_store_data_fault);
    operand_forward u_forward (
        .rd(x_rd), .rs(x_rs), .use_rd(x_use_rd), .use_rs(x_use_rs),
        .rd_value(x_rd_value), .rs_value(x_rs_value),
        .m_valid(m_valid), .m_fault(m_fault),
        .m_reg_write(m_reg_write), .m_mem_read(m_mem_read),
        .m_rd(m_rd), .m_value(m_exec_value),
        .w_valid(w_valid), .w_fault(w_fault), .w_reg_write(w_reg_write),
        .w_rd(w_rd), .w_value(wb_data),
        .rd_fwd(rd_fwd), .rs_fwd(rs_fwd), .rd_sel(rd_fwd_sel), .rs_sel(rs_fwd_sel),
        .blocked_rd(blocked_rd), .blocked_rs(blocked_rs)
    );

    reg [15:0] alu_a, alu_b;
    always @* begin
        alu_a = 16'h0000;
        alu_b = 16'h0000;
        case (x_alu_a_sel)
            2'd1: alu_a = rd_fwd;
            2'd2: alu_a = rs_fwd;
            default: alu_a = 16'h0000;
        endcase
        case (x_alu_b_sel)
            2'd1: alu_b = rs_fwd;
            2'd2: alu_b = x_imm_ext;
            default: alu_b = 16'h0000;
        endcase
    end
    wire [15:0] alu_result;
    wire alu_eq, alu_illegal, alu_c, alu_v;
    alu16 u_alu (.a(alu_a), .b(alu_b), .op(x_alu_op), .result(alu_result),
                 .eq(alu_eq), .illegal(alu_illegal), .carry(alu_c), .overflow(alu_v));
    wire [15:0] x_store_data = rd_fwd;
    branch_target16 u_target (.branch_pc(x_pc), .imm(x_imm_ext[7:0]),
                             .relative(x_jump_z), .target(branch_target));

    // Z is not the current ALU result. Only valid CMP candidates may bypass
    // architectural Z; a candidate zero overrides an older candidate one.
    reg z_effective;
    reg [1:0] z_fwd_sel;
    always @* begin
        z_effective = Z;
        z_fwd_sel = 2'd0;
        if (m_valid && !m_fault && m_z_write) begin
            z_effective = m_cmp_z;
            z_fwd_sel = 2'd1;
        end else if (w_valid && !w_fault && w_z_write) begin
            z_effective = w_cmp_z;
            z_fwd_sel = 2'd2;
        end
    end

    // ID may reference only the actual instruction sources. MOV immediate,
    // for example, must never stall because its destination matches a load.
    // Only a known legal STR may defer its Rd data. Rs is always an EX
    // address source, including Rd==Rs, and retains the load-use interlock.
    reg d_store_data_only;
    always @* begin
        d_store_data_only = 1'b0;
        if (d_mem_write && d_use_rd && d_use_rs && d_alu_a_sel == 2'd2
            && d_alu_b_sel == 2'd2 && d_alu_op == 3'd1 && d_imm_signed
            && !d_reg_write && !d_mem_read && !d_z_write && !d_cv_write
            && !d_wb_sel && !d_jump_abs && !d_jump_z && !d_halt)
            d_store_data_only = 1'b1;
    end
    wire load_use = x_valid && !x_fault && x_mem_read && d_valid && !d_fault
                  && ((d_use_rd && d_rd == x_rd && !d_store_data_only)
                      || (d_use_rs && d_rs == x_rd));
    reg x_store_late;
    always @* begin
        x_store_late = 1'b0;
        if (mode == RUN && x_valid && !x_fault && x_mem_write
            && x_use_rd && x_use_rs && x_alu_a_sel == 2'd2
            && x_alu_b_sel == 2'd2 && x_alu_op == 3'd1
            && !x_mem_read && !x_z_write && !x_cv_write
            && !x_wb_sel && !x_jump_abs && !x_jump_z && !x_halt
            && blocked_rd && !blocked_rs
            && m_valid && !m_fault && m_reg_write && m_mem_read && m_rd == x_rd)
            x_store_late = 1'b1;
    end
    wire x_control_illegal = alu_illegal || x_alu_a_sel == 2'd3
                         || x_alu_b_sel == 2'd3 || (blocked_rd && !x_store_late) || blocked_rs;
    wire x_fault_event = !rst && mode == RUN && x_valid
                       && (x_fault || x_control_illegal);
    wire halt_req = x_valid && !x_fault && !x_control_illegal && x_halt;
    wire qualified_halt = !rst && mode == RUN && !m_fault_event
                        && !x_fault_event && halt_req;
    wire branch_req = x_valid && !x_fault && !x_control_illegal
                    && (x_jump_abs || (x_jump_z && z_effective));
    assign qualified_redirect = !rst && mode == RUN && !m_fault_event
                              && !x_fault_event && !qualified_halt && branch_req;

    // Age priority: reset > older MEM fault > EX stop > EX branch > load use.
    // fetch_accept includes out-of-range requests logically: physical IM is
    // disabled, but the bad address becomes a cancellable IF/ID fault token.
    wire frontend_kill = m_fault_event || x_fault_event || qualified_halt
                       || qualified_redirect;
    assign fetch_accept = !rst && mode == RUN && !frontend_kill && !load_use;
    assign pc_hold = !fetch_accept;
    wire d_kill = frontend_kill || mode != RUN;
    wire x_kill = m_fault_event;

    // Full EA is exported. Qualification happens before a wrapper can index
    // the physical RAM, so 0100 can never alias 0000, nor FFFF alias 00FF.
    wire mem_ok = !rst && mode_active && m_valid && !m_fault && m_address_in_range
                && !m_store_data_fault;
    assign dm_addr = m_exec_value;
    assign dm_din = m_store_pending ? wb_data : m_store_data;
    assign dm_en = mem_ok && (m_mem_read || m_mem_write);
    assign dm_we = mem_ok && m_mem_write;

    reg d_valid_next, x_valid_next, m_valid_next, w_valid_next;
    reg d_fetch_fault_next, w_fault_next, m_fault_next;
    wire w_stop_token = w_valid && (w_halt || w_fault);
    wire pipeline_empty_next = !(d_valid_next || x_valid_next || m_valid_next || w_valid_next);
    wire drain_done = !rst && stop_pending && w_stop_token && pipeline_empty_next;

    // Only occupancy needs explicit hold/kill arbitration. Data fields below
    // move with their valid/control tags; stale bits in a bubble cannot act.
    always @* begin
        d_valid_next = 1'b0;
        x_valid_next = 1'b0;
        m_valid_next = 1'b0;
        w_valid_next = 1'b0;
        d_fetch_fault_next = 1'b0;
        m_fault_next = 1'b0;
        w_fault_next = 1'b0;
        if (!rst && mode_active) begin
            // Unified occupancy: even a successful STR has a valid WB slot.
            // Its one DM side effect still occurs only at the MEM edge.
            w_valid_next = m_valid;
            w_fault_next = m_fault || m_access_fault || m_store_data_fault;
            m_valid_next = x_valid && !m_fault_event;
            m_fault_next = x_fault || x_control_illegal;
            if (mode == RUN && !frontend_kill) begin
                if (load_use) begin
                    d_valid_next = d_valid;
                    d_fetch_fault_next = d_fetch_fault;
                    x_valid_next = 1'b0;
                end else begin
                    d_valid_next = fetch_accept;
                    d_fetch_fault_next = fetch_accept && !fetch_in_range;
                    x_valid_next = d_valid;
                end
            end
        end
    end

    always @* begin
        mode_next = mode;
        if (rst) mode_next = RUN;
        else case (mode)
            RUN: begin
                if (m_fault_event || x_fault_event) mode_next = DRAIN_FAULT;
                else if (qualified_halt) mode_next = DRAIN_HALT;
            end
            DRAIN_HALT: if (drain_done) mode_next = HALTED;
            DRAIN_FAULT: if (drain_done) mode_next = FAULTED;
            HALTED: mode_next = HALTED;
            FAULTED: mode_next = FAULTED;
            default: mode_next = FAULTED; // fail safe, never restart silently
        endcase
    end

    assign observe_wb_valid = !rst && mode_active && w_valid;
    assign observe_wb_fault = observe_wb_valid && w_fault;
    assign observe_wb_halt = observe_wb_valid && w_halt;
    assign observe_wb_store = observe_wb_valid && w_store;
    assign observe_rf_we = rf_we;
    assign observe_z_we = z_we;
    assign observe_cv_we = cv_we;
    assign observe_wb_rd = w_rd;
    assign observe_wb_pc = w_pc;
    assign observe_wb_data = wb_data;
    assign observe_wb_flags = {w_cmp_z,w_c,w_v};
    assign observe_stall = !rst && mode == RUN && !frontend_kill && load_use;
    assign observe_redirect = qualified_redirect;
    assign observe_fetch_pc = PC_fetch;
    assign observe_pipeline_valid = {d_valid,x_valid,m_valid,w_valid};
    assign observe_flags = {Z,C,V};

    // Diagnostic reasons follow the SAME valid tokens, without changing CU
    // arbitration or memory timing. 1=HALT, 2=opcode, 3=fetch range,
    // 4=DM range, 5=internal control, 6=illegal binary mode (no PC).
    reg [2:0] x_reason, m_reason, w_reason;
    always @(posedge clk) begin
        if (rst) begin
            x_reason <= 0; m_reason <= 0; w_reason <= 0;
            stop_valid <= 0; stop_pc_valid <= 0; stop_pc <= 0; stop_reason <= 0;
            last_completed_valid <= 0; last_completed_pc <= 0;
        end else begin
            x_reason <= x_valid_next && d_fault ? (d_fetch_fault ? 3'd3 : 3'd2) : 3'd0;
            m_reason <= !m_valid_next ? 3'd0 : x_fault ? x_reason :
                        x_control_illegal ? 3'd5 : x_halt ? 3'd1 : 3'd0;
            w_reason <= !w_valid_next ? 3'd0 : m_fault ? m_reason :
                        m_access_fault ? 3'd4 : m_store_data_fault ? 3'd5 : m_halt ? 3'd1 : 3'd0;
            if (observe_wb_valid && !w_fault) begin
                last_completed_valid <= 1;
                last_completed_pc <= w_pc;
            end
            if (!stop_valid && drain_done) begin
                stop_valid <= 1; stop_pc_valid <= 1;
                stop_pc <= w_pc; stop_reason <= w_fault ? w_reason : 3'd1;
            end else if (!stop_valid && mode > FAULTED) begin
                stop_valid <= 1; stop_pc_valid <= 0;
                stop_pc <= 0; stop_reason <= 3'd6;
            end
        end
    end

    // One driver for every pipeline state. Backend advances during an ID
    // interlock; notably RF/flags may write even when MEM reports a younger
    // fault. rst qualifies external memory writes before this sampling edge.
    always @(posedge clk) begin
        if (rst) begin
            mode <= RUN;
            d_valid <= 1'b0; d_fetch_fault <= 1'b0; d_pc <= 16'h0000;
            x_valid <= 1'b0; x_fault <= 1'b0; x_pc <= 16'h0000;
            x_rd <= 2'd0; x_rs <= 2'd0;
            x_rd_value <= 16'h0000; x_rs_value <= 16'h0000; x_imm_ext <= 16'h0000;
            x_use_rd <= 1'b0; x_use_rs <= 1'b0;
            x_alu_a_sel <= 2'd0; x_alu_b_sel <= 2'd0; x_alu_op <= 3'd0;
            x_reg_write <= 1'b0; x_mem_read <= 1'b0; x_mem_write <= 1'b0;
            x_z_write <= 1'b0; x_cv_write <= 1'b0; x_wb_sel <= 1'b0;
            x_jump_abs <= 1'b0; x_jump_z <= 1'b0; x_halt <= 1'b0;
            m_valid <= 1'b0; m_fault <= 1'b0; m_store_pending <= 1'b0;
            m_pc <= 16'h0000; m_rd <= 2'd0;
            m_exec_value <= 16'h0000; m_store_data <= 16'h0000;
            m_cmp_z <= 1'b0; m_c <= 1'b0; m_v <= 1'b0;
            m_reg_write <= 1'b0; m_mem_read <= 1'b0; m_mem_write <= 1'b0;
            m_z_write <= 1'b0; m_cv_write <= 1'b0; m_wb_sel <= 1'b0; m_halt <= 1'b0;
            w_valid <= 1'b0; w_fault <= 1'b0; w_store <= 1'b0;
            w_pc <= 16'h0000; w_rd <= 2'd0;
            w_exec_value <= 16'h0000; w_cmp_z <= 1'b0; w_c <= 1'b0; w_v <= 1'b0;
            w_reg_write <= 1'b0; w_z_write <= 1'b0; w_cv_write <= 1'b0;
            w_wb_sel <= 1'b0; w_halt <= 1'b0;
        end else begin
            mode <= mode_next;

            d_valid <= d_valid_next;
            d_fetch_fault <= d_fetch_fault_next;
            if (fetch_accept) d_pc <= PC_fetch;
            // When load_use is true, IM en=0 and d_pc/valid hold together.

            x_valid <= x_valid_next;
            x_fault <= x_valid_next && d_fault;
            x_pc <= d_pc;
            x_rd <= d_rd; x_rs <= d_rs;
            x_rd_value <= d_rd_value; x_rs_value <= d_rs_value; x_imm_ext <= d_imm_ext;
            x_use_rd <= x_valid_next && !d_fault && d_use_rd;
            x_use_rs <= x_valid_next && !d_fault && d_use_rs;
            x_alu_a_sel <= d_alu_a_sel; x_alu_b_sel <= d_alu_b_sel; x_alu_op <= d_alu_op;
            x_reg_write <= x_valid_next && !d_fault && d_reg_write;
            x_mem_read <= x_valid_next && !d_fault && d_mem_read;
            x_mem_write <= x_valid_next && !d_fault && d_mem_write;
            x_z_write <= x_valid_next && !d_fault && d_z_write;
            x_cv_write <= x_valid_next && !d_fault && d_cv_write;
            x_wb_sel <= d_wb_sel;
            x_jump_abs <= x_valid_next && !d_fault && d_jump_abs;
            x_jump_z <= x_valid_next && !d_fault && d_jump_z;
            x_halt <= x_valid_next && !d_fault && d_halt;

            m_valid <= m_valid_next;
            m_fault <= m_valid_next && m_fault_next;
            m_store_pending <= m_valid_next && !m_fault_next && x_store_late;
            m_pc <= x_pc; m_rd <= x_rd;
            m_exec_value <= alu_result; m_store_data <= x_store_data;
            m_cmp_z <= alu_eq; m_c <= alu_c; m_v <= alu_v;
            m_reg_write <= m_valid_next && !m_fault_next && x_reg_write;
            m_mem_read <= m_valid_next && !m_fault_next && x_mem_read;
            m_mem_write <= m_valid_next && !m_fault_next && x_mem_write;
            m_z_write <= m_valid_next && !m_fault_next && x_z_write;
            m_cv_write <= m_valid_next && !m_fault_next && x_cv_write;
            m_wb_sel <= x_wb_sel;
            m_halt <= m_valid_next && !m_fault_next && x_halt;

            w_valid <= w_valid_next;
            w_fault <= w_valid_next && w_fault_next;
            w_store <= w_valid_next && !w_fault_next && m_mem_write;
            w_pc <= m_pc; w_rd <= m_rd; w_exec_value <= m_exec_value;
            w_cmp_z <= m_cmp_z; w_c <= m_c; w_v <= m_v;
            w_reg_write <= w_valid_next && !w_fault_next && m_reg_write;
            w_z_write <= w_valid_next && !w_fault_next && m_z_write;
            w_cv_write <= w_valid_next && !w_fault_next && m_cv_write;
            w_wb_sel <= m_wb_sel;
            w_halt <= w_valid_next && !w_fault_next && m_halt;
        end
    end
endmodule
