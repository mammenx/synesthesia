## Generated SDC file "syn_fpga_top.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 259 01/25/2012 Service Pack 2.11 SJ Web Edition"

## DATE    "Sat Oct 20 14:52:09 2012"

##
## DEVICE  "EP2C20F484C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {pin_clock_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {pin_clock_24} -period 41.667 -waveform { 0.000 20.833 } [get_ports {CLOCK_24[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {syn_sys_pll_inst|altpll_component|pll|clk[0]} -source [get_pins {syn_sys_pll_inst|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {pin_clock_50} [get_pins {syn_sys_pll_inst|altpll_component|pll|clk[0]}] 
create_generated_clock -name {syn_sys_pll_inst|altpll_component|pll|clk[1]} -source [get_pins {syn_sys_pll_inst|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {pin_clock_50} [get_pins {syn_sys_pll_inst|altpll_component|pll|clk[1]}] 
create_generated_clock -name {syn_sys_pll_inst|altpll_component|pll|clk[2]} -source [get_pins {syn_sys_pll_inst|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -phase -108.000 -master_clock {pin_clock_50} [get_pins {syn_sys_pll_inst|altpll_component|pll|clk[2]}] 
create_generated_clock -name {mclk_pll_inst|altpll_component|pll|clk[0]} -source [get_pins {mclk_pll_inst|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 25 -divide_by 54 -master_clock {pin_clock_24} [get_pins {mclk_pll_inst|altpll_component|pll|clk[0]}] 
create_generated_clock -name {mclk_pll_inst|altpll_component|pll|clk[1]} -source [get_pins {mclk_pll_inst|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 25 -divide_by 48 -master_clock {pin_clock_24} [get_pins {mclk_pll_inst|altpll_component|pll|clk[1]}] 
create_generated_clock -name {mclk_pll_inst|altpll_component|pll|clk[2]} -source [get_pins {mclk_pll_inst|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 25 -divide_by 32 -master_clock {pin_clock_24} [get_pins {mclk_pll_inst|altpll_component|pll|clk[2]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path  -from  [get_clocks {syn_sys_pll_inst|altpll_component|pll|clk[0]}]  -to  [get_clocks {mclk_pll_inst|altpll_component|pll|clk[0]}]
set_false_path  -from  [get_clocks {syn_sys_pll_inst|altpll_component|pll|clk[0]}]  -to  [get_clocks {mclk_pll_inst|altpll_component|pll|clk[1]}]
set_false_path  -from  [get_clocks {syn_sys_pll_inst|altpll_component|pll|clk[0]}]  -to  [get_clocks {mclk_pll_inst|altpll_component|pll|clk[2]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

