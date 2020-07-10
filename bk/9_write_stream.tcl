set_write_stream_options -child_depth 100 -output_pin {text}
change_names -rules verilog -hierarchy
write_verilog -output ../outputs/e203_soc_top_routed.v
write_sdf -version 2.1 -significant_digits 6 ../outputs/e203_soc_top_routed.sdf
write_stream -cells e203_soc_top ../outputs/e203_soc_top.gds
