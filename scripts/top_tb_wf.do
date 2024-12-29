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

add wave -position end sim:/top_tb/top_inst/local_addr
add wave -position end sim:/top_tb/top_inst/local_data

add wave -position end sim:/top_tb/top_inst/hit

add wave -position end sim:/top_tb/top_inst/cpu_cache_transfer_handler_inst/hwrite
add wave -position end sim:/top_tb/top_inst/cpu_cache_transfer_handler_inst/hready
add wave -position end sim:/top_tb/top_inst/cpu_cache_transfer_handler_inst/local_addr
add wave -position end sim:/top_tb/top_inst/cpu_cache_transfer_handler_inst/next_addr
add wave -position end sim:/top_tb/top_inst/downstream_intf.hrdata
add wave -position end sim:/top_tb/top_inst/downstream_intf.hready

add wave -position end sim:/top_tb/mem_sim_inst/cache_mem_transfer_handler_inst/hwrite
add wave -position end sim:/top_tb/mem_sim_inst/cache_mem_transfer_handler_inst/hready
add wave -position end sim:/top_tb/mem_sim_inst/cache_mem_transfer_handler_inst/local_addr
add wave -position end sim:/top_tb/mem_sim_inst/cache_mem_transfer_handler_inst/next_addr

add wave -position end sim:/top_tb/mem_sim_inst/mem_local_addr
add wave -position end sim:/top_tb/mem_sim_inst/mem_local_data
add wave -position end sim:/top_tb/mem_sim_inst/driver_obj.mem_read_val
add wave -position end sim:/top_tb/mem_sim_inst/mem_intf.hready


run -all
quit