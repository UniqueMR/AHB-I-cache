VLIB=vlib
VLOG=vlog
VSIM=vsim
MODEL_SIM_WS=./model_sim/top
MODEL_SIM_FLAGS=-c -do "run -all; quit;"
TOP_TB_EXEC=top_tb
TOP_TB_SRC=./src/top.sv ./src/tb/top_tb.sv

compile_top:
	mkdir -p $(MODEL_SIM_WS)
	$(VLIB) $(MODEL_SIM_WS)
	$(VLOG) -work $(MODEL_SIM_WS) $(TOP_TB_SRC) 

sim_top: compile_top
	$(VSIM) -work $(MODEL_SIM_WS) $(TOP_TB_EXEC) $(MODEL_SIM_FLAGS)
