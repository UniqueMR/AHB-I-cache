set VSIM vsim 
set INTERFACE_WS ./modelsim/interface
set INTERFACE_TB_EXEC interface_tb
set WAVEFORM $INTERFACE_WS/waveform/interface_tb_wf.wlf

$VSIM -voptargs=+acc -lib $INTERFACE_WS $INTERFACE_TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/interface_tb/ahb_lite_inst.hclk
add wave -position end sim:/interface_tb/ahb_lite_inst.hrstn
add wave -position end sim:/interface_tb/ahb_lite_inst.haddr
add wave -position end sim:/interface_tb/ahb_lite_inst.hwrite
add wave -position end sim:/interface_tb/ahb_lite_inst.hready
add wave -position end sim:/interface_tb/ahb_lite_inst.hwdata
add wave -position end sim:/interface_tb/ahb_lite_inst.hrdata
run -all
quit
