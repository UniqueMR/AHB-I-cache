set VSIM vsim
set TOP_WS ./modelsim/top
set TOP_TB_EXEC top_tb
set WAVEFORM $TOP_WS/waveform/top_tb_wf.wlf

$VSIM -voptargs=+acc -lib $TOP_WS $TOP_TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/top_tb/clk
add wave -position end sim:/top_tb/rst
run -all
quit