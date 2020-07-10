check_physical_design -stage pre_route_opt

set_host_options -max_cores 4
set_route_mode_options -zroute true
set_route_zrt_common_options -default true
set_route_zrt_common_options -post_detail_route_redundant_via_insertion medium
set_route_zrt_global_options -default true
set_route_zrt_track_options -default true
set_route_zrt_detail_options -default true
set_route_zrt_detail_options -optimize_wire_via_effort_level medium

route_zrt_group -all_clock_nets
route_zrt_auto

route_opt -initial_route_only
route_opt -skip_initial_route
route_opt -incremental
verify_drc 
verify_zrt_route 

save_mw_cel -as 7_routed

