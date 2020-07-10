source ../scripts/ant.tcl
set_route_zrt_detail_options -insert_diodes_during_routing true
route_zrt_detail -increment true

derive_pg_connection -power_net VDD -power_pin VDD -ground_net GND -ground_pin GND
derive_pg_connection -power_net VDD -ground_net GND -tie
check_mv_design -power_nets

#report_critical_area -fault_type short
#spread_zrt_wires
#report_critical_area -fault_type short
#
#report_critical_area -fault_type open
#widen_zrt_wires
#report_critical_area -fault_type open

insert_stdcell_filler -cell_without_metal {FILLER1HD FILLER2HD FILLER4HD FILLER6HD FILLER8HD} \
                -connect_to_power VDD -connect_to_ground GND


#report_design_physical -route
#insert_zrt_redundant_vias -list_only
#insert_zrt_redundant_vias -effort medium
#report_design_physical -route
#
#route_opt -incremental
derive_pg_connection -power_net VDD -power_pin VDD -ground_net GND -ground_pin GND
derive_pg_connection -power_net VDD -ground_net GND -tie
#check_mv_design -power_nets

route_zrt_eco

verify_zrt_route 
verify_lvs -max_error 1000 > ../logs/lvs_violations.rpt
verify_drc > ../logs/drc.rpt
report_constraint -all_violators -nosplit -significant_digits 4 > ../logs/violations.rpt
check_timing
report_timing > ../logs/timing.rpt 


save_mw_cel -as 8_chip_finished

