#########################################################################
#									#
# Definition of main clocks.						#
# 	1. Define clocks : SYS_CLK		#
# 	2. Define the clocks' uncertainty and transition etc.		#
# 	3. Define timing exceptions between clock domains.		#
#	4. Define drc free nets						#
#									#

#########################################################################
set CLK_PERIOD_high  20
set CLK_PERIOD_low   30517.58

#==================================================
# 		clock source definition
#==================================================
create_clock -name "hfextclk" -period $CLK_PERIOD_high [get_ports hfextclk]
create_clock -name "lfextclk" -period $CLK_PERIOD_low [get_ports lfextclk]



##===================================================
##	uncertainty and transition time
##===================================================
set_clock_uncertainty -setup 0.5  hfextclk
set_clock_uncertainty -hold  0.5 hfextclk
set_clock_transition         0.5 hfextclk
#set_dont_touch_network [get_clocks hfextclk]

set_clock_uncertainty -setup 0.5  lfextclk
set_clock_uncertainty -hold  0.5 lfextclk
set_clock_transition         0.5 lfextclk

set_false_path -from [get_clocks lfextclk] -to [get_clocks hfextclk]
set_false_path -from [get_clocks hfextclk] -to [get_clocks lfextclk]
#set_clock_groups -asynchronous -name "clock_group" -group lfextclk -group hfextclk

set_dont_touch_network [get_clocks lfextclk]
set_dont_touch_network [get_clocks hfextclk]
##===================================================
## 	set drc free net
##===================================================
echo "set_ideal_network"
set_ideal_network [get_ports lfextclk] -no_propagate
set_ideal_network [get_ports hfextclk] -no_propagate
echo "set_ideal_network_end"



set_fix_hold hfextclk
set_fix_hold lfextclk

