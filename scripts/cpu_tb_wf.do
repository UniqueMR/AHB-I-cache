restart -force
vsim ./model_sim/cpu/work.cpu_tb
add wave /cpu_tb/requested_data
run 1000ns