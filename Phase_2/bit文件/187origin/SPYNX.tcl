
################################################################
# This is a generated script based on design: zsys
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source zsys_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# Debounce, Phase_Test, deadtime, my_2_3MUX, SOH3, SOH3

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name zsys

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: FOC
proc create_hier_cell_FOC { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_FOC() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 I_ab_Filtered_m
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 I_ab_raw
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 I_ab_raw_m
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 I_alphabeta_m
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 I_dq_m
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 V_PWM
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 V_PWM_m
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 V_abc_m
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 V_alphabeta_m
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 V_dq_m

  # Create pins
  create_bd_pin -dir I -from 31 -to 0 Flux_Ki
  create_bd_pin -dir I -from 31 -to 0 Flux_Kp
  create_bd_pin -dir I -from 31 -to 0 Flux_Sp
  create_bd_pin -dir O -from 31 -to 0 -type data Id_out
  create_bd_pin -dir O -from 31 -to 0 -type data Iq_out
  create_bd_pin -dir O -from 31 -to 0 RPM
  create_bd_pin -dir I -from 31 -to 0 RPM_Ki
  create_bd_pin -dir I -from 31 -to 0 RPM_Kp
  create_bd_pin -dir I -from 31 -to 0 RPM_Sp
  create_bd_pin -dir I -from 31 -to 0 Torque_Ki
  create_bd_pin -dir I -from 31 -to 0 Torque_Kp
  create_bd_pin -dir I -from 31 -to 0 Torque_Sp
  create_bd_pin -dir I -from 31 -to 0 Vd
  create_bd_pin -dir I -from 31 -to 0 Vq
  create_bd_pin -dir I -type clk ap_clk
  create_bd_pin -dir I -type rst ap_rst_n
  create_bd_pin -dir I -from 31 -to 0 -type data control

  # Create instance: Clarke_Direct_0, and set properties
  set Clarke_Direct_0 [ create_bd_cell -type ip -vlnv trenz.biz:hls:Clarke_Direct:1.0 Clarke_Direct_0 ]

  # Create instance: Clarke_Inverse_0, and set properties
  set Clarke_Inverse_0 [ create_bd_cell -type ip -vlnv trenz.biz:hls:Clarke_Inverse:1.0 Clarke_Inverse_0 ]

  # Create instance: Filters_0, and set properties
  set Filters_0 [ create_bd_cell -type ip -vlnv trenz.biz:hls:Filters:1.0 Filters_0 ]

  # Create instance: Flux_Ki_slice, and set properties
  set Flux_Ki_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Flux_Ki_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Flux_Ki_slice

  # Create instance: Flux_Kp_slice, and set properties
  set Flux_Kp_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Flux_Kp_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Flux_Kp_slice

  # Create instance: Flux_PI_Control, and set properties
  set Flux_PI_Control [ create_bd_cell -type ip -vlnv trenz.biz:hls:PI_Control:1.0 Flux_PI_Control ]

  # Create instance: Flux_Sp_slice, and set properties
  set Flux_Sp_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Flux_Sp_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Flux_Sp_slice

  # Create instance: Park_Direct_0, and set properties
  set Park_Direct_0 [ create_bd_cell -type ip -vlnv trenz.biz:hls:Park_Direct:1.0 Park_Direct_0 ]

  # Create instance: Park_Inverse_0, and set properties
  set Park_Inverse_0 [ create_bd_cell -type ip -vlnv trenz.biz:hls:Park_Inverse:1.0 Park_Inverse_0 ]

  # Create instance: RPM_Ki_slice, and set properties
  set RPM_Ki_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 RPM_Ki_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $RPM_Ki_slice

  # Create instance: RPM_Kp_slice, and set properties
  set RPM_Kp_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 RPM_Kp_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $RPM_Kp_slice

  # Create instance: RPM_PI_Control, and set properties
  set RPM_PI_Control [ create_bd_cell -type ip -vlnv trenz.biz:hls:PI_Control:1.0 RPM_PI_Control ]

  # Create instance: RPM_Sp_slice, and set properties
  set RPM_Sp_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 RPM_Sp_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $RPM_Sp_slice

  # Create instance: SVPWM_0, and set properties
  set SVPWM_0 [ create_bd_cell -type ip -vlnv trenz.biz:hls:SVPWM:1.0 SVPWM_0 ]

  # Create instance: Torque_Ki_slice, and set properties
  set Torque_Ki_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Torque_Ki_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Torque_Ki_slice

  # Create instance: Torque_Kp_slice, and set properties
  set Torque_Kp_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Torque_Kp_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Torque_Kp_slice

  # Create instance: Torque_PI_Control, and set properties
  set Torque_PI_Control [ create_bd_cell -type ip -vlnv trenz.biz:hls:PI_Control:1.0 Torque_PI_Control ]

  # Create instance: Torque_Sp_slice, and set properties
  set Torque_Sp_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Torque_Sp_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Torque_Sp_slice

  # Create instance: axis_broadcaster_0, and set properties
  set axis_broadcaster_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 axis_broadcaster_0 ]
  set_property -dict [ list \
CONFIG.M00_TDATA_REMAP {tdata[15:0]} \
CONFIG.M01_TDATA_REMAP {tdata[31:16]} \
CONFIG.M02_TDATA_REMAP {tdata[47:32]} \
CONFIG.M03_TDATA_REMAP {tdata[63:48]} \
CONFIG.M_TDATA_NUM_BYTES {2} \
CONFIG.NUM_MI {4} \
CONFIG.S_TDATA_NUM_BYTES {8} \
 ] $axis_broadcaster_0

  # Create instance: flux_limit, and set properties
  set flux_limit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 flux_limit ]
  set_property -dict [ list \
CONFIG.CONST_VAL {16777215} \
CONFIG.CONST_WIDTH {32} \
 ] $flux_limit

  # Create instance: foc_control_0, and set properties
  set foc_control_0 [ create_bd_cell -type ip -vlnv trenz.biz:user:foc_control:1.0 foc_control_0 ]

  # Create instance: one, and set properties
  set one [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 one ]

  # Create instance: rpm_limit, and set properties
  set rpm_limit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 rpm_limit ]
  set_property -dict [ list \
CONFIG.CONST_VAL {16777215} \
CONFIG.CONST_WIDTH {32} \
 ] $rpm_limit

  # Create instance: torque_limit, and set properties
  set torque_limit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 torque_limit ]
  set_property -dict [ list \
CONFIG.CONST_VAL {16777215} \
CONFIG.CONST_WIDTH {32} \
 ] $torque_limit

  # Create interface connections
  connect_bd_intf_net -intf_net Clarke_Inverse_0_m_axis_V [get_bd_intf_pins Clarke_Inverse_0/m_axis_V] [get_bd_intf_pins SVPWM_0/s_axis_V]
  connect_bd_intf_net -intf_net [get_bd_intf_nets Clarke_Inverse_0_m_axis_V] [get_bd_intf_pins V_abc_m] [get_bd_intf_pins Clarke_Inverse_0/m_axis_V]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins I_ab_raw] [get_bd_intf_pins Filters_0/s_axis_V]
  connect_bd_intf_net -intf_net [get_bd_intf_nets Conn1] [get_bd_intf_pins I_ab_raw] [get_bd_intf_pins I_ab_raw_m]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins V_PWM] [get_bd_intf_pins SVPWM_0/m_axis_V]
  connect_bd_intf_net -intf_net [get_bd_intf_nets Conn3] [get_bd_intf_pins V_PWM] [get_bd_intf_pins V_PWM_m]
  connect_bd_intf_net -intf_net Filters_0_m_axis_V [get_bd_intf_pins Clarke_Direct_0/s_axis_V] [get_bd_intf_pins Filters_0/m_axis_V]
  connect_bd_intf_net -intf_net [get_bd_intf_nets Filters_0_m_axis_V] [get_bd_intf_pins I_ab_Filtered_m] [get_bd_intf_pins Filters_0/m_axis_V]
  connect_bd_intf_net -intf_net Flux_PI_Control_m_axis_V [get_bd_intf_pins Flux_PI_Control/m_axis_V] [get_bd_intf_pins foc_control_0/s_flux]
  connect_bd_intf_net -intf_net Park_Direct_0_m_axis_V [get_bd_intf_pins Park_Direct_0/m_axis_V] [get_bd_intf_pins axis_broadcaster_0/S_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets Park_Direct_0_m_axis_V] [get_bd_intf_pins I_dq_m] [get_bd_intf_pins axis_broadcaster_0/S_AXIS]
  connect_bd_intf_net -intf_net Park_Inverse_0_m_axis_V [get_bd_intf_pins Clarke_Inverse_0/s_axis_V] [get_bd_intf_pins Park_Inverse_0/m_axis_V]
  connect_bd_intf_net -intf_net [get_bd_intf_nets Park_Inverse_0_m_axis_V] [get_bd_intf_pins V_alphabeta_m] [get_bd_intf_pins Park_Inverse_0/m_axis_V]
  connect_bd_intf_net -intf_net RPM_PI_Control_m_axis_V [get_bd_intf_pins RPM_PI_Control/m_axis_V] [get_bd_intf_pins foc_control_0/s_rpm]
  connect_bd_intf_net -intf_net Torque_PI_Control_m_axis_V [get_bd_intf_pins Torque_PI_Control/m_axis_V] [get_bd_intf_pins foc_control_0/s_torque]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M00_AXIS [get_bd_intf_pins Flux_PI_Control/s_axis_V] [get_bd_intf_pins axis_broadcaster_0/M00_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M01_AXIS [get_bd_intf_pins Torque_PI_Control/s_axis_V] [get_bd_intf_pins axis_broadcaster_0/M01_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M02_AXIS [get_bd_intf_pins RPM_PI_Control/s_axis_V] [get_bd_intf_pins axis_broadcaster_0/M02_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M03_AXIS [get_bd_intf_pins axis_broadcaster_0/M03_AXIS] [get_bd_intf_pins foc_control_0/s_angle]
  connect_bd_intf_net -intf_net axis_broadcaster_1_M01_AXIS [get_bd_intf_pins Clarke_Direct_0/m_axis_V] [get_bd_intf_pins Park_Direct_0/s_axis_V]
  connect_bd_intf_net -intf_net [get_bd_intf_nets axis_broadcaster_1_M01_AXIS] [get_bd_intf_pins I_alphabeta_m] [get_bd_intf_pins Clarke_Direct_0/m_axis_V]
  connect_bd_intf_net -intf_net foc_control_0_m_axis [get_bd_intf_pins Park_Inverse_0/s_axis_V] [get_bd_intf_pins foc_control_0/m_axis]
  connect_bd_intf_net -intf_net [get_bd_intf_nets foc_control_0_m_axis] [get_bd_intf_pins V_dq_m] [get_bd_intf_pins foc_control_0/m_axis]

  # Create port connections
  connect_bd_net -net Din1_1 [get_bd_pins RPM_Kp] [get_bd_pins RPM_Kp_slice/Din]
  connect_bd_net -net Din2_1 [get_bd_pins RPM_Ki] [get_bd_pins RPM_Ki_slice/Din]
  connect_bd_net -net Din3_1 [get_bd_pins Flux_Sp] [get_bd_pins Flux_Sp_slice/Din]
  connect_bd_net -net Din4_1 [get_bd_pins Flux_Kp] [get_bd_pins Flux_Kp_slice/Din]
  connect_bd_net -net Din5_1 [get_bd_pins Flux_Ki] [get_bd_pins Flux_Ki_slice/Din]
  connect_bd_net -net Din6_1 [get_bd_pins Torque_Kp] [get_bd_pins Torque_Kp_slice/Din]
  connect_bd_net -net Din7_1 [get_bd_pins Torque_Ki] [get_bd_pins Torque_Ki_slice/Din]
  connect_bd_net -net Din_1 [get_bd_pins RPM_Sp] [get_bd_pins RPM_Sp_slice/Din]
  connect_bd_net -net Filters_0_RPM_out [get_bd_pins RPM] [get_bd_pins Filters_0/RPM_out]
  connect_bd_net -net Flux_Ki_slice_Dout [get_bd_pins Flux_Ki_slice/Dout] [get_bd_pins Flux_PI_Control/Ki]
  connect_bd_net -net Flux_Kp_slice_Dout [get_bd_pins Flux_Kp_slice/Dout] [get_bd_pins Flux_PI_Control/Kp]
  connect_bd_net -net Flux_Sp_slice_Dout [get_bd_pins Flux_PI_Control/Sp] [get_bd_pins Flux_Sp_slice/Dout]
  connect_bd_net -net Park_Direct_0_Id_out [get_bd_pins Id_out] [get_bd_pins Park_Direct_0/Id_out]
  connect_bd_net -net Park_Direct_0_Iq_out [get_bd_pins Iq_out] [get_bd_pins Park_Direct_0/Iq_out]
  connect_bd_net -net RPM_Ki_slice_Dout [get_bd_pins RPM_Ki_slice/Dout] [get_bd_pins RPM_PI_Control/Ki]
  connect_bd_net -net RPM_Kp_slice_Dout [get_bd_pins RPM_Kp_slice/Dout] [get_bd_pins RPM_PI_Control/Kp]
  connect_bd_net -net RPM_Sp_slice_Dout [get_bd_pins RPM_PI_Control/Sp] [get_bd_pins RPM_Sp_slice/Dout]
  connect_bd_net -net Torque_Ki_slice_Dout [get_bd_pins Torque_Ki_slice/Dout] [get_bd_pins Torque_PI_Control/Ki]
  connect_bd_net -net Torque_Kp_slice_Dout [get_bd_pins Torque_Kp_slice/Dout] [get_bd_pins Torque_PI_Control/Kp]
  connect_bd_net -net Torque_Sp_1 [get_bd_pins Torque_Sp] [get_bd_pins Torque_Sp_slice/Din]
  connect_bd_net -net Torque_Sp_slice_Dout [get_bd_pins Torque_Sp_slice/Dout] [get_bd_pins foc_control_0/torque_sp_in]
  connect_bd_net -net Vd_1 [get_bd_pins Vd] [get_bd_pins foc_control_0/vd_in]
  connect_bd_net -net Vq_1 [get_bd_pins Vq] [get_bd_pins foc_control_0/vq_in]
  connect_bd_net -net ap_clk_1 [get_bd_pins ap_clk] [get_bd_pins Clarke_Direct_0/ap_clk] [get_bd_pins Clarke_Inverse_0/ap_clk] [get_bd_pins Filters_0/ap_clk] [get_bd_pins Flux_PI_Control/ap_clk] [get_bd_pins Park_Direct_0/ap_clk] [get_bd_pins Park_Inverse_0/ap_clk] [get_bd_pins RPM_PI_Control/ap_clk] [get_bd_pins SVPWM_0/ap_clk] [get_bd_pins Torque_PI_Control/ap_clk] [get_bd_pins axis_broadcaster_0/aclk] [get_bd_pins foc_control_0/axis_aclk]
  connect_bd_net -net ap_rst_n_1 [get_bd_pins ap_rst_n] [get_bd_pins Clarke_Direct_0/ap_rst_n] [get_bd_pins Clarke_Inverse_0/ap_rst_n] [get_bd_pins Filters_0/ap_rst_n] [get_bd_pins Flux_PI_Control/ap_rst_n] [get_bd_pins Park_Direct_0/ap_rst_n] [get_bd_pins Park_Inverse_0/ap_rst_n] [get_bd_pins RPM_PI_Control/ap_rst_n] [get_bd_pins SVPWM_0/ap_rst_n] [get_bd_pins Torque_PI_Control/ap_rst_n] [get_bd_pins axis_broadcaster_0/aresetn] [get_bd_pins foc_control_0/axis_aresetn]
  connect_bd_net -net control_1 [get_bd_pins control] [get_bd_pins Filters_0/control] [get_bd_pins Flux_PI_Control/mode] [get_bd_pins RPM_PI_Control/mode] [get_bd_pins Torque_PI_Control/mode] [get_bd_pins foc_control_0/control_in]
  connect_bd_net -net flux_limit_dout [get_bd_pins Flux_PI_Control/limit] [get_bd_pins flux_limit/dout]
  connect_bd_net -net foc_control_0_torque_sp_out [get_bd_pins Torque_PI_Control/Sp] [get_bd_pins foc_control_0/torque_sp_out]
  connect_bd_net -net one_dout [get_bd_pins Clarke_Direct_0/ap_start] [get_bd_pins Clarke_Inverse_0/ap_start] [get_bd_pins Filters_0/ap_start] [get_bd_pins Flux_PI_Control/ap_start] [get_bd_pins Park_Direct_0/ap_start] [get_bd_pins Park_Inverse_0/ap_start] [get_bd_pins RPM_PI_Control/ap_start] [get_bd_pins SVPWM_0/ap_start] [get_bd_pins Torque_PI_Control/ap_start] [get_bd_pins one/dout]
  connect_bd_net -net rpm_limit_dout [get_bd_pins RPM_PI_Control/limit] [get_bd_pins rpm_limit/dout]
  connect_bd_net -net torque_limit_dout [get_bd_pins Torque_PI_Control/limit] [get_bd_pins torque_limit/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: FCSMPC
proc create_hier_cell_FCSMPC { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_FCSMPC() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 Idq_m
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:acc_handshake_rtl:1.0 ap_ctrl

  # Create pins
  create_bd_pin -dir O -from 2 -to 0 GH
  create_bd_pin -dir O GH_V_ap_vld
  create_bd_pin -dir O -from 2 -to 0 GL
  create_bd_pin -dir O -from 15 -to 0 Id_exp
  create_bd_pin -dir O -from 15 -to 0 Id_out
  create_bd_pin -dir O -from 15 -to 0 Iq_exp
  create_bd_pin -dir O -from 15 -to 0 Iq_out
  create_bd_pin -dir I -from 31 -to 0 -type data MPC_Control
  create_bd_pin -dir I -from 15 -to 0 -type data angle
  create_bd_pin -dir I -type clk ap_clk
  create_bd_pin -dir I -type rst axis_in_aresetn
  create_bd_pin -dir I -from 31 -to 0 -type data iq_SP

  # Create instance: AXI_to_Signal_0, and set properties
  set AXI_to_Signal_0 [ create_bd_cell -type ip -vlnv mwn.de:user:AXI_to_Signal:1.0 AXI_to_Signal_0 ]

  # Create instance: FCSMPC_0, and set properties
  set FCSMPC_0 [ create_bd_cell -type ip -vlnv TUM_EAL:hls:FCSMPC:3.2 FCSMPC_0 ]

  # Create instance: Iq_Sp_slice, and set properties
  set Iq_Sp_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Iq_Sp_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Iq_Sp_slice

  # Create instance: MPC_Trigger_v1_0_0, and set properties
  set MPC_Trigger_v1_0_0 [ create_bd_cell -type ip -vlnv TUM_EAL:user:MPC_Trigger_v1_0:1.0 MPC_Trigger_v1_0_0 ]

  # Create instance: P_sample, and set properties
  set P_sample [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 P_sample ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0x35abcc77} \
CONFIG.CONST_WIDTH {32} \
 ] $P_sample

  # Create instance: R_over_L, and set properties
  set R_over_L [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 R_over_L ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0x452ca6e5} \
CONFIG.CONST_WIDTH {32} \
 ] $R_over_L

  # Create instance: SOH3_0, and set properties
  set block_name SOH3
  set block_cell_name SOH3_0
  if { [catch {set SOH3_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $SOH3_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: SOH3_1, and set properties
  set block_name SOH3
  set block_cell_name SOH3_1
  if { [catch {set SOH3_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $SOH3_1 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: one_over_L, and set properties
  set one_over_L [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 one_over_L ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0x44960000} \
CONFIG.CONST_WIDTH {32} \
 ] $one_over_L

  # Create instance: reset, and set properties
  set reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 reset ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
 ] $reset

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $xlslice_0

  # Create instance: zeros, and set properties
  set zeros [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zeros ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {16} \
 ] $zeros

  # Create interface connections
  connect_bd_intf_net -intf_net Conn [get_bd_intf_pins Idq_m] [get_bd_intf_pins AXI_to_Signal_0/AXIS_IN]
  connect_bd_intf_net -intf_net MPC_Trigger_v1_0_0_ap_ctrl [get_bd_intf_pins FCSMPC_0/ap_ctrl] [get_bd_intf_pins MPC_Trigger_v1_0_0/ap_ctrl]
  connect_bd_intf_net -intf_net [get_bd_intf_nets MPC_Trigger_v1_0_0_ap_ctrl] [get_bd_intf_pins ap_ctrl] [get_bd_intf_pins FCSMPC_0/ap_ctrl]

  # Create port connections
  connect_bd_net -net AXI_to_Signal_0_Valid [get_bd_pins AXI_to_Signal_0/Valid] [get_bd_pins MPC_Trigger_v1_0_0/AXI_data_valid]
  connect_bd_net -net FCSMPC_0_GH_V [get_bd_pins FCSMPC_0/GH_V] [get_bd_pins SOH3_1/Data]
  connect_bd_net -net FCSMPC_0_GH_V_ap_vld [get_bd_pins GH_V_ap_vld] [get_bd_pins FCSMPC_0/GH_V_ap_vld] [get_bd_pins SOH3_1/Valid]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets FCSMPC_0_GH_V_ap_vld]
  connect_bd_net -net FCSMPC_0_GL_V [get_bd_pins FCSMPC_0/GL_V] [get_bd_pins SOH3_0/Data]
  connect_bd_net -net FCSMPC_0_GL_V_ap_vld [get_bd_pins FCSMPC_0/GL_V_ap_vld] [get_bd_pins SOH3_0/Valid]
  connect_bd_net -net FCSMPC_0_id_exp [get_bd_pins Id_exp] [get_bd_pins FCSMPC_0/id_exp]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets FCSMPC_0_id_exp]
  connect_bd_net -net FCSMPC_0_iq_exp [get_bd_pins Iq_exp] [get_bd_pins FCSMPC_0/iq_exp]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets FCSMPC_0_iq_exp]
  connect_bd_net -net P_Controller_0_RPM [get_bd_pins AXI_to_Signal_0/Signal_47_32] [get_bd_pins FCSMPC_0/RPM]
  connect_bd_net -net R_over_L_dout [get_bd_pins FCSMPC_0/R_over_L] [get_bd_pins R_over_L/dout]
  connect_bd_net -net SOH3_0_Data_vld [get_bd_pins GL] [get_bd_pins SOH3_0/Data_vld]
  connect_bd_net -net SOH3_1_Data_vld [get_bd_pins GH] [get_bd_pins SOH3_1/Data_vld]
  connect_bd_net -net Torque_Sp_slice_Dout [get_bd_pins FCSMPC_0/iq_SP] [get_bd_pins Iq_Sp_slice/Dout]
  connect_bd_net -net angle_1 [get_bd_pins angle] [get_bd_pins FCSMPC_0/angle]
  connect_bd_net -net ap_clk_1 [get_bd_pins ap_clk] [get_bd_pins AXI_to_Signal_0/axis_in_aclk] [get_bd_pins FCSMPC_0/ap_clk] [get_bd_pins MPC_Trigger_v1_0_0/ap_clk] [get_bd_pins SOH3_0/clk] [get_bd_pins SOH3_1/clk]
  connect_bd_net -net axis_in_aresetn_1 [get_bd_pins axis_in_aresetn] [get_bd_pins AXI_to_Signal_0/axis_in_aresetn] [get_bd_pins MPC_Trigger_v1_0_0/ap_rst]
  connect_bd_net -net iq_SP_1 [get_bd_pins iq_SP] [get_bd_pins Iq_Sp_slice/Din]
  connect_bd_net -net one_over_L1_1 [get_bd_pins MPC_Control] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net one_over_L1_dout [get_bd_pins FCSMPC_0/sampling_period] [get_bd_pins P_sample/dout]
  connect_bd_net -net one_over_L_dout [get_bd_pins FCSMPC_0/one_over_L] [get_bd_pins one_over_L/dout]
  connect_bd_net -net reset_dout [get_bd_pins FCSMPC_0/ap_rst] [get_bd_pins reset/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins FCSMPC_0/lm_over_c_i_sqr] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins Id_out] [get_bd_pins AXI_to_Signal_0/Signal_15_0] [get_bd_pins FCSMPC_0/id_m]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets xlslice_1_Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins Iq_out] [get_bd_pins AXI_to_Signal_0/Signal_31_16] [get_bd_pins FCSMPC_0/iq_m]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets xlslice_2_Dout]
  connect_bd_net -net zeros_dout [get_bd_pins FCSMPC_0/id_SP] [get_bd_pins zeros/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports
  set ENC_A [ create_bd_port -dir I ENC_A ]
  set ENC_B [ create_bd_port -dir I ENC_B ]
  set ENC_I [ create_bd_port -dir I ENC_I ]
  set GH [ create_bd_port -dir O -from 2 -to 0 GH ]
  set GL [ create_bd_port -dir O -from 2 -to 0 GL ]
  set SCLK [ create_bd_port -dir O SCLK ]
  set SDI1 [ create_bd_port -dir I SDI1 ]
  set SDI2 [ create_bd_port -dir I SDI2 ]
  set SDI3 [ create_bd_port -dir I SDI3 ]
  set SDV [ create_bd_port -dir I SDV ]
  set SW_0 [ create_bd_port -dir I SW_0 ]
  set led [ create_bd_port -dir O -from 3 -to 0 led ]

  # Create instance: Angle_RPM_Ib_Ia, and set properties
  set Angle_RPM_Ib_Ia [ create_bd_cell -type ip -vlnv trenz.biz:user:axis_concat:1.0 Angle_RPM_Ib_Ia ]
  set_property -dict [ list \
CONFIG.C_A_TDATA_WIDTH {32} \
CONFIG.C_IN_CHANNELS {3} \
CONFIG.M_TDATA_WIDTH {64} \
 ] $Angle_RPM_Ib_Ia

  # Create instance: Angle_Shift_slice, and set properties
  set Angle_Shift_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Angle_Shift_slice ]
  set_property -dict [ list \
CONFIG.DIN_FROM {15} \
CONFIG.DOUT_WIDTH {16} \
 ] $Angle_Shift_slice

  # Create instance: Angle_concat, and set properties
  set Angle_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 Angle_concat ]
  set_property -dict [ list \
CONFIG.IN0_WIDTH {16} \
CONFIG.IN1_WIDTH {16} \
 ] $Angle_concat

  # Create instance: Debounce_0, and set properties
  set block_name Debounce
  set block_cell_name Debounce_0
  if { [catch {set Debounce_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Debounce_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: Decimate_Samples, and set properties
  set Decimate_Samples [ create_bd_cell -type ip -vlnv trenz.biz:user:axis_decimate:1.0 Decimate_Samples ]
  set_property -dict [ list \
CONFIG.C_TDATA_WIDTH {64} \
 ] $Decimate_Samples

  # Create instance: FCSMPC
  create_hier_cell_FCSMPC [current_bd_instance .] FCSMPC

  # Create instance: FOC
  create_hier_cell_FOC [current_bd_instance .] FOC

  # Create instance: I_a_Ib, and set properties
  set I_a_Ib [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 I_a_Ib ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {4} \
CONFIG.S_TDATA_NUM_BYTES {8} \
CONFIG.TDATA_REMAP {tdata[31:0]} \
 ] $I_a_Ib

  # Create instance: Phase_Test_0, and set properties
  set block_name Phase_Test
  set block_cell_name Phase_Test_0
  if { [catch {set Phase_Test_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Phase_Test_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axi_datamover_0, and set properties
  set axi_datamover_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_datamover:5.1 axi_datamover_0 ]
  set_property -dict [ list \
CONFIG.c_enable_mm2s {0} \
CONFIG.c_include_mm2s {Omit} \
CONFIG.c_include_mm2s_stsfifo {false} \
CONFIG.c_m_axi_s2mm_id_width {0} \
CONFIG.c_mm2s_include_sf {false} \
CONFIG.c_s2mm_btt_used {23} \
CONFIG.c_s2mm_burst_size {8} \
CONFIG.c_s2mm_include_sf {false} \
CONFIG.c_s2mm_support_indet_btt {true} \
 ] $axi_datamover_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
 ] $axi_interconnect_0

  # Create instance: axis_AD7403_0, and set properties
  set axis_AD7403_0 [ create_bd_cell -type ip -vlnv trenz.biz:user:axis_AD7403:1.0 axis_AD7403_0 ]
  set_property -dict [ list \
CONFIG.C_CLOCK_RATIO {5} \
CONFIG.C_DECIMATION {32} \
CONFIG.C_SIGNED {true} \
 ] $axis_AD7403_0

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_0 ]
  set_property -dict [ list \
CONFIG.FIFO_DEPTH {8192} \
CONFIG.IS_ACLK_ASYNC {0} \
 ] $axis_data_fifo_0

  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_1 ]
  set_property -dict [ list \
CONFIG.ACLKEN_CONV_MODE {0} \
CONFIG.FIFO_DEPTH {128} \
CONFIG.IS_ACLK_ASYNC {0} \
 ] $axis_data_fifo_1

  # Create instance: axis_encoder_0, and set properties
  set axis_encoder_0 [ create_bd_cell -type ip -vlnv trenz.biz:user:axis_encoder:1.0 axis_encoder_0 ]
  set_property -dict [ list \
CONFIG.C_ANGLE_AXIS {true} \
CONFIG.C_CPR {1000} \
CONFIG.C_RPM_AXIS {true} \
CONFIG.C_USE_SHIFT {true} \
 ] $axis_encoder_0

  # Create instance: axis_monitor_0, and set properties
  set axis_monitor_0 [ create_bd_cell -type ip -vlnv trenz.biz:user:axis_monitor:1.1 axis_monitor_0 ]
  set_property -dict [ list \
CONFIG.C_SLAVE_IF {8} \
 ] $axis_monitor_0

  # Create instance: axis_pwm_0, and set properties
  set axis_pwm_0 [ create_bd_cell -type ip -vlnv trenz.biz:user:axis_pwm:1.0 axis_pwm_0 ]
  set_property -dict [ list \
CONFIG.C_CHANNELS {3} \
CONFIG.C_DEADTIME_SYCLES {50} \
CONFIG.C_IN_TYPE {1} \
CONFIG.C_S_AXIS_TDATA_WIDTH {64} \
 ] $axis_pwm_0

  # Create instance: capture_axi_PYNQ, and set properties
  set capture_axi_PYNQ [ create_bd_cell -type ip -vlnv trenz.biz:user:AXI_StreamCapture:1.0 capture_axi_PYNQ ]

  # Create instance: control_axi_block, and set properties
  set control_axi_block [ create_bd_cell -type ip -vlnv trenz.biz:user:axi_reg32:1.0 control_axi_block ]
  set_property USER_COMMENTS.comment_1 "0 Control
1 Flux_SP
2 Flux_KP
3 Flux_KI
4 Torq_SP
5 Torq_KP
6 Torq_KI
7 RPM_SP
8 RPM_KP
9 RPM_KI
10 Shift
11 VD
12 VQ
13 Decimate
14 MPC Control
15 Corntrol2" [get_bd_cells /control_axi_block]
  set_property USER_COMMENTS.comment_2 "0 Angle
1 Speed
2 I_d
3 I_q
4 debug" [get_bd_cells /control_axi_block]
  set_property -dict [ list \
CONFIG.C_NUM_RO_REG {5} \
CONFIG.C_NUM_WR_REG {16} \
CONFIG.C_RR0_ALIAS {RR0_Angle} \
CONFIG.C_RR1_ALIAS {RR1_RPM} \
CONFIG.C_RR2_ALIAS {RR2_Id} \
CONFIG.C_RR3_ALIAS {RR3_Iq} \
CONFIG.C_WR0_ALIAS {Control} \
CONFIG.C_WR10_ALIAS {Angle Shift} \
CONFIG.C_WR10_DEFAULT {719} \
CONFIG.C_WR11_ALIAS {Vd} \
CONFIG.C_WR11_DEFAULT {-7424} \
CONFIG.C_WR12_ALIAS {Vq} \
CONFIG.C_WR12_DEFAULT {15000} \
CONFIG.C_WR13_ALIAS {Decimation} \
CONFIG.C_WR14_ALIAS {TR_Control} \
CONFIG.C_WR1_ALIAS {Flux Sp} \
CONFIG.C_WR2_ALIAS {Flux Kp} \
CONFIG.C_WR2_DEFAULT {-45056} \
CONFIG.C_WR3_ALIAS {Flux Ki} \
CONFIG.C_WR4_ALIAS {Torque Sp} \
CONFIG.C_WR4_DEFAULT {100} \
CONFIG.C_WR5_ALIAS {Torque Kp} \
CONFIG.C_WR5_DEFAULT {256} \
CONFIG.C_WR6_ALIAS {Torque Ki} \
CONFIG.C_WR7_ALIAS {RPM Sp} \
CONFIG.C_WR7_DEFAULT {3000} \
CONFIG.C_WR8_ALIAS {RPM Kp} \
CONFIG.C_WR8_DEFAULT {744} \
CONFIG.C_WR9_ALIAS {RPM Ki} \
CONFIG.C_WR9_DEFAULT {9} \
 ] $control_axi_block

  # Create instance: deadtime_0, and set properties
  set block_name deadtime
  set block_cell_name deadtime_0
  if { [catch {set deadtime_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $deadtime_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: fit_timer_0, and set properties
  set fit_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fit_timer:2.0 fit_timer_0 ]
  set_property -dict [ list \
CONFIG.C_NO_CLOCKS {1000} \
 ] $fit_timer_0

  # Create instance: my_2_3MUX_0, and set properties
  set block_name my_2_3MUX
  set block_cell_name my_2_3MUX_0
  if { [catch {set my_2_3MUX_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $my_2_3MUX_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.preset {ZedBoard} \
 ] $processing_system7_0

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {3} \
 ] $ps7_0_axi_periph

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.0 system_ila_0 ]
  set_property -dict [ list \
CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
CONFIG.C_ADV_TRIGGER {false} \
CONFIG.C_BRAM_CNT {49} \
CONFIG.C_DATA_DEPTH {8192} \
CONFIG.C_EN_STRG_QUAL {1} \
CONFIG.C_MON_TYPE {MIX} \
CONFIG.C_NUM_MONITOR_SLOTS {4} \
CONFIG.C_NUM_OF_PROBES {8} \
CONFIG.C_PROBE0_MU_CNT {2} \
CONFIG.C_PROBE0_TYPE {0} \
CONFIG.C_PROBE1_MU_CNT {2} \
CONFIG.C_PROBE1_TYPE {0} \
CONFIG.C_PROBE2_MU_CNT {2} \
CONFIG.C_PROBE2_TYPE {0} \
CONFIG.C_PROBE3_MU_CNT {2} \
CONFIG.C_PROBE3_TYPE {0} \
CONFIG.C_PROBE4_MU_CNT {2} \
CONFIG.C_PROBE4_TYPE {0} \
CONFIG.C_PROBE5_MU_CNT {2} \
CONFIG.C_PROBE6_MU_CNT {2} \
CONFIG.C_PROBE7_MU_CNT {2} \
CONFIG.C_SLOT {0} \
CONFIG.C_SLOT_0_APC_EN {0} \
CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
CONFIG.C_SLOT_1_APC_EN {0} \
CONFIG.C_SLOT_1_AXI_DATA_SEL {1} \
CONFIG.C_SLOT_1_AXI_TRIG_SEL {1} \
CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
CONFIG.C_SLOT_2_APC_EN {0} \
CONFIG.C_SLOT_2_AXI_DATA_SEL {1} \
CONFIG.C_SLOT_2_AXI_TRIG_SEL {1} \
CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
CONFIG.C_SLOT_3_INTF_TYPE {xilinx.com:interface:acc_handshake_rtl:1.0} \
CONFIG.C_SLOT_3_TYPE {0} \
 ] $system_ila_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {4} \
 ] $xlconcat_0

  # Create instance: xlconcat_2, and set properties
  set xlconcat_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_2 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {4} \
 ] $xlconcat_2

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {3} \
CONFIG.DOUT_WIDTH {4} \
 ] $xlslice_1

  # Create instance: zero_16, and set properties
  set zero_16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_16 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {16} \
 ] $zero_16

  # Create interface connections
  connect_bd_intf_net -intf_net AXI_StreamCapture_0_m_axis_s2mm [get_bd_intf_pins axi_datamover_0/S_AXIS_S2MM] [get_bd_intf_pins capture_axi_PYNQ/m_axis_s2mm]
  connect_bd_intf_net -intf_net AXI_StreamCapture_0_m_axis_s2mm_cmd [get_bd_intf_pins axi_datamover_0/S_AXIS_S2MM_CMD] [get_bd_intf_pins capture_axi_PYNQ/m_axis_s2mm_cmd]
  connect_bd_intf_net -intf_net Angle_RPM_Ib_Ia_m_axis [get_bd_intf_pins Angle_RPM_Ib_Ia/m_axis] [get_bd_intf_pins FOC/I_ab_raw]
connect_bd_intf_net -intf_net Conn [get_bd_intf_pins FOC/I_ab_raw_m] [get_bd_intf_pins axis_monitor_0/s01_axis]
connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins FOC/I_alphabeta_m] [get_bd_intf_pins axis_monitor_0/s02_axis]
connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins FOC/I_dq_m] [get_bd_intf_pins axis_monitor_0/s03_axis]
connect_bd_intf_net -intf_net [get_bd_intf_nets Conn2] [get_bd_intf_pins FCSMPC/Idq_m] [get_bd_intf_pins FOC/I_dq_m]
connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins FOC/V_dq_m] [get_bd_intf_pins axis_monitor_0/s04_axis]
connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins FOC/V_PWM_m] [get_bd_intf_pins axis_monitor_0/s07_axis]
connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins FOC/V_abc_m] [get_bd_intf_pins axis_monitor_0/s06_axis]
connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins FOC/I_ab_Filtered_m] [get_bd_intf_pins axis_monitor_0/s00_axis]
connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins FOC/V_alphabeta_m] [get_bd_intf_pins axis_monitor_0/s05_axis]
connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins FCSMPC/ap_ctrl] [get_bd_intf_pins system_ila_0/SLOT_3_ACC_HANDSHAKE]
  connect_bd_intf_net -intf_net FOC_m_axis_V [get_bd_intf_pins FOC/V_PWM] [get_bd_intf_pins axis_pwm_0/S_AXIS]
  connect_bd_intf_net -intf_net axi_datamover_0_M_AXIS_S2MM_STS [get_bd_intf_pins axi_datamover_0/M_AXIS_S2MM_STS] [get_bd_intf_pins capture_axi_PYNQ/s_axis_s2mm_sts]
  connect_bd_intf_net -intf_net axi_datamover_0_M_AXI_S2MM [get_bd_intf_pins axi_datamover_0/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net axis_AD7403_0_m_axis [get_bd_intf_pins axis_AD7403_0/m_axis] [get_bd_intf_pins axis_data_fifo_1/S_AXIS]
connect_bd_intf_net -intf_net [get_bd_intf_nets axis_AD7403_0_m_axis] [get_bd_intf_pins axis_data_fifo_1/S_AXIS] [get_bd_intf_pins system_ila_0/SLOT_1_AXIS]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_intf_nets axis_AD7403_0_m_axis]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins Decimate_Samples/m_axis] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS1 [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins capture_axi_PYNQ/s_axis]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins I_a_Ib/S_AXIS] [get_bd_intf_pins axis_data_fifo_1/M_AXIS]
  connect_bd_intf_net -intf_net axis_encoder_0_m_angle [get_bd_intf_pins Angle_RPM_Ib_Ia/sc_axis] [get_bd_intf_pins axis_encoder_0/m_angle]
  connect_bd_intf_net -intf_net axis_encoder_0_m_rpm [get_bd_intf_pins Angle_RPM_Ib_Ia/sb_axis] [get_bd_intf_pins axis_encoder_0/m_rpm]
  connect_bd_intf_net -intf_net axis_monitor_0_m_axis [get_bd_intf_pins Decimate_Samples/s_axis] [get_bd_intf_pins axis_monitor_0/m_axis]
connect_bd_intf_net -intf_net [get_bd_intf_nets axis_monitor_0_m_axis] [get_bd_intf_pins axis_monitor_0/m_axis] [get_bd_intf_pins system_ila_0/SLOT_0_AXIS]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_intf_nets axis_monitor_0_m_axis]
  connect_bd_intf_net -intf_net axis_subset_converter_0_M_AXIS [get_bd_intf_pins Angle_RPM_Ib_Ia/sa_axis] [get_bd_intf_pins I_a_Ib/M_AXIS]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins control_axi_block/S_AXI] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M01_AXI [get_bd_intf_pins capture_axi_PYNQ/S_AXI] [get_bd_intf_pins ps7_0_axi_periph/M01_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins ps7_0_axi_periph/ARESETN]
  connect_bd_net -net A_1 [get_bd_ports ENC_A] [get_bd_pins axis_encoder_0/A] [get_bd_pins xlconcat_2/In2]
  connect_bd_net -net Angle_Shift_slice_Dout [get_bd_pins Angle_Shift_slice/Dout] [get_bd_pins axis_encoder_0/angle_shift]
  connect_bd_net -net B_1 [get_bd_ports ENC_B] [get_bd_pins axis_encoder_0/B] [get_bd_pins xlconcat_2/In3]
  connect_bd_net -net Debounce_0_DBx [get_bd_pins Debounce_0/DBx] [get_bd_pins my_2_3MUX_0/SEL] [get_bd_pins system_ila_0/probe7] [get_bd_pins xlconcat_2/In0]
  connect_bd_net -net FCSMPC_GH [get_bd_pins FCSMPC/GH] [get_bd_pins deadtime_0/GH_IN]
  connect_bd_net -net FCSMPC_GH_V_ap_vld [get_bd_pins FCSMPC/GH_V_ap_vld] [get_bd_pins system_ila_0/probe2]
  connect_bd_net -net FCSMPC_GL [get_bd_pins FCSMPC/GL] [get_bd_pins deadtime_0/GL_IN]
  connect_bd_net -net FCSMPC_Id_exp [get_bd_pins FCSMPC/Id_exp] [get_bd_pins system_ila_0/probe3]
  connect_bd_net -net FCSMPC_Id_out [get_bd_pins FCSMPC/Id_out] [get_bd_pins system_ila_0/probe0]
  connect_bd_net -net FCSMPC_Iq_exp [get_bd_pins FCSMPC/Iq_exp] [get_bd_pins system_ila_0/probe4]
  connect_bd_net -net FCSMPC_Iq_out [get_bd_pins FCSMPC/Iq_out] [get_bd_pins system_ila_0/probe1]
  connect_bd_net -net FOC_Id_out [get_bd_pins FOC/Id_out] [get_bd_pins control_axi_block/RR2]
  connect_bd_net -net FOC_Iq_out [get_bd_pins FOC/Iq_out] [get_bd_pins control_axi_block/RR3]
  connect_bd_net -net FOC_dout [get_bd_pins FOC/RPM] [get_bd_pins control_axi_block/RR1]
  connect_bd_net -net I_1 [get_bd_ports ENC_I] [get_bd_pins axis_encoder_0/I] [get_bd_pins xlconcat_2/In1]
  connect_bd_net -net SDI1_1 [get_bd_ports SDI1] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net SDI2_1 [get_bd_ports SDI2] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net SDI3_1 [get_bd_ports SDI3] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net SDV_1 [get_bd_ports SDV] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net SW_0_1 [get_bd_ports SW_0] [get_bd_pins Debounce_0/x]
  connect_bd_net -net Vq_1 [get_bd_pins FOC/Vq] [get_bd_pins control_axi_block/WR12]
  connect_bd_net -net axi_reg32_0_WR0 [get_bd_pins FOC/control] [get_bd_pins control_axi_block/WR0]
  connect_bd_net -net axi_reg32_0_WR1 [get_bd_pins FOC/Flux_Sp] [get_bd_pins control_axi_block/WR1]
  connect_bd_net -net axi_reg32_0_WR2 [get_bd_pins FOC/Flux_Kp] [get_bd_pins control_axi_block/WR2]
  connect_bd_net -net axi_reg32_0_WR3 [get_bd_pins FOC/Flux_Ki] [get_bd_pins control_axi_block/WR3]
  connect_bd_net -net axi_reg32_0_WR4 [get_bd_pins FCSMPC/iq_SP] [get_bd_pins FOC/Torque_Sp] [get_bd_pins control_axi_block/WR4]
  connect_bd_net -net axi_reg32_0_WR5 [get_bd_pins FOC/Torque_Kp] [get_bd_pins control_axi_block/WR5]
  connect_bd_net -net axi_reg32_0_WR6 [get_bd_pins FOC/Torque_Ki] [get_bd_pins control_axi_block/WR6]
  connect_bd_net -net axi_reg32_0_WR7 [get_bd_pins FOC/RPM_Sp] [get_bd_pins control_axi_block/WR7]
  connect_bd_net -net axi_reg32_0_WR8 [get_bd_pins FOC/RPM_Kp] [get_bd_pins control_axi_block/WR8]
  connect_bd_net -net axi_reg32_0_WR9 [get_bd_pins FOC/RPM_Ki] [get_bd_pins control_axi_block/WR9]
  connect_bd_net -net axi_reg32_0_WR10 [get_bd_pins Angle_Shift_slice/Din] [get_bd_pins control_axi_block/WR10]
  connect_bd_net -net axi_reg32_0_WR11 [get_bd_pins FOC/Vd] [get_bd_pins control_axi_block/WR11]
  connect_bd_net -net axi_reg32_0_WR13 [get_bd_pins Decimate_Samples/decimation] [get_bd_pins control_axi_block/WR13]
  connect_bd_net -net axis_AD7403_0_clkout [get_bd_ports SCLK] [get_bd_pins axis_AD7403_0/clkout]
  connect_bd_net -net axis_encoder_0_angle_data [get_bd_pins Angle_concat/In0] [get_bd_pins FCSMPC/angle] [get_bd_pins axis_encoder_0/angle_data]
  connect_bd_net -net axis_pwm_0_pwm_h [get_bd_pins axis_pwm_0/pwm_h] [get_bd_pins my_2_3MUX_0/B0]
  connect_bd_net -net axis_pwm_0_pwm_l [get_bd_pins axis_pwm_0/pwm_l] [get_bd_pins my_2_3MUX_0/A0]
  connect_bd_net -net control_axi_block_WR14 [get_bd_pins FCSMPC/MPC_Control] [get_bd_pins control_axi_block/WR14]
  connect_bd_net -net control_axi_block_WR15 [get_bd_pins control_axi_block/WR15] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net deadtime_0_GH_OUT [get_bd_pins deadtime_0/GH_OUT] [get_bd_pins my_2_3MUX_0/B1]
  connect_bd_net -net deadtime_0_GL_OUT [get_bd_pins deadtime_0/GL_OUT] [get_bd_pins my_2_3MUX_0/A1]
  connect_bd_net -net fit_timer_0_Interrupt [get_bd_pins fit_timer_0/Interrupt] [get_bd_pins system_ila_0/probe5]
  connect_bd_net -net my_2_3MUX_0_A [get_bd_ports GL] [get_bd_pins my_2_3MUX_0/A] [get_bd_pins system_ila_0/probe6]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets my_2_3MUX_0_A]
  connect_bd_net -net my_2_3MUX_0_B [get_bd_ports GH] [get_bd_pins my_2_3MUX_0/B]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins Angle_RPM_Ib_Ia/s_axis_aresetn] [get_bd_pins Decimate_Samples/s_axis_aresetn] [get_bd_pins FCSMPC/axis_in_aresetn] [get_bd_pins FOC/ap_rst_n] [get_bd_pins I_a_Ib/aresetn] [get_bd_pins axi_datamover_0/m_axi_s2mm_aresetn] [get_bd_pins axi_datamover_0/m_axis_s2mm_cmdsts_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axis_AD7403_0/m_axis_aresetn] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins axis_encoder_0/axis_aresetn] [get_bd_pins axis_monitor_0/axis_aresetn] [get_bd_pins axis_pwm_0/s_axis_aresetn] [get_bd_pins capture_axi_PYNQ/axi_aresetn] [get_bd_pins control_axi_block/s_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/M01_ARESETN] [get_bd_pins ps7_0_axi_periph/M02_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN] [get_bd_pins system_ila_0/resetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins fit_timer_0/Rst] [get_bd_pins proc_sys_reset_0/peripheral_reset]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_pins Angle_RPM_Ib_Ia/s_axis_aclk] [get_bd_pins Debounce_0/CLK] [get_bd_pins Decimate_Samples/s_axis_aclk] [get_bd_pins FCSMPC/ap_clk] [get_bd_pins FOC/ap_clk] [get_bd_pins I_a_Ib/aclk] [get_bd_pins Phase_Test_0/CLK] [get_bd_pins axi_datamover_0/m_axi_s2mm_aclk] [get_bd_pins axi_datamover_0/m_axis_s2mm_cmdsts_awclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axis_AD7403_0/m_axis_aclk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins axis_encoder_0/axis_aclk] [get_bd_pins axis_monitor_0/axis_aclk] [get_bd_pins axis_pwm_0/s_axis_aclk] [get_bd_pins capture_axi_PYNQ/axi_aclk] [get_bd_pins control_axi_block/s_axi_aclk] [get_bd_pins deadtime_0/CLK] [get_bd_pins fit_timer_0/Clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/M01_ACLK] [get_bd_pins ps7_0_axi_periph/M02_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK] [get_bd_pins system_ila_0/clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axis_AD7403_0/din] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins Angle_concat/dout] [get_bd_pins control_axi_block/RR0]
  connect_bd_net -net xlconcat_2_dout [get_bd_ports led] [get_bd_pins xlconcat_2/dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins axis_monitor_0/mux_in] [get_bd_pins xlslice_1/Dout]
  connect_bd_net -net zero_16_dout [get_bd_pins Angle_concat/In1] [get_bd_pins zero_16/dout]

  # Create address segments
  create_bd_addr_seg -range 0x20000000 -offset 0x00000000 [get_bd_addr_spaces axi_datamover_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x00010000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs capture_axi_PYNQ/S_AXI/S_AXI_reg] SEG_AXI_StreamCapture_0_S_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs control_axi_block/S_AXI/S_AXI_reg] SEG_axi_reg32_0_S_AXI_reg


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


