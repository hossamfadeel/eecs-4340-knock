module top;
  reg [3:0] packet_addr_y_i;
  reg [3:0] packet_addr_x_i;
  reg [3:0] local_addr_y_i;
  reg [3:0] local_addr_x_i;
  reg packet_valid_i;
  
  logic north_req;
  logic east_req;
  logic south_req;
  logic west_req;
  logic local_req;

  bit clk = 0;
  always #5 clk = ~clk;

  dccl d (packet_addr_y_i, packet_addr_x_i, local_addr_y_i, local_addr_x_i, packet_valid_i,
          north_req, east_req, south_req, west_req, local_req);

  dccl_bench b (clk, packet_addr_y_i, packet_addr_x_i, local_addr_y_i, local_addr_x_i, packet_valid_i,
          north_req, east_req, south_req, west_req, local_req);
endmodule
