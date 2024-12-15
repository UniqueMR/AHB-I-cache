restart -force
vsim work.cpu_tb
view wave
add wave /cpu_tb/requested_data
run 1000ns