set VSIM vsim
set WS ./modelsim/transfer_handler
set TB_EXEC transfer_handler_tb
set WAVEFORM $WS/waveform/transfer_handler_tb_wf.wlf

$VSIM -voptargs=+acc -lib $WS $TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/$TB_EXEC/clk
add wave -position end sim:/$TB_EXEC/rstn
add wave -position end sim:/$TB_EXEC/hwrite
add wave -position end sim:/$TB_EXEC/addr
add wave -position end sim:/$TB_EXEC/rdata
add wave -position end sim:/$TB_EXEC/trans
add wave -position end sim:/$TB_EXEC/read_addr
add wave -position end sim:/$TB_EXEC/read_data
add wave -position end sim:/$TB_EXEC/burst
add wave -position end sim:/$TB_EXEC/ready

run -all
quit