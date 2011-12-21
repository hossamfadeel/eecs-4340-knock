module noc(
	clock_interface.dut clk,
	reset_interface.dut reset,
	node_interface local_node [1:`INTERFACES] 
);

  node_interface c [1:(2*`NOC_SIZE*`NOC_SIZE-2*`NOC_SIZE)] (.clk(clk.clk));

node3 #(.NODE_X(0), .NODE_Y(0)) tl (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(0,0)]),  .node_0(c[`SOUTH(0,0)]), .node_1(c[`EAST(0,0)]));
node3 #(.NODE_X(3), .NODE_Y(0)) tr (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(3,0)]),  .node_0(c[`SOUTH(3,0)]), .node_1(c[`WEST(3,0)]));
node3 #(.NODE_X(0), .NODE_Y(3)) bl (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(0,3)]),  .node_0(c[`NORTH(0,3)]), .node_1(c[`EAST(0,3)]));
node3 #(.NODE_X(3), .NODE_Y(3)) br (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(3,3)]),  .node_0(c[`NORTH(3,3)]), .node_1(c[`WEST(3,3)]));

node4 #(.NODE_X(1), .NODE_Y(0)) t1 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(1,0)]),  .node_0(c[`SOUTH(1,0)]), .node_1(c[`EAST(1,0)]), .node_2(c[`WEST(1,0)]));
node4 #(.NODE_X(2), .NODE_Y(0)) t2 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(2,0)]),  .node_0(c[`SOUTH(2,0)]), .node_1(c[`EAST(2,0)]), .node_2(c[`WEST(2,0)]));

node4 #(.NODE_X(1), .NODE_Y(3)) b1 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(1,3)]),  .node_0(c[`NORTH(1,3)]), .node_1(c[`EAST(1,3)]), .node_2(c[`WEST(1,3)]));
node4 #(.NODE_X(2), .NODE_Y(3)) b2 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(2,3)]),  .node_0(c[`NORTH(2,3)]), .node_1(c[`EAST(2,3)]), .node_2(c[`WEST(2,3)]));

node4 #(.NODE_X(0), .NODE_Y(1)) l1 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(0,1)]),  .node_0(c[`NORTH(0,1)]), .node_1(c[`SOUTH(0,1)]), .node_2(c[`EAST(0,1)]));
node4 #(.NODE_X(0), .NODE_Y(2)) l2 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(0,2)]),  .node_0(c[`NORTH(0,2)]), .node_1(c[`SOUTH(0,2)]), .node_2(c[`EAST(0,2)]));

node4 #(.NODE_X(3), .NODE_Y(1)) r1 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(3,1)]),  .node_0(c[`NORTH(3,1)]), .node_1(c[`SOUTH(3,1)]), .node_2(c[`WEST(3,1)]));
node4 #(.NODE_X(3), .NODE_Y(2)) r2 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(3,2)]),  .node_0(c[`NORTH(3,2)]), .node_1(c[`SOUTH(3,2)]), .node_2(c[`WEST(3,2)]));

node5 #(.NODE_X(1), .NODE_Y(1)) n1 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(1,1)]),  .node_0(c[`NORTH(1,1)]), .node_1(c[`SOUTH(1,1)]), .node_2(c[`EAST(1,1)]), .node_3(c[`WEST(1,1)]));
node5 #(.NODE_X(1), .NODE_Y(2)) n2 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(1,2)]),  .node_0(c[`NORTH(1,2)]), .node_1(c[`SOUTH(1,2)]), .node_2(c[`EAST(1,2)]), .node_3(c[`WEST(1,2)]));
node5 #(.NODE_X(2), .NODE_Y(1)) n3 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(2,1)]),  .node_0(c[`NORTH(2,1)]), .node_1(c[`SOUTH(2,1)]), .node_2(c[`EAST(2,1)]), .node_3(c[`WEST(2,1)]));
node5 #(.NODE_X(2), .NODE_Y(2)) n4 (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(2,2)]),  .node_0(c[`NORTH(2,2)]), .node_1(c[`SOUTH(2,2)]), .node_2(c[`EAST(2,2)]), .node_3(c[`WEST(2,2)]));

endmodule
