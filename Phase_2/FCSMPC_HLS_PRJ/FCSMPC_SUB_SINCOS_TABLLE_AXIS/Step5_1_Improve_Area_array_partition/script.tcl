############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
############################################################
open_project FCSMPC_SUB_SINCOS_TABLLE_AXIS
set_top FCSMPC
add_files FCSMPC_2.0.cpp
add_files -tb FCSMPC_2.0_TB.cpp
open_solution "Step5_1_Improve_Area_array_partition"
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
config_dataflow -default_channel fifo -fifo_depth 1
source "./FCSMPC_SUB_SINCOS_TABLLE_AXIS/Step5_1_Improve_Area_array_partition/directives.tcl"
csim_design
csynth_design
cosim_design
export_design -format ip_catalog
