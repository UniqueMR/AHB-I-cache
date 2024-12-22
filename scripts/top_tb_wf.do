set VSIM vsim
set TOP_WS ./modelsim/top
set TOP_TB_EXEC top_tb
set WAVEFORM $TOP_WS/waveform/top_tb_wf.wlf

$VSIM -voptargs=+acc -lib $TOP_WS $TOP_TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/top_tb/top_inst/upstream_intf.hclk
add wave -position end sim:/top_tb/top_inst/upstream_intf.hrstn

add wave -position end sim:/top_tb/top_inst/upstream_intf.haddr
add wave -position end sim:/top_tb/top_inst/upstream_intf.hwrite
add wave -position end sim:/top_tb/top_inst/upstream_intf.hready
add wave -position end sim:/top_tb/top_inst/upstream_intf.hrdata

add wave -position end sim:/top_tb/top_inst/cache_local_addr
add wave -position end sim:/top_tb/top_inst/cache_local_data
run -all
quit