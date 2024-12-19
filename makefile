VLIB=vlib
VLOG=vlog
VSIM=vsim

MODEL_SIM_WS=./modelsim/
TOP_WS=$(MODEL_SIM_WS)top
CPU_WS=$(MODEL_SIM_WS)cpu
MEM_WS=$(MODEL_SIM_WS)mem
INTERFACE_WS=$(MODEL_SIM_WS)interface

MODEL_SIM_FLAGS=-c -do "run -all; quit;"

TOP_TB_EXEC=top_tb

UTILS_SRC = ./src/utils/addr_parser.sv ./src/utils/line_segment_selector.sv ./src/utils/cache_state_handler.sv

TOP_SRC=./src/top.sv $(UTILS_SRC)
CPU_SIM_SRC=./src/tb/cpu/cpu_sim.sv
MEM_SIM_SRC=./src/tb/mem/mem_sim.sv
INTERFACE_SRC=./src/interface/ahb_lite.sv

TOP_TB_SRC=$(TOP_SRC) $(MEM_SIM_SRC) $(CPU_SIM_SRC) ./src/tb/top_tb.sv
CPU_TB_SRC=$(CPU_SIM_SRC) ./src/tb/cpu/cpu_tb.sv
MEM_TB_SRC=$(MEM_SIM_SRC) ./src/tb/mem/mem_tb.sv
INTERFACE_TB_SRC=$(INTERFACE_SRC) ./src/tb/interface/interface_tb_master.sv ./src/tb/interface/interface_tb_slave.sv ./src/tb/interface/interface_tb.sv

DO_CPU=./scripts/cpu_tb_wf.do
DO_MEM=./scripts/mem_tb_wf.do
DO_TOP=./scripts/top_tb_wf.do
DO_INTERFACE=./scripts/interface_tb_wf.do

CPU_WF=$(CPU_WS)/waveform/cpu_tb_wf.wlf
MEM_WF=$(MEM_WS)/waveform/mem_tb_wf.wlf
TOP_WF=$(TOP_WS)/waveform/top_tb_wf.wlf
INTERFACE_WF=$(INTERFACE_WS)/waveform/interface_tb_wf.wlf

CLEAN_FILES=./src/*.swp ./src/tb/*.swp

WS=
TB_SRC=
DO=
WF=

ifeq ($(MAKECMDGOALS), top)
	WS = $(TOP_WS)
	TB_SRC = $(TOP_TB_SRC)
	DO = $(DO_TOP)
	WF = $(TOP_WF) 

else ifeq ($(MAKECMDGOALS), cpu)
	WS = $(CPU_WS)
	TB_SRC = $(CPU_TB_SRC)
	DO = $(DO_CPU)
	WF = $(CPU_WF)

else ifeq ($(MAKECMDGOALS), mem)
	WS = $(MEM_WS)
	TB_SRC = $(MEM_TB_SRC)
	DO = $(DO_MEM)
	WF = $(MEM_WF)

else ifeq ($(MAKECMDGOALS), interface)
	WS = $(INTERFACE_WS)
	TB_SRC = $(INTERFACE_TB_SRC)
	DO = $(DO_INTERFACE)
	WF = $(INTERFACE_WF)

else
.DEFAULT:
	@echo "Error: Unknown target"
	exit 1

endif

compile: 
	mkdir -p $(WS) $(WS)/waveform
	$(VLOG) -work $(WS) $(TB_SRC)

sim: compile
	$(VSIM) -do $(DO) -c
	$(VSIM) -view $(WF)

clean:
	rm -rf $(CLEAN_FILES)