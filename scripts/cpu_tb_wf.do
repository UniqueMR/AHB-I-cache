set VSIM vsim
set CPU_WS ./modelsim/cpu
set CPU_TB_EXEC cpu_tb
set WAVEFORM $CPU_WS/waveform/cpu_tb_wf.wlf 

$VSIM -voptargs=+acc -lib ./modelsim/cpu cpu_tb -wlf $WAVEFORM
add wave -position end sim:/cpu_tb/cpu_intf_inst.hclk
add wave -position end sim:/cpu_tb/cpu_intf_inst.hrstn
add wave -position end sim:/cpu_tb/cpu_intf_inst.haddr
add wave -position end sim:/cpu_tb/cpu_intf_inst.hwrite
run -all
quit
