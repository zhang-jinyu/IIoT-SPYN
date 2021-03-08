############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
############################################################
set_directive_pipeline -enable_flush -rewind "FCSMPC/CAL_UD_UQ_LOOP"
set_directive_pipeline -enable_flush -rewind "FCSMPC/CAL_ID_IQ_LOOP"
set_directive_pipeline -enable_flush -rewind "FCSMPC/CAL_J_LOOP"
set_directive_interface -mode axis -register -register_mode both "FCSMPC" s_axis
set_directive_array_reshape -type complete -dim 1 "FCSMPC" sw_eff
set_directive_array_partition -type complete -dim 1 "FCSMPC" uk_pos
set_directive_array_reshape -type complete -dim 1 "FCSMPC" J
set_directive_unroll "FCSMPC/CAL_SW_EFF_OUTTER_LOOP"
set_directive_unroll "FCSMPC/CAL_SW_EFF_INNER_LOOP"
set_directive_dataflow "FCSMPC"
