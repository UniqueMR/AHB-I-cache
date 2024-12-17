VLIB=vlib
VLOG=vlog
VSIM=vsim

MODEL_SIM_WS=./modelsim/
TOP_WS=$(MODEL_SIM_WS)top
CPU_WS=$(MODEL_SIM_WS)cpu
MEM_WS=$(MODEL_SIM_WS)mem

MODEL_SIM_FLAGS=-c -do "run -all; quit;"

TOP_TB_EXEC=top_tb

TOP_SRC=./src/top.sv ./src/utils/addr_parser.sv ./src/utils/line_segment_selector.sv
CPU_SIM_SRC=./src/tb/cpu/cpu_sim.sv
MEM_SIM_SRC=./src/tb/mem/mem_sim.sv

TOP_TB_SRC=$(TOP_SRC) $(MEM_SIM_SRC) $(CPU_SIM_SRC) ./src/tb/top_tb.sv
CPU_TB_SRC=$(CPU_SIM_SRC) ./src/tb/cpu/cpu_tb.sv
MEM_TB_SRC=$(MEM_SIM_SRC) ./src/tb/mem/mem_tb.sv

DO_CPU=./scripts/cpu_tb_wf.do
DO_MEM=./scripts/mem_tb_wf.do
DO_TOP=./scripts/top_tb_wf.do

CPU_WF=$(CPU_WS)/waveform/cpu_tb_wf.wlf
MEM_WF=$(MEM_WS)/waveform/mem_tb_wf.wlf
TOP_WF=$(TOP_WS)/waveform/top_tb_wf.wlf

CLEAN_FILES=./src/*.swp ./src/tb/*.swp

compile_top:
	mkdir -p $(TOP_WS)
	mkdir -p $(TOP_WS)/waveform
	$(VLOG) -work $(TOP_WS) $(TOP_TB_SRC) 

sim_top: compile_top
	$(VSIM) -do $(DO_TOP) -c
	$(VSIM) -view $(TOP_WF)

compile_cpu:
	mkdir -p $(CPU_WS)
	mkdir -p $(CPU_WS)/waveform
	$(VLOG) -work $(CPU_WS) $(CPU_TB_SRC) 

sim_cpu: compile_cpu
	$(VSIM) -do $(DO_CPU) -c
	$(VSIM) -view $(CPU_WF)

compile_mem:
	mkdir -p $(MEM_WS)
	mkdir -p $(MEM_WS)/waveform
	$(VLOG) -work $(MEM_WS) $(MEM_TB_SRC)

sim_mem: compile_mem
	$(VSIM) -do $(DO_MEM) -c
	$(VSIM) -view $(MEM_WF)
	
clean:
	rm -rf $(CLEAN_FILES)