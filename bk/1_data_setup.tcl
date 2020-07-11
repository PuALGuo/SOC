#this is the setting for csmc130nm technology
#change to library V1.0
#

##LC
#set std_path "/home/library/wxsh/0d13um/013-CRD-DOC-V1.0/STD_RVT/Synopsys"
#set io_path "/home/library/wxsh/0d13um/013-CRD-DOC-V1.0/IO/Synopsys"
#set std_symb_path "/home/library/wxsh/0d13um/013-CRD-DOC-V1.0/STD_RVT/Symbol/synopsys"
#set io_symb_path "/home/library/wxsh/0d13um/013-CRD-DOC-V1.0/IO/Symbol/synopsys"

#set tech_file_path "/home/library/wxsh/0d13um/013-CRD-DOC-V1.0/TECH"
#set search_path [list $std_path/ \
#                      $std_symb_path/ \
#                      $io_path/ \
#                      $tech_file_path/ \
#                      $io_symb_path/]
set home_path "/home/riscv/Desktop/DC+ICC"
set std_path "/home/riscv/Desktop/DC+ICC/icc/ref/db"
set tech_file_path "/home/riscv/Desktop/DC+ICC/icc/ref/tf"
set refer_path "/home/riscv/Desktop/DC+ICC/icc/ref"

set search_path [list $std_path/ \
                      $tech_file_path/ \
		]



#target library-----------------------------------------------------------
#set     target_library          csmc13_ff_1p32v_-55c.db
#set     io_library              csmc13iov33_stagger_ss_1p08v_2p97v_125c.db
#set     link_library            [list  "*" $target_library $io_library]
#set     symbol_library          {csmc13.sdb csmc13iov33.sdb}

set     target_library          "saed32rvt_ff1p16vn40c.db sram_4kx64_ss_0p99v_0p99v_125c.db sram_8kx32_ss_0p99v_0p99v_125c.db"
set     io_library              ""
set     link_library            "* $target_library $io_library"
#set     symbol_library          {csmc13.sdb csmc13iov33.sdb}	


#lappend search_path "/home/jfjiang/lib/smic_130nm/SCC013UG_HD_RVT_V0p1/synopsys/1.2v \
#		     /home/husai/SOCIPtest/lib \
#		     /home/jfjiang/lib/smic_130nm/SCC013UG_HD_RVT_V0p1/symbol"

#set_app_var target_library "scc013ug_hd_rvt_ss_v1p08_125c_basic.db"
#set_app_var io_library "pad.db"
#set_app_var link_library "* $target_library $io_library"
#set_app_var symbol_library "SCC013UG_HD_RVT_V0p1.sdb"


#create library
#create_mw_lib  -technology  /home/library/wxsh/0d13um/013-CRD-DOC-V1.0/TECH/csmc13_astro_m6.tf     \
#               -mw_reference_library {/home/library/wxsh/0d13um/013-CRD-DOC-V1.0/STD_RVT/Milkyway/csmc13mt6rvt    \
#                                      /home/library/wxsh/0d13um/013-CRD-DOC-V1.0/IO/Milkyway/CSMC13V33IOLIB_S_M6 } \
#               -hier_separator {/} \
#               -bus_naming_style {[%d]} \
#               -open  /home/jiangjf/ip_test/backend/icc/design_data/e203_soc_top.mw

create_mw_lib  -technology  $tech_file_path/saed32nm_1p9m_mw.tf     \
               -mw_reference_library {../ref/mw_lib/saed32nm_rvt_1p9m   \
                                      ../ref/mw_lib/sram_4kx64   	\
				                      ../ref/mw_lib/sram_8kx32} 	\
               -hier_separator {/} \
               -bus_naming_style {[%d]} \
               -open  ../design_data/e203_soc_top.mw
               #-open  ../design_data/conv_top.mw
#/home/jfjiang/lib/smic_130nm/SP013D3_V1p6/apollo/SP013D3_V1p6_6MT

set_check_library_options -all

#set TLU+ files
#set_tlu_plus_files   -max_tluplus   /home/library/wxsh/0d13um/013-CRD-DOC-V1.0/starrc/tluplus/thin/CSMCM1316M01_sal_cell_max.tluplus     \
#                     -min_tluplus   /home/library/wxsh/0d13um/013-CRD-DOC-V1.0/starrc/tluplus/thin/CSMCM1316M01_sal_cell_min.tluplus     \
#                     -tech2itf_map  /home/jiangjf/ip_test/backend/icc/tluplus_tf.map
set_tlu_plus_files   -max_tluplus   $refer_path/tluplus/saed32nm_1p9m_Cmax.tluplus     \
                     -min_tluplus   $refer_path/tluplus/saed32nm_1p9m_Cmin.tluplus     \
                     -tech2itf_map  $refer_path/tluplus/saed32nm_tf_itf_tluplus.map
#                     -tech2itf_map  /home/library/wxsh/0d13um/VS013/BEView_STDIO/VS-CSMC-13-Tapeout-Kit-V0.5/TECH/CSMC013E_layer_m6.map

check_tlu_plus_files
list_libs

#import designs
#import_designs -format verilog /home/jiangjf/ip_test/backend/dc/mapped/e203_soc_top_pad.v
import_designs -format verilog $home_path/dc/mapped/e203_soc_top.mapped.v
#import_designs -format verilog $home_path/dc/mapped/conv_top.mapped.v

#derive_pg_connection -power_net VDD -power_pin VDD -ground_net GND -ground_pin GND
#derive_pg_connection -power_net VDDH -power_pin VDDH -ground_net VSSH -ground_pin VSSH
#derive_pg_connection -power_net VDD -ground_net GND -tie
derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS
derive_pg_connection -power_net VDD -power_pin VDDPE -ground_net VSS -ground_pin VSSE
derive_pg_connection -power_net VDD -power_pin VDDCE -ground_net VSS -ground_pin VSSE
derive_pg_connection -power_net VDD -ground_net VSS -tie

check_mv_design -power_nets

#read_sdc /home/jiangjf/ip_test/backend/dc/mapped/e203_soc_top_pad.sdc
read_sdc $home_path/dc/mapped/e203_soc_top.sdc
#read_sdc $home_path/dc/mapped/conv_top.sdc

check_timing
report_timing_requirements
report_disable_timing
report_case_analysis
report_clock -skew


set_fix_multiple_port_nets -all -buffer_constants
save_mw_cel -as 1_data_setup

#
