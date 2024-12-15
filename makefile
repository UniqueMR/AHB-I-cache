VLIB=vlib
VLOG=vlog
VSIM=vsim

MODEL_SIM_WS=./model_sim/
TOP_WS=$(MODEL_SIM_WS)top
CPU_WS=$(MODEL_SIM_WS)cpu

MODEL_SIM_FLAGS=-c -do "run -all; quit;" -wlf cpu_tb_wf.wlf $(CPU_WS)/work.cpu_tb

TOP_TB_EXEC=top_tb
CPU_TB_EXEC=cpu_tb

TOP_SRC=./src/top.sv ./src/utils/addr_parser.sv ./src/utils/line_segment_selector.sv
CPU_SIM_SRC=./src/tb/cpu/cpu_sim.sv
MEM_SIM_SRC=./src/tb/mem/mem_sim.sv

TOP_TB_SRC=$(TOP_SRC) $(MEM_SIM_SRC) $(CPU_SIM_SRC) ./src/tb/top_tb.sv
CPU_TB_SRC=$(CPU_SIM_SRC) ./src/tb/cpu/cpu_tb.sv

CLEAN_FILES=./src/*.swp ./src/tb/*.swp

compile_top:
	mkdir -p $(TOP_WS)
	$(VLIB) $(TOP_WS)
	$(VLOG) -work $(TOP_WS) $(TOP_TB_SRC) 

sim_top: compile_top
	$(VSIM) -work $(TOP_WS) $(TOP_TB_EXEC) $(MODEL_SIM_FLAGS)

compile_cpu:
	mkdir -p $(CPU_WS)
	$(VLIB) $(CPU_WS)
	$(VLOG) -work $(CPU_WS) $(CPU_TB_SRC) 

sim_cpu: compile_cpu
	$(VSIM) -work $(CPU_WS) $(CPU_TB_EXEC) $(MODEL_SIM_FLAGS)

wf_cpu: sim_cpu
	$(VSIM) -do ./scripts/cpu_tb_wf.do	

clean:
	rm -rf $(CLEAN_FILES)