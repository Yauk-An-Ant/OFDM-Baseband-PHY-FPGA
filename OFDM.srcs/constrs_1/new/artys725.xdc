
## 100 MHz clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Reset button (BTN0 on Arty S7)
set_property PACKAGE_PIN V17 [get_ports n_rst]
set_property IOSTANDARD LVCMOS33 [get_ports n_rst]

## LEDs
set_property PACKAGE_PIN U16 [get_ports {toggle[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {toggle[0]}]

set_property PACKAGE_PIN E19 [get_ports {toggle[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {toggle[1]}]