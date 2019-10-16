transcript on
if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}

vlib vhdl_libs/altera
vmap altera ./vhdl_libs/altera
vcom -93 -work altera {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_syn_attributes.vhd}
vcom -93 -work altera {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_standard_functions.vhd}
vcom -93 -work altera {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/alt_dspbuilder_package.vhd}
vcom -93 -work altera {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_europa_support_lib.vhd}
vcom -93 -work altera {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_primitives_components.vhd}
vcom -93 -work altera {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_primitives.vhd}

vlib vhdl_libs/lpm
vmap lpm ./vhdl_libs/lpm
vcom -93 -work lpm {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/220pack.vhd}
vcom -93 -work lpm {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/220model.vhd}

vlib vhdl_libs/sgate
vmap sgate ./vhdl_libs/sgate
vcom -93 -work sgate {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/sgate_pack.vhd}
vcom -93 -work sgate {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/sgate.vhd}

vlib vhdl_libs/altera_mf
vmap altera_mf ./vhdl_libs/altera_mf
vcom -93 -work altera_mf {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_mf_components.vhd}
vcom -93 -work altera_mf {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_mf.vhd}

vlib vhdl_libs/altera_lnsim
vmap altera_lnsim ./vhdl_libs/altera_lnsim
vlog -sv -work altera_lnsim {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv}
vcom -93 -work altera_lnsim {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/altera_lnsim_components.vhd}

vlib vhdl_libs/cyclone10lp
vmap cyclone10lp ./vhdl_libs/cyclone10lp
vcom -93 -work cyclone10lp {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/cyclone10lp_atoms.vhd}
vcom -93 -work cyclone10lp {c:/intelfpga_lite/18.1/quartus/eda/sim_lib/cyclone10lp_components.vhd}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Lucas-PC/Desktop/DUC_vhdl/timing_controller.vhd}

vcom -93 -work work {C:/Users/Lucas-PC/Desktop/DUC_vhdl/simulation/modelsim/testbench.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclone10lp -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
