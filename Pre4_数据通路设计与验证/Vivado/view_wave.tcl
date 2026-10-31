set root [file dirname [file normalize [info script]]]
open_wave_database [file join $root datapath.wdb]
create_wave_config
add_wave /tb_datapath/clk /tb_datapath/rst
add_wave /tb_datapath/dut/core/PC_fetch /tb_datapath/dut/core/im_en
add_wave /tb_datapath/dut/core/d_valid /tb_datapath/dut/core/d_pc /tb_datapath/dut/core/d_inst
add_wave /tb_datapath/dut/core/x_valid /tb_datapath/dut/core/x_pc /tb_datapath/dut/core/alu_a /tb_datapath/dut/core/alu_b /tb_datapath/dut/core/alu_result
add_wave /tb_datapath/dut/core/rd_fwd_sel /tb_datapath/dut/core/rs_fwd_sel /tb_datapath/dut/core/load_use
add_wave /tb_datapath/dut/core/m_valid /tb_datapath/dut/core/m_pc /tb_datapath/dut/core/m_exec_value /tb_datapath/dut/core/m_store_data
add_wave /tb_datapath/dut/core/dm_en /tb_datapath/dut/core/dm_we /tb_datapath/dut/core/dm_dout
add_wave /tb_datapath/dut/core/w_valid /tb_datapath/dut/core/w_pc /tb_datapath/dut/core/wb_data /tb_datapath/dut/core/rf_we
add_wave /tb_datapath/dut/core/Z /tb_datapath/dut/core/C /tb_datapath/dut/core/V /tb_datapath/dut/core/z_effective
add_wave /tb_datapath/dut/core/qualified_redirect /tb_datapath/dut/core/branch_target /tb_datapath/dut/core/m_fault_event
add_wave /tb_datapath/dut/core/mode /tb_datapath/dut/core/halted /tb_datapath/dut/core/fault
