####################################
# Timing optimization
####################################
current_design $top


#set_ultra_optimization true
#compile_ultra
#group_path -name all_reg -critical_range 2.0 -to [all_registers] -weight 10

compile -incr -map_effort medium -incremental_mapping 
#compile_ultra -timing_high_effort_script

#compile -incr
#compile -incr
#compile -incr

####################################
# Area optimization
####################################


#set_ultra_optimization false
#set_max_area 200000
#compile -incr -area_effort high 
#compile -incr -area_effort high  
#current_design $top


####################################
#  DRC optimization
####################################
#insert buffers
foreach_in_collection itr [get_designs * -h] {
     current_design $itr
     set_fix_multiple_port_net -all -buffer
     set_fix_multiple_port_net -output -buffer
     set_fix_multiple_port_net -feedthr -buffer
     set_fix_multiple_port_net -buffer     
}

current_design $top
#compile -incr 
#compile -incr
#compile -incr 
###

#-only_design_rule


