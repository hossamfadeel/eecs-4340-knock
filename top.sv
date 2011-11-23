`timescale 1ns/1ns

module top;
  bit clk = 0;
  always #5 clk = ~clk;

  initial $vcdpluson;

  clock_interface clk_if(clk);
  reset_interface rst_if(clk); 

  node_interface local_if [1:16] (.clk(clk));

  noc n(clk_if.dut, rst_if.dut, local_if);
  bench b(clk_if.bench, rst_if.bench, local_if);
endmodule
