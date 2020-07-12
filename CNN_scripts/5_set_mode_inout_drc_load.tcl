#########################################################################
#									#
# 1.Set drc and load							#
# 2.Set multicycle path and false path		      	#
# 								      	#

#########################################################################

##############################
current_design $top
#set_wire_load_model -name Zero -min
#set_wire_load_mode SRAMtest_top
set_input_delay -clock hfextclk 0.5 [remove_from_collection [all_inputs] lfextclk]
set_output_delay -clock hfextclk 0.5 [all_outputs]
set_input_delay -clock lfextclk 0.5 [remove_from_collection [all_inputs] hfextclk]
set_output_delay -clock lfextclk 0.5 [all_outputs]
set_drive 0.2 [all_inputs]
set_load 0.2 [all_outputs]
#source ./set_out_load.tcl
#*define the capacitance of wire is 5pf

#set_min_delay 1.6 -from i_pad_clk/D -to i_clk_b/Z
#set_min_delay 1.6 -from pad_clk -to clkb

##############################
#set operating conditions
#set_operating_conditions typical

                                                                                                                                                                                                                                                                                                         
