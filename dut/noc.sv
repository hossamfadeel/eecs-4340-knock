module noc(
	clock_interface.dut clk,
	reset_interface.dut reset,
	node_interface.dut local_node [1:`INTERFACES] 
);

  node_interface c [1:(2*`NOC_SIZE*`NOC_SIZE-2*`NOC_SIZE)] (.clk(clk.clk));

  generate
    for(genvar x = 0; x < `NOC_SIZE; x = x+1) begin
      for(genvar y = 0; y < `NOC_SIZE; y = y+1) begin
        if(`TOP(y) && `LEFT(x)) begin
          node3 tl (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`EAST(x,y)]), .node_1(c[`SOUTH(x,y)]));
        end else if (`TOP(y) && `RIGHT(x)) begin
          node3 tr (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`SOUTH(x,y)]), .node_1(c[`WEST(x,y)]));
        end else if (`BOTTOM(y) && `LEFT(x)) begin
          node3 bl (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`EAST(x,y)]), .node_1(c[`NORTH(x,y)]));
        end else if (`BOTTOM(y) && `RIGHT(x)) begin
          node3 bl (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`WEST(x,y)]), .node_1(c[`NORTH(x,y)]));
        end else if (`TOP(y)) begin
          node4 t (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`EAST(x,y)]), .node_1(c[`SOUTH(x,y)]), .node_2(c[`WEST(x,y)]));
        end else if (`BOTTOM(y)) begin
          node4 b (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`EAST(x,y)]), .node_1(c[`WEST(x,y)]), .node_2(c[`NORTH(x,y)]));
        end else if (`LEFT(x)) begin
          node4 l (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`EAST(x,y)]), .node_1(c[`SOUTH(x,y)]), .node_2(c[`NORTH(x,y)]));
        end else if (`RIGHT(x)) begin
          node4 r (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`SOUTH(x,y)]), .node_1(c[`WEST(x,y)]), .node_2(c[`NORTH(x,y)]));
        end else begin
          node5 n (.clk(clk), .reset(reset), .local_node(local_node[`INDEX(x,y)]),  .node_0(c[`EAST(x,y)]), .node_1(c[`SOUTH(x,y)]), .node_2(c[`WEST(x,y)]), .node_3(c[`NORTH(x,y)]));
        end
      end
    end
  endgenerate
endmodule
