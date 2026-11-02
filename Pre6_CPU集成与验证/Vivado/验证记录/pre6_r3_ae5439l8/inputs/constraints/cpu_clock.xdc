# System OOC estimate. No package pins or board IO delays are claimed here.
create_clock -name system_clk -period 10.000 [get_ports clk]
