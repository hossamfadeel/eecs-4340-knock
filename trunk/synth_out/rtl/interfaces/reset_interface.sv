interface reset_interface (
  input bit clk
);
  
  logic reset;
	`ifndef DUT_MODE
		clocking cb @(posedge clk);
		  output reset;
		endclocking
	`endif

  modport dut(input reset);
		`ifndef DUT_MODE	
		  modport bench(clocking cb);
		`endif
endinterface
