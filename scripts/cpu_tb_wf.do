set VSIM vsim
set CPU_WS ./modelsim/cpu
set CPU_TB_EXEC cpu_tb
set WAVEFORM $CPU_WS/waveform/cpu_tb_wf.wlf 

$VSIM -voptargs=+acc -lib ./modelsim/cpu cpu_tb -wlf $WAVEFORM
add wave -position end sim:/cpu_tb/clk
add wave -position end sim:/cpu_tb/requested_data
add wave -position end sim:/cpu_tb/request_addr
add wave -position end sim:/cpu_tb/hit 
add wave -position end sim:/cpu_tb/read_en
run -all
quit
