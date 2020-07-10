source ../scripts/test_pin.tcl

set_fp_pin_constraints -block_level -use_physical_constraints on -hard_constraints {layer location}
set_ignored_layers -max_routing_layer A4
create_fp_placement -timing -no_hier -optimize_pins
derive_pg_connection -power_net VDD -power_pin VDD -ground_net GND -ground_pin GND
derive_pg_connection -power_net VDDH -power_pin VDDH -ground_net VSSH -ground_pin VSSH
derive_pg_connection -power_net VDD -ground_net GND -tie
check_mv_design -power_nets

route_global -congestion_map_only
check_timing
save_mw_cel -as 3_pre_pns

