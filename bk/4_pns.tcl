set_fp_rail_constraints -add_layer -layer metal3 -direction horizontal -max_strap 20 -min_strap 2 -min_width 2 -spacing 1
set_fp_rail_constraints -add_layer -layer metal4 -direction vertical -max_strap 20 -min_strap 2 -min_width 2 -spacing 1
set_fp_rail_constraints -set_ring -nets {VDD GND} -horizontal_ring_layer {metal3} -vertical_ring_layer {metal4} -ring_spacing 2 -extend_strap core_ring
set_fp_rail_constraints -set_global
synthesize_fp_rail -nets {VDD GND} -voltage_supply 1.08 -synthesize_power_plan -power_budget 10
commit_fp_rail

derive_pg_connection -power_net VDD -power_pin VDD -ground_net GND -ground_pin GND
derive_pg_connection -power_net VDD -ground_net GND -tie
check_mv_design -power_nets

preroute_instances
preroute_standard_cells -fill_empty_rows -remove_floating_pieces
add_tap_cell_array -master_cell_name FILLER8HD -distance 60 -connect_power_name VDD -connect_ground_name GND -no_tap_cell_under_layer {M1,M2}
set_pnet_options -complete "A3 A4"

verify_pg_nets > ../logs/pg_nets.rpt

create_fp_placement -timing -no_hier -incremental all
route_global -congestion_map_only
check_timing
save_mw_cel -as 4_floorplanned
