#create_die_area  \
        -poly { {0.000 0.000} {1871.800 0.000} {1871.800 435.90} {0.000 435.90} }

#source ../scripts/bk/pad_new.tcl
#
#create_floorplan -control_type boundary -start_first_row -flip_first_row -left_io2core 215.9 -bottom_io2core 20 -right_io2core 215.9 -top_io2core 215.9
#
#save_mw_cel -as 2_floorplan

create_floorplan -control_type aspect_ratio -core_utilization 0.7 -start_first_row -flip_first_row 
create_fp_virtual_pad -nets VDD -point {0 500}
create_fp_virtual_pad -nets VSS -point {0 600}
create_fp_virtual_pad -nets VDD -point {1121 500}
create_fp_virtual_pad -nets VSS -point {1121 600}
create_fp_virtual_pad -nets VDD -point {500 0}
create_fp_virtual_pad -nets VSS -point {600 0}
create_fp_virtual_pad -nets VSS -point {600 1121}
create_fp_virtual_pad -nets VDD -point {500 1121}

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS
derive_pg_connection -power_net VDD -ground_net VSS -tie

save_mw_cel -as 2_floorplan
