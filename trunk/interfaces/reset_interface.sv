interface reset_interface (
  input bit clk
);
  
  logic reset;

  clocking cb @(posedge clk);
    output reset;
  endclocking

  modport dut(input reset);
  modport bench(clocking cb);
endinterface
