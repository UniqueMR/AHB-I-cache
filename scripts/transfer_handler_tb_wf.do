set VSIM vsim
set WS ./modelsim/transfer_handler
set TB_EXEC transfer_handler_tb
set WAVEFORM $WS/waveform/transfer_handler_tb_wf.wlf
set DUT transfer_handler_inst

$VSIM -voptargs=+acc -lib $WS $TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/$TB_EXEC/clk
add wave -position end sim:/$TB_EXEC/rstn
add wave -position end sim:/$TB_EXEC/hwrite
add wave -position end sim:/$TB_EXEC/addr
add wave -position end sim:/$TB_EXEC/$DUT/base_addr
add wave -position end sim:/$TB_EXEC/$DUT/offset_addr
add wave -position end sim:/$TB_EXEC/$DUT/next_offset_addr
add wave -position end sim:/$TB_EXEC/read_addr
add wave -position end sim:/$TB_EXEC/ready
add wave -position end sim:/$TB_EXEC/rdata
add wave -position end sim:/$TB_EXEC/trans
add wave -position end sim:/$TB_EXEC/read_data
add wave -position end sim:/$TB_EXEC/burst

run -all
quit