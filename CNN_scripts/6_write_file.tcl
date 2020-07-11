#write_file -f verilog -h -o $db/wdt..v
#write_file -f db -h -o $db/wdt..db
#write_sdc $db/wdt..sdc
write -hierarchy -format ddc -output ../mapped/$top.mapped.ddc
write -hierarchy -format verilog -output ../mapped/$top.mapped.v
write_sdf ../mapped/$top.sdf
write_sdc -version 1.9 ../mapped/$top.sdc
report_timing > ../rpts/timing_rpts.rpts
report_area > ../rpts/area_rpts.rpts
report_constrain -all_violators > ../rpts/all_violators.rpts
report_net_fanout >  ../rpts/net_fanout.rpts
