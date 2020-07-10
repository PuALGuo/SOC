#create_cell {Corner_LL} PSCORNER_D
#create_cell {Corner_LR} PSCORNER_D
#create_cell {Filler10} PSFILLER20
#create_cell {Filler11} PSFILLER20
#
#create_cell {Filler30} PSFILLER20
#create_cell {Filler31} PSFILLER20
#
#create_cell {Filler40} PSFILLER20
#create_cell {Filler41} PSFILLER20
#create_cell {Filler42} PSFILLER20
#create_cell {Filler43} PSFILLER20
#create_cell {Filler44} PSFILLER20
#create_cell {Filler45} PSFILLER20
#create_cell {Filler46} PSFILLER20
#create_cell {Filler47} PSFILLER20
#create_cell {Filler48} PSFILLER20
#create_cell {Filler49} PSFILLER20
#create_cell {Filler410} PSFILLER20
#create_cell {Filler411} PSFILLER20
#create_cell {Filler412} PSFILLER20
#create_cell {Filler413} PSFILLER20

#set_pad_physical_constraints -pad_name "Corner_LL"    -side 4
#set_pad_physical_constraints -pad_name "Corner_LR"    -side 3 -min_left_iospace 0

set_pad_physical_constraints -pad_name i_pad_lsel0 -side 1 -offset 195.9
set_pad_physical_constraints -pad_name i_pad_lsel1 -side 1 -offset 235.9
set_pad_physical_constraints -pad_name i_pad_lsel2 -side 1 -offset 295.9
set_pad_physical_constraints -pad_name i_pad_lsel3 -side 1 -offset 335.9
set_pad_physical_constraints -pad_name i_pad_lsel4 -side 1 -offset 395.9

#set_pad_physical_constraints -pad_name Filler10 -side 1 -offset 275.9
#set_pad_physical_constraints -pad_name Filler11 -side 1 -offset 375.9
#
#set_pad_physical_constraints -pad_name Filler30 -side 3 -offset 275.9
#set_pad_physical_constraints -pad_name Filler31 -side 3 -offset 375.9
#
#set_pad_physical_constraints -pad_name Filler40  -side 4 -offset 275.9
#set_pad_physical_constraints -pad_name Filler41  -side 4 -offset 375.9
#set_pad_physical_constraints -pad_name Filler42  -side 4 -offset 475.9
#set_pad_physical_constraints -pad_name Filler43  -side 4 -offset 575.9
#set_pad_physical_constraints -pad_name Filler44  -side 4 -offset 675.9
#set_pad_physical_constraints -pad_name Filler45  -side 4 -offset 775.9
#set_pad_physical_constraints -pad_name Filler46  -side 4 -offset 875.9
#set_pad_physical_constraints -pad_name Filler47  -side 4 -offset 975.9
#set_pad_physical_constraints -pad_name Filler48  -side 4 -offset 1075.9
#set_pad_physical_constraints -pad_name Filler49  -side 4 -offset 1175.9
#set_pad_physical_constraints -pad_name Filler410 -side 4 -offset 1275.9
#set_pad_physical_constraints -pad_name Filler411 -side 4 -offset 1375.9
#set_pad_physical_constraints -pad_name Filler412 -side 4 -offset 1475.9
#set_pad_physical_constraints -pad_name Filler413 -side 4 -offset 1575.9

set_pad_physical_constraints -pad_name i_pad_vssh2    -side 3 -offset 195.9
set_pad_physical_constraints -pad_name i_pad_vddh2    -side 3 -offset 235.9
set_pad_physical_constraints -pad_name i_pad_result0  -side 3 -offset 295.9
set_pad_physical_constraints -pad_name i_pad_result1  -side 3 -offset 335.9
set_pad_physical_constraints -pad_name i_pad_complete -side 3 -offset 395.9
set_pad_physical_constraints -pad_name i_pad_vssh1         -side 4 -offset 195.9
set_pad_physical_constraints -pad_name i_pad_vddh1         -side 4 -offset 235.9
set_pad_physical_constraints -pad_name i_pad_bsel0         -side 4 -offset 295.9
set_pad_physical_constraints -pad_name i_pad_bsel1         -side 4 -offset 335.9
set_pad_physical_constraints -pad_name i_pad_bsel2         -side 4 -offset 395.9
set_pad_physical_constraints -pad_name i_pad_bsel3         -side 4 -offset 435.9
set_pad_physical_constraints -pad_name i_pad_bsel4         -side 4 -offset 495.9
set_pad_physical_constraints -pad_name i_pad_bsel5         -side 4 -offset 535.9
set_pad_physical_constraints -pad_name i_pad_instruction0  -side 4 -offset 595.9
set_pad_physical_constraints -pad_name i_pad_instruction1  -side 4 -offset 635.9
set_pad_physical_constraints -pad_name i_pad_instruction2  -side 4 -offset 695.9
set_pad_physical_constraints -pad_name i_pad_instruction3  -side 4 -offset 735.9
set_pad_physical_constraints -pad_name i_pad_instruction4  -side 4 -offset 795.9
set_pad_physical_constraints -pad_name i_pad_instruction5  -side 4 -offset 835.9
set_pad_physical_constraints -pad_name i_pad_instruction6  -side 4 -offset 895.9
set_pad_physical_constraints -pad_name i_pad_instruction7  -side 4 -offset 935.9
set_pad_physical_constraints -pad_name i_pad_instruction8  -side 4 -offset 995.9
set_pad_physical_constraints -pad_name i_pad_instruction9  -side 4 -offset 1035.9
set_pad_physical_constraints -pad_name i_pad_instruction10 -side 4 -offset 1095.9
set_pad_physical_constraints -pad_name i_pad_instruction11 -side 4 -offset 1135.9
set_pad_physical_constraints -pad_name i_pad_instruction12 -side 4 -offset 1195.9
set_pad_physical_constraints -pad_name i_pad_instruction13 -side 4 -offset 1235.9
set_pad_physical_constraints -pad_name i_pad_instruction14 -side 4 -offset 1295.9
set_pad_physical_constraints -pad_name i_pad_instruction15 -side 4 -offset 1335.9
set_pad_physical_constraints -pad_name i_pad_stop          -side  4 -offset 1395.9
set_pad_physical_constraints -pad_name i_pad_start         -side 4 -offset 1435.9
set_pad_physical_constraints -pad_name i_pad_clk           -side 4 -offset 1495.9
set_pad_physical_constraints -pad_name i_pad_rst_n         -side 4 -offset 1535.9
set_pad_physical_constraints -pad_name i_pad_vssc          -side 4 -offset 1595.9
set_pad_physical_constraints -pad_name i_pad_vddc          -side 4 -offset 1635.9
#set_pad_physical_constraints -pad_name Corner_LR -lib_cell -lib_cell_orientation { FN N N N } 
