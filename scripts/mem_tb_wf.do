set VSIM vsim
set MEM_WS ./modelsim/mem
set MEM_TB_EXEC mem_tb
set WAVEFORM $MEM_WS/waveform/mem_tb_wf.wlf

$VSIM -voptargs=+acc -lib $MEM_WS $MEM_TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/mem_tb/clk
add wave -position end sim:/mem_tb/mem_addr
add wave -position end sim:/mem_tb/mem_data
add wave -position end sim:/mem_tb/mem_ready
add wave -position end sim:/mem_tb/mem_req
run -all
quit