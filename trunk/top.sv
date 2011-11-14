`timescale 1ns/1ns

module top;
  bit clk = 0;
  always #5 clk = ~clk;

  initial $vcdpluson;

  clock_interface clk_if(clk);
  reset_interface rst_if(clk); 

  node_interface local_if [1:16]  (.clk(clk));
  node_interface c [1:24] (.clk(clk));

  node3 n1(.clk(clk_if), .reset(rst_if), .local_node(local_if[1]), .node_0(c[1]), .node_1(c[4]));
  node3 n4(.clk(clk_if), .reset(rst_if), .local_node(local_if[4]), .node_0(c[7]), .node_1(c[3]));
  node3 n13(.clk(clk_if), .reset(rst_if), .local_node(local_if[13]), .node_0(c[22]), .node_1(c[18]));
  node3 n16(.clk(clk_if), .reset(rst_if), .local_node(local_if[16]), .node_0(c[24]), .node_1(c[21]));

  node4 n2(.clk(clk_if), .reset(rst_if), .local_node(local_if[2]), .node_0(c[2]), .node_1(c[5]), .node_2(c[1]));
  node4 n3(.clk(clk_if), .reset(rst_if), .local_node(local_if[3]), .node_0(c[3]), .node_1(c[6]), .node_2(c[2]));
  node4 n5(.clk(clk_if), .reset(rst_if), .local_node(local_if[5]), .node_0(c[8]), .node_1(c[11]), .node_2(c[4]));
  node4 n8(.clk(clk_if), .reset(rst_if), .local_node(local_if[8]), .node_0(c[14]), .node_1(c[10]), .node_2(c[7]));
  node4 n9(.clk(clk_if), .reset(rst_if), .local_node(local_if[9]), .node_0(c[15]), .node_1(c[18]), .node_2(c[11]));
  node4 n12(.clk(clk_if), .reset(rst_if), .local_node(local_if[12]), .node_0(c[21]), .node_1(c[17]), .node_2(c[14]));
  node4 n14(.clk(clk_if), .reset(rst_if), .local_node(local_if[14]), .node_0(c[23]), .node_1(c[22]), .node_2(c[19]));
  node4 n15(.clk(clk_if), .reset(rst_if), .local_node(local_if[15]), .node_0(c[24]), .node_1(c[23]), .node_2(c[20]));

  node5 n6(.clk(clk_if), .reset(rst_if), .local_node(local_if[6]), .node_0(c[9]), .node_1(c[12]), .node_2(c[8]), .node_3(c[5]));
  node5 n7(.clk(clk_if), .reset(rst_if), .local_node(local_if[7]), .node_0(c[10]), .node_1(c[13]), .node_2(c[9]), .node_3(c[6]));
  node5 n10(.clk(clk_if), .reset(rst_if), .local_node(local_if[10]), .node_0(c[16]), .node_1(c[19]), .node_2(c[15]), .node_3(c[12]));
  node5 n11(.clk(clk_if), .reset(rst_if), .local_node(local_if[11]), .node_0(c[17]), .node_1(c[20]), .node_2(c[16]), .node_3(c[13]));

  bench b(clk_if.bench, rst_if.bench, local_if);
endmodule
