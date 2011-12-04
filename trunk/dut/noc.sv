module noc(
	clock_interface.dut clk,
	reset_interface.dut reset,
	node_interface.dut local_node [1:`INTERFACES] 
);

  node_interface c [1:24] (.clk(clk.clk));

  generate
    for(genvar x = 0; x < `NOC_SIZE; x = x + 1) begin
      for(genvar y = 0; y < `NOC_SIZE; y = y + 1) begin
        if(`TOP(y) && `LEFT(x)) begin
          node3 tl (.clk(clk), .reset(reset), .local_node(local_node[x + y*`NOC_SIZE + 1]),  .node_0(c[1]), .node_1(c[`NOC_SIZE]));
        end else if (`TOP(y) && `RIGHT(x)) begin
          node3 tr (.clk(clk), .reset(reset), .local_node(local_node[x + y*`NOC_SIZE + 1]),  .node_0(c[`NOC_SIZE*2 - 1]), .node_1(c[`NOC_SIZE - 1]));
        end else if (`BOTTOM(y) && `LEFT(x)) begin
          node3 bl (.clk(clk), .reset(reset), .local_node(local_node[x + y*`NOC_SIZE + 1]),  .node_0(c[x + y*`NOC_SIZE + 1 + (`NOC_SIZE-1)*y]), .node_1(c[(x + y*`NOC_SIZE + 1) + (`NOC_SIZE-1)*(y-1) - 1]));
        end else if (`BOTTOM(y) && `RIGHT(x)) begin
          node3 bl (.clk(clk), .reset(reset), .local_node(local_node[x + y*`NOC_SIZE + 1]),  .node_0(c[`INTERFACES]), .node_1(c[(x + y*`NOC_SIZE + 1) + (`NOC_SIZE-1)*(y-1) - 1]));
        end else if (`TOP(y)) begin
          node4 t (.clk(clk), .reset(reset), .local_node(local_node[x+y*`NOC_SIZE+1]),  .node_0(c[x+y*`NOC_SIZE+1]), .node_1(c[x+y*`NOC_SIZE+1+`NOC_SIZE-1]), .node_2(c[x+y*`NOC_SIZE+1-1]));
        end else if (`BOTTOM(y)) begin
          node4 b (.clk(clk), .reset(reset), .local_node(local_node[x+y*`NOC_SIZE+1]),  .node_0(c[x + y*`NOC_SIZE + 1 + (`NOC_SIZE-1)*y]), .node_1(c[x+y*`NOC_SIZE+1+(`NOC_SIZE-1)*y-1]), .node_2(c[(x + y*`NOC_SIZE + 1) + (`NOC_SIZE-1)*(y-1) - 1]));
        end else if (`LEFT(x)) begin
          node4 l (.clk(clk), .reset(reset), .local_node(local_node[x+y*`NOC_SIZE+1]),  .node_0(c[x+y*`NOC_SIZE+1+(`NOC_SIZE-1)*y]), .node_1(c[x+y*`NOC_SIZE+1+(`NOC_SIZE-1)*(y+1)]), .node_2(c[(x + y*`NOC_SIZE + 1) + (`NOC_SIZE-1)*(y-1) - 1]));
        end else if (`RIGHT(x)) begin
          node4 r (.clk(clk), .reset(reset), .local_node(local_node[x+y*`NOC_SIZE+1]),  .node_0(c[x+y*`NOC_SIZE+1+(`NOC_SIZE-1)*(y+1)]), .node_1(c[x+y*`NOC_SIZE+1+(`NOC_SIZE-1)*y-1]), .node_2(c[(x + y*`NOC_SIZE + 1) + (`NOC_SIZE-1)*(y-1) - 1]));
        end else begin
          node5 n (.clk(clk), .reset(reset), .local_node(local_node[x+y*`NOC_SIZE+1]),  .node_0(c[x+y*`NOC_SIZE+1 + y*(`NOC_SIZE-1)]), .node_1(c[x+y*`NOC_SIZE+1 + (y+1)*(`NOC_SIZE-1)]), .node_2(c[x+y*`NOC_SIZE+1+y*(`NOC_SIZE-1)-1]), .node_3(c[x+y*`NOC_SIZE+1+(y-1)*(`NOC_SIZE-1)-1]));
        end
      end
    end
  endgenerate
/*
  node3 n1  (.clk(clk), .reset(reset), .local_node(local_node[ 1]),  .node_0(c[ 1]), .node_1(c[ 4]));
  node3 n4  (.clk(clk), .reset(reset), .local_node(local_node[ 4]),  .node_0(c[ 7]), .node_1(c[ 3]));
  node3 n13 (.clk(clk), .reset(reset), .local_node(local_node[13]),  .node_0(c[22]), .node_1(c[18]));
  node3 n16 (.clk(clk), .reset(reset), .local_node(local_node[16]),  .node_0(c[24]), .node_1(c[21]));

  node4 n2  (.clk(clk), .reset(reset), .local_node(local_node[ 2]),  .node_0(c[ 2]), .node_1(c[ 5]), .node_2(c[ 1]));
  node4 n3  (.clk(clk), .reset(reset), .local_node(local_node[ 3]),  .node_0(c[ 3]), .node_1(c[ 6]), .node_2(c[ 2]));
  node4 n5  (.clk(clk), .reset(reset), .local_node(local_node[ 5]),  .node_0(c[ 8]), .node_1(c[11]), .node_2(c[ 4]));
  node4 n8  (.clk(clk), .reset(reset), .local_node(local_node[ 8]),  .node_0(c[14]), .node_1(c[10]), .node_2(c[ 7]));
  node4 n9  (.clk(clk), .reset(reset), .local_node(local_node[ 9]),  .node_0(c[15]), .node_1(c[18]), .node_2(c[11]));
  node4 n12 (.clk(clk), .reset(reset), .local_node(local_node[12]),  .node_0(c[21]), .node_1(c[17]), .node_2(c[14]));
  node4 n14 (.clk(clk), .reset(reset), .local_node(local_node[14]),  .node_0(c[23]), .node_1(c[22]), .node_2(c[19]));
  node4 n15 (.clk(clk), .reset(reset), .local_node(local_node[15]),  .node_0(c[24]), .node_1(c[23]), .node_2(c[20]));

  node5 n6  (.clk(clk), .reset(reset), .local_node(local_node[ 6]),  .node_0(c[ 9]), .node_1(c[12]), .node_2(c[ 8]), .node_3(c[ 5]));
  node5 n7  (.clk(clk), .reset(reset), .local_node(local_node[ 7]),  .node_0(c[10]), .node_1(c[13]), .node_2(c[ 9]), .node_3(c[ 6]));
  node5 n10 (.clk(clk), .reset(reset), .local_node(local_node[10]),  .node_0(c[16]), .node_1(c[19]), .node_2(c[15]), .node_3(c[12]));
  node5 n11 (.clk(clk), .reset(reset), .local_node(local_node[11]),  .node_0(c[17]), .node_1(c[20]), .node_2(c[16]), .node_3(c[13]));
*/
endmodule
