DUT = dut/node*.sv dut/noc.sv
INTERFACES = interfaces/*.sv
BENCH = bench/data.sv bench/transaction.sv bench/reset_transaction.sv bench/configuration.sv bench/tracker.sv bench/environment.sv bench/bench.sv 

VCS = vcs -PP -sverilog  

bench_out: top.sv $(INTERFACES) $(DUT) $(BENCH)
	$(VCS) $^ -o $@
	./$@

dut_out: top.sv $(INTERFACES) $(DUT)
	$(VCS) $^ -o $@

.PHONY: clean
clean:
	-rm -rf csrc/ *.daidir/ DVEfiles/
	-rm -f *.log bench_out dut_out *.svf *.key *.vpd
