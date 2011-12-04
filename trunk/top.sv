`timescale 1ns/1ns

module top;
  bit clk = 0;
  always #5 clk = ~clk;

  initial $vcdpluson;

  clock_interface clk_if(clk);
  reset_interface rst_if(clk); 

  `ifdef NODE_TYPE3
    `define NODE_COUNT 1
    `define INTERFACES 3
    node_interface local_if [1:`INTERFACES] (.clk(clk));
    node3 n ( .clk(clk_if.dut),
              .reset(rst_if.dut),
              .local_node(local_if[ 1]),
              .node_0(local_if[ 2]),
              .node_1(local_if[ 3])
            );
  `endif
  `ifdef NODE_TYPE4
    `define NODE_COUNT 1
    `define INTERFACES 4
    node_interface local_if [1:`INTERFACES] (.clk(clk));
    node4 n ( .clk(clk_if.dut),
              .reset(rst_if.dut),
              .local_node(local_if[ 1]),
              .node_0(local_if[ 2]),
              .node_1(local_if[ 3]),
              .node_2(local_if[ 4])
            );
  `endif
  `ifdef NODE_TYPE5
    `define NODE_COUNT 1
    `define INTERFACES 5 
    node_interface local_if [1:`INTERFACES] (.clk(clk));
    node5 n ( .clk(clk_if.dut),
              .reset(rst_if.dut),
              .local_node(local_if[ 1]),
              .node_0(local_if[ 2]),
              .node_1(local_if[ 3]),
              .node_2(local_if[ 4]),
              .node_3(local_if[ 5])
            );
  `endif
  `ifdef NOC_MODE
    `define INTERFACES `NOC_SIZE*`NOC_SIZE
    `define NODE_COUNT `INTERFACES 
    node_interface local_if [1:`INTERFACES] (.clk(clk));
    noc n(clk_if.dut, rst_if.dut, local_if);
  `endif

  `ifndef DUT_MODE
    bench b(clk_if.bench, rst_if.bench, local_if);
  `endif
endmodule
