// Verification tools 1.6-vtools-r1. Included inside CPU-level test modules.
// Synchronous reset permits unknown startup state only before the first edge.
// Check controls, not arbitrary data bits in bubbles/unconsumed payloads.
bit control_checks_armed = 0;
task automatic check_cpu_controls(input string sample_phase);
 begin
  if ($isunknown({rst,halted,fault,dut.im_en,dut.dm_en,dut.dm_we,
      dut.core.rf_we,dut.core.z_we,dut.core.cv_we,
      dut.core.d_valid,dut.core.x_valid,dut.core.m_valid,dut.core.w_valid,
      dut.core.mode,dut.core.mode_active,dut.core.stop_pending,
      dut.core.load_use,dut.core.frontend_kill,dut.core.d_kill,dut.core.x_kill,
      dut.core.pc_hold,dut.core.fetch_accept,dut.core.qualified_redirect,
      dut.core.qualified_halt,dut.core.x_fault_event,dut.core.m_fault_event,
      dut.core.branch_req,dut.core.halt_req}))
    $fatal(1,"CONTROL_XZ phase=%s scope=%m",sample_phase);
  if (rst===1'b1 || halted===1'b1 || fault===1'b1)
    if ({dut.im_en,dut.dm_en,dut.dm_we,dut.core.rf_we,dut.core.z_we,
         dut.core.cv_we,dut.core.qualified_redirect,dut.core.qualified_halt,
         dut.core.x_fault_event,dut.core.m_fault_event} !== '0)
      $fatal(1,"CONTROL_DISABLED_NOT_ZERO phase=%s scope=%m",sample_phase);
  if (dut.core.x_valid===1'b1)
    if ($isunknown(dut.core.x_fault))$fatal(1,"CONTROL_XZ_EX_FAULT scope=%m");
  if (dut.core.x_valid===1'b1 && dut.core.x_fault===1'b0)
    if ($isunknown({dut.core.x_use_rd,dut.core.x_use_rs,dut.core.x_alu_a_sel,
      dut.core.x_alu_b_sel,dut.core.x_alu_op,dut.core.x_reg_write,
      dut.core.x_mem_read,dut.core.x_mem_write,dut.core.x_z_write,
      dut.core.x_cv_write,dut.core.x_wb_sel,dut.core.x_jump_abs,
      dut.core.x_jump_z,dut.core.x_halt}))$fatal(1,"CONTROL_XZ_EX scope=%m");
  if (dut.core.m_valid===1'b1)
    if ($isunknown({dut.core.m_fault,dut.core.m_reg_write,dut.core.m_mem_read,
      dut.core.m_mem_write,dut.core.m_z_write,dut.core.m_cv_write,
      dut.core.m_wb_sel,dut.core.m_halt}))$fatal(1,"CONTROL_XZ_MEM scope=%m");
  if (dut.core.w_valid===1'b1)
    if ($isunknown({dut.core.w_fault,dut.core.w_reg_write,dut.core.w_z_write,
      dut.core.w_cv_write,dut.core.w_wb_sel,dut.core.w_halt,
      dut.core.w_store}))$fatal(1,"CONTROL_XZ_WB scope=%m");
 end
endtask
always @(posedge clk) begin
 if (control_checks_armed)check_cpu_controls("pre_edge");
 #1;
 control_checks_armed=1;
 check_cpu_controls("post_NBA");
end
// TB fixtures/reset are changed on falling edges; allow delta propagation.
always @(negedge clk) begin
 #1;
 if(control_checks_armed)check_cpu_controls("settled_half_cycle");
end
