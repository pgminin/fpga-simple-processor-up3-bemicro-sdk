# ************************************************************** 
# Create Clock 
# ************************************************************** 
#create_clock -name {altera_reserved_tck} -period 20.0 [get_ports {altera_reserved_tck}] 
create_clock -name test_clock -period 5.000 [get_ports {clk_fpga_50M}]