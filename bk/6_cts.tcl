check_clock_tree

set_max_fanout 20 [current_design]
set_max_transition 0.5 [current_design]
set_host_options -max_cores 4
set_route_mode_options -zroute true
#set_delay_calculation -clock_arnoldi
set_delay_calculation_options -routed_clock arnoldi -postroute arnoldi
set_clock_tree_references -references {BUFCLKHD10X BUFCLKHD8X BUFCLKHD6X BUFCLKHD4X BUFCLKHD2X BUFCLKHD12X}
set_clock_tree_references -references {BUFCLKHD10X BUFCLKHD8X}  -sizing_only
set_clock_tree_references -references {BUFCLKHD2X BUFCLKHD4X}  -delay_insertion_only

#remove_clock_uncertainty [all_clocks]
set_clock_uncertainty 0.5 [all_clocks]
clock_opt -no_clock_route -only_cts
set_fix_hold [all_clocks]
extract_rc
clock_opt -no_clock_route -only_psyn -area_recovery
optimize_clock_tree
set_propagated_clock [all_clocks]
derive_pg_connection -power_net VDD -power_pin VDD -ground_net GND -ground_pin GND
derive_pg_connection -power_net VDD -ground_net GND -tie
check_mv_design -power_nets

save_mw_cel -as 6_cts

