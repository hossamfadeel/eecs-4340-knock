NOC_MODE ?= 0
NOC_SIZE ?= 4 
NODE_X ?= 0
NODE_Y ?= 0

NOC_SIZE_M1 = $(shell echo $(NOC_SIZE)-1 | bc)

GENDUT = dut/converter_out.sv dut/address_counter.sv dw/*.v general/dccl.sv general/fifo_kev.sv general/flipflop.sv general/register.sv
INTERFACES = interfaces/*.sv
BENCH = bench/fifo.sv bench/sim_node.sv bench/data.sv bench/transaction.sv bench/reset_transaction.sv bench/node_transaction.sv bench/configuration.sv bench/tracker.sv bench/environment.sv bench/bench.sv 

VCS = vcs -PP -sverilog  

ifeq ($(NODE_Y), 0)
  ifeq ($(NODE_X), 0)
    NODE_TYPE = 3
    NODEDUT := general/mux2_1.sv dut/controller3_nw.sv
  else ifeq ($(NODE_X), $(NOC_SIZE_M1))
    NODE_TYPE = 3
    NODEDUT := general/mux2_1.sv dut/controller3_ne.sv
  else
    NODE_TYPE = 4
    NODEDUT := general/mux2_1.sv general/mux3_1.sv dut/controller4_edge_n.sv
  endif
else ifeq ($(NODE_Y), $(NOC_SIZE_M1))
  ifeq ($(NODE_X), 0)
    NODE_TYPE = 3
    NODEDUT := general/mux2_1.sv dut/controller3_sw.sv
  else ifeq ($(NODE_X), $(NOC_SIZE_M1))
    NODE_TYPE = 3
    NODEDUT := general/mux2_1.sv dut/controller3_se.sv
  else
    NODE_TYPE = 4
    NODEDUT := general/mux2_1.sv general/mux3_1.sv dut/controller4_edge_s.sv
  endif
else ifeq ($(NODE_X), 0)
  NODE_TYPE = 4
  NODEDUT := general/mux2_1.sv general/mux3_1.sv dut/arbiter2.sv dut/controller4_edge_w.sv
else ifeq ($(NODE_X), $(NOC_SIZE_M1))
  NODE_TYPE = 4
  NODEDUT := general/mux2_1.sv general/mux3_1.sv dut/arbiter2.sv dut/controller4_edge_e.sv
else
  NODE_TYPE = 5
  NODEDUT := general/mux*.sv dut/controller5.sv
endif

ifeq ($(NODE_TYPE), 3)
	NODEDUT := dut/arbiter2.sv $(NODEDUT) 
else ifeq ($(NODE_TYPE), 4)
	NODEDUT := dut/arbiter3.sv $(NODEDUT) 
else ifeq ($(NODE_TYPE), 5)
	NODEDUT := dut/arbiter2.sv dut/arbiter4.sv $(NODEDUT) 
endif


ifeq ($(NOC_MODE), 1)
  PARAMS ?= bench/params0.cfg
  DPARAMS = \"$(PARAMS)\"
  NOCDUT = $(GENDUT) dut/converter_in.sv dut/arbiter*.sv dut/controller*.sv dut/node*.sv dut/noc.sv
  DEFINES = +define+NOC_MODE
  ifeq ($(NOC_SIZE), 2)
	DUT = $(NOCDUT) general/mux2_1.sv
  else ifeq ($(NOC_SIZE), 3)
	DUT = $(NOCDUT) general/mux2_1.sv general/mux3_1.sv
  else
	DUT = $(NOCDUT) general/mux*.sv
  endif
else
  PARAMS ?= bench/params$(NODE_TYPE).cfg
  DPARAMS = \"$(PARAMS)\"
  DUT = $(GENDUT) $(NODEDUT) dut/node$(NODE_TYPE).sv
  DEFINES = +define+NODE_TYPE$(NODE_TYPE) +define+NODE_X=$(NODE_X) +define+NODE_Y=$(NODE_Y) 
endif

DEFINES += +define+NOC_SIZE=$(NOC_SIZE) +define+PARAMS=$(DPARAMS)

bench_out: defines.sv top.sv $(INTERFACES) $(DUT) $(BENCH)
	$(VCS) $^ $(DEFINES) -o $@
	./$@ > results.txt

dut_out: defines.sv top.sv $(INTERFACES) $(DUT)
	$(VCS) $^ $(DEFINES) +define+DUT_MODE -o $@


dccl_out: defines.sv dw/DW01_cmp2.v general/dccl.sv other/dccl_bench.sv other/dccl_top.sv
	$(VCS) $^ $(DEFINES) -o $@
	./$@

node3: 
	make clean
	make > results.txt
	echo "***NW***"
	tail -n 13 results.txt
	make clean
	make NODE_X=3 > results.txt
	echo "***NE***"
	tail -n 13 results.txt
	make clean
	make NODE_Y=3 > results.txt
	echo "***SW***"
	tail -n 13 results.txt
	make clean
	make NODE_X=3 NODE_Y=3 > results.txt
	echo "***SE***"
	tail -n 13 results.txt
	rm results.txt

.PHONY: clean
clean:
	-rm -rf csrc/ *.daidir/ DVEfiles/
	-rm -f *.log bench_out dut_out dccl_out *.svf *.key *.vpd results.txt
