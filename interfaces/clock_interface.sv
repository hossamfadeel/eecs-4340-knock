interface clock_interface (
  input bit clk
);
  
  clocking cb @(posedge clk);
  endclocking

  modport dut(input clk);
  modport bench(clocking cb);
endinterface
