interface clock_interface (
  input bit clk
);
  
	`ifndef DUT_MODE
    clocking cb @(posedge clk);
    endclocking
  `endif

  modport dut(input clk);

	`ifndef DUT_MODE
    modport bench(clocking cb);
	`endif
endinterface
