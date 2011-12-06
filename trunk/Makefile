NOC_MODE ?= 0
NOC_SIZE ?= 4 
NODE_X ?= 0
NODE_Y ?= 0
PARAMS ?= bench/params$(NODE_TYPE).cfg
DPARAMS = \"$(PARAMS)\"

NOC_SIZE_M1 = $(shell echo $(NOC_SIZE)-1 | bc)

GENDUT = dut/converter.sv dw/*.v general/*.sv 
INTERFACES = interfaces/*.sv
BENCH = bench/fifo.sv bench/sim_node.sv bench/data.sv bench/transaction.sv bench/reset_transaction.sv bench/node_transaction.sv bench/configuration.sv bench/tracker.sv bench/environment.sv bench/bench.sv 

VCS = vcs -PP -sverilog  

ifeq ($(NODE_Y), 0)
  ifeq ($(NODE_X), 0)
    NODE_TYPE = 3
  else ifeq ($(NODE_X), $(NOC_SIZE_M1))
    NODE_TYPE = 3
  else
    NODE_TYPE = 4
  endif
else ifeq ($(NODE_Y), $(NOC_SIZE_M1))
  ifeq ($(NODE_X), 0)
    NODE_TYPE = 3
  else ifeq ($(NODE_X), $(NOC_SIZE_M1))
    NODE_TYPE = 3
  else
    NODE_TYPE = 4
  endif
else ifeq ($(NODE_X), 0)
  NODE_TYPE = 4
else ifeq ($(NODE_X), $(NOC_SIZE_M1))
  NODE_TYPE = 4
else
  NODE_TYPE = 5
endif


ifeq ($(NOC_MODE), 1)
  DUT = $(GENDUT) dut/node*.sv dut/noc.sv
  DEFINES = +define+NOC_MODE
else
  DUT = $(GENDUT) dut/node$(NODE_TYPE).sv
  DEFINES = +define+NODE_TYPE$(NODE_TYPE) +define+NODE_X=$(NODE_X) +define+NODE_Y=$(NODE_Y) 
endif

DEFINES += +define+NOC_SIZE=$(NOC_SIZE) +define+PARAMS=$(DPARAMS)



bench_out: defines.sv top.sv $(INTERFACES) $(DUT) $(BENCH)
	$(VCS) $^ $(DEFINES) -o $@
	./$@

dut_out: defines.sv top.sv $(INTERFACES) $(DUT)
	$(VCS) $^ $(DEFINES) +define+DUT_MODE -o $@

.PHONY: clean
clean:
	-rm -rf csrc/ *.daidir/ DVEfiles/
	-rm -f *.log bench_out dut_out *.svf *.key *.vpd
