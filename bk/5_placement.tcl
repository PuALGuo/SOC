check_physical_design -stage pre_place_opt
#Dynamic Power Optimization LPP    //Gate-level power optimization (GLPO) optimizes
#set_power_options -low_power_placement true
set_optimize_pre_cts_power_options -low_power_placement true
place_opt -area_recovery
route_global -congestion_map_only

#set_power_options -dynamic true
set_scenario_options -dynamic_power true
psynopt -area_recovery
save_mw_cel -as 5_placement
