#read_verilog 
#set rtl_dir /home/student/Desktop/Soc_lab1/DC/rtl/e203
set rtl_dir ../rtl/e203/CNN

#analyze -format verilog [glob $rtl_dir/core/*.v $rtl_dir/fab/*.v $rtl_dir/general/*.v $rtl_dir/mems/*.v $rtl_dir/perips/*.v $rtl_dir/soc/*.v $rtl_dir/subsys/*.v  $rtl_dir/debug/*.v]

analyze -format verilog [glob $rtl_dir/*.v]
elaborate $top


#read_verilog -rtl [glob $rtl_dir/*.v]
#elaborate WORK -library [glob $std_path/*.db]
