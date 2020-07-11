set top "cnn_top"
set std_path "../ref"

#set mem_lib "/home/lus/digital/complete_dc_scripts/libraries/lib "
#set dc_run_lib "/home/lus/digital/spi_final/dc_global"
set search_path [list $std_path/ ]


#SYNTHETIC LIB---------------------------------------------------------


#target library-----------------------------------------------------------
#set     target_library          csmc13_ff_1p32v_-40c.db
#set     target_library          [list saed32rvt_ss0p95v125c.db sram_8kx32_ss_0p99v_0p99v_125c.db sram_4kx64_ss_0p99v_0p99v_125c.db]
#set     link_library            [list  "*" $target_library ]
set     target_library          "saed32rvt_ss0p95v125c.db sram_8kx32_ss_0p99v_0p99v_125c.db sram_4kx64_ss_0p99v_0p99v_125c.db"
set     link_library            "* $target_library"
#set 	symbol_library      	{csmc13.sdb csmc13iov33.sdb}

#define_name_rules BORG -type port -allowed "A-Z a-z 0-9" -first_restricted "_" \
#	-last_restricted "_" -max_length 30
#define_name_rules BORG -type cell -prefix "CELL" -restrict "\\" 
define_name_rules BORG -type net -allowed "A-Z a-z 0-9" -first_restricted "_0-9\\" \
        -last_restricted "_0-9\\" -max_length 30

#report_name_rules BORG
#set bus_naming_style {%s[%d]}
set verilogout_no_tri true
set verilogout_show_unconnected_pins true
