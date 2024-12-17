set VSIM vsim
set TOP_WS ./modelsim/top
set TOP_TB_EXEC top_tb
set WAVEFORM $TOP_WS/waveform/top_tb_wf.wlf

$VSIM -voptargs=+acc -lib $TOP_WS $TOP_TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/top_tb/clk
add wave -position end sim:/top_tb/rst
add wave -position end sim:/top_tb/read_en
add wave -position end sim:/top_tb/hit
add wave -position end sim:/top_tb/mem_ready
add wave -position end sim:/top_tb/mem_req
add wave -position end sim:/top_tb/addr
add wave -position end sim:/top_tb/data_out
add wave -position end sim:/top_tb/mem_addr
add wave -position end sim:/top_tb/mem_data_in
run -all
quit