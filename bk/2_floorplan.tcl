create_die_area  \
        -poly { {0.000 0.000} {1040.000 0.000} {1040.000 1040.000} {0.000 1040.000} }

#source ../scripts/bk/pad_new.tcl
#
create_floorplan -start_first_row -flip_first_row -left_io2core 20 -bottom_io2core 20 -right_io2core 20 -top_io2core 20 -control_type aspect_ratio -core_utilization 0.7
#
#save_mw_cel -as 2_floorplan

create_fp_virtual_pad -nets VDD -point {0 500}
create_fp_virtual_pad -nets VSS -point {0 600}
create_fp_virtual_pad -nets VDD -point {1050 500}
create_fp_virtual_pad -nets VSS -point {1050 600}
create_fp_virtual_pad -nets VDD -point {500 0}
create_fp_virtual_pad -nets VSS -point {600 0}
create_fp_virtual_pad -nets VSS -point {600 1050}
create_fp_virtual_pad -nets VDD -point {500 1050}

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS
derive_pg_connection -power_net VDD -ground_net VSS -tie

save_mw_cel -as 2_floorplan
