NODE_TYPE ?= 0
NOC_SIZE ?= 4 
NODE_X ?= 0
NODE_Y ?= 0
PARAMS ?= bench/params$(NODE_TYPE).cfg
DPARAMS = \"$(PARAMS)\"

ifeq ($(NODE_TYPE), 0)
	DUT = dut/node*.sv dut/noc.sv
else
	DUT = dut/node$(NODE_TYPE).sv
endif
INTERFACES = interfaces/*.sv
BENCH = bench/data.sv bench/transaction.sv bench/reset_transaction.sv bench/configuration.sv bench/tracker.sv bench/environment.sv bench/bench.sv 

VCS = vcs -PP -sverilog  
DEFINES = +define+NODE_TYPE$(NODE_TYPE) +define+NOC_SIZE=$(NOC_SIZE) +define+NODE_X=$(NODE_X) +define+NODE_Y=$(NODE_Y) +define+PARAMS=$(DPARAMS) 

bench_out: top.sv $(INTERFACES) $(DUT) $(BENCH)
	$(VCS) $^ $(DEFINES) -o $@
	./$@

dut_out: top.sv $(INTERFACES) $(DUT)
	$(VCS) $^ $(DEFINES) +define+DUT_MODE -o $@

.PHONY: clean
clean:
	-rm -rf csrc/ *.daidir/ DVEfiles/
	-rm -f *.log bench_out dut_out *.svf *.key *.vpd
