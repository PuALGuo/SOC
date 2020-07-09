####################################
# Logic synthesis main script

####################################
#main control scripts
#set hdlin_preserve_sequential true
#set compile_delete_unloaded_sequential_cells false 
set_host_options -max_cores 4
#set_units -capacitance pf
#set_units -time ns
#set_units -resistance ohm
source ../scripts/1_setup.tcl
#source ./script/2_read_file.tcl > ./log/read_file.log
source ../scripts/2_read_file.tcl 
#source set_main_clk.tcl

#elaborate $top
#uniquify
link
check_design 

#set timing_non_unate_clock_compatibility true
#set_case_analysis 0 ema_ctrl
#------------------------------------------------------------------
# #set logical design rule constraint
source ../scripts/3_set_drc.tcl
 #set clock and design rule for clock net
source ../scripts/4_set_main_clk.tcl
# specify inout pad latency
source ../scripts/5_set_mode_inout_drc_load.tcl
#source ./script/set_out_load.tcl
set compile_implementation_selection true
set compile_preserve_subdesign_interfaces true

set_fix_multiple_port_nets -all -buffer_constants

set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
group_path -name reg2out -from [all_registers -clock_pins] -to [all_outputs] 
group_path -name in2reg -from [remove_from_collection [all_inputs] $ports_clock_root] -to [all_registers -data_pins]
group_path -name in2out -from [remove_from_collection [all_inputs] $ports_clock_root] -to [all_outputs]

check_timing > ../log/check_timing.log
compile

source ../scripts/optimization.tcl

#give the report fot a varity of elements
#write synthesized files
source ../scripts/6_write_file.tcl
