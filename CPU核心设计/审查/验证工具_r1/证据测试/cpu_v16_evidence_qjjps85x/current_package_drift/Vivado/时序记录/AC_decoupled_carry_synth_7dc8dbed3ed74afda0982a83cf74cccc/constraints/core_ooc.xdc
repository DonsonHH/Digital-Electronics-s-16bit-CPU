# Core clock target only, not a board pinout or complete external timing model.
# 100 MHz is a constraint, not a claim of timing closure.
create_clock -period 10.000 -name core_clk [get_ports clk]
