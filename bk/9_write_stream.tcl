set_write_stream_options -child_depth 100 -output_pin {text}
change_names -rules verilog -hierarchy
write_verilog -output ../outputs/top_digital_routed.v
write_sdf -version 2.1 -significant_digits 6 ../outputs/top_digital_routed.sdf
write_stream -cells top_digital ../outputs/top_digital.gds
