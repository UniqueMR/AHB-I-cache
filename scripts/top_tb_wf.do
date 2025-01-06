set VSIM vsim
set WS ./modelsim/top
set TB_EXEC top_tb
set WAVEFORM $WS/waveform/top_tb_wf.wlf

set DUT top_inst
set UPSTREAM cpu_sim_inst
set DOWNSTREAM mem_sim_inst

$VSIM -voptargs=+acc -lib $WS $TB_EXEC -wlf $WAVEFORM
add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.hclk
add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.hrstn

add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.haddr
add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.hwrite
add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.hready
add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.hburst
add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.htrans
add wave -position end sim:/$TB_EXEC/$DUT/upstream_intf.hrdata

add wave -position end sim:/$TB_EXEC/$DUT/downstream_intf.haddr
add wave -position end sim:/$TB_EXEC/$DUT/downstream_intf.hwrite
add wave -position end sim:/$TB_EXEC/$DUT/downstream_intf.hready
add wave -position end sim:/$TB_EXEC/$DUT/downstream_intf.hburst
add wave -position end sim:/$TB_EXEC/$DUT/downstream_intf.htrans
add wave -position end sim:/$TB_EXEC/$DUT/downstream_intf.hrdata

add wave -position end sim:/$TB_EXEC/$DUT/local_addr

add wave -position end sim:/$TB_EXEC/$DOWNSTREAM/mem_local_addr
add wave -position end sim:/$TB_EXEC/$DOWNSTREAM/trans_out

run -all
quit