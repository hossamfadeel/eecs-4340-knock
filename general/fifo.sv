module fifo #(
  parameter WIDTH = 16,
  parameter depth = 5,
  parameter ae_level = 1,
  parameter af_level = 1,
  parameter err_mode = 1,
  parameter rst_mode = 1
)  (
  input clk,
  input rst,
  input push_req,
  input pop_req,
  input [WIDTH-1:0] data_in,
  output full,
  output data_valid,
  output [WIDTH-1:0] data_out
);

wire empty;
wire almost_empty;
wire half_full;
wire almost_full;
wire error;

DW_fifo_s1_sf #(WIDTH, depth, ae_level, af_level, err_mode, rst_mode)
	buffer (.clk(clk), .rst_n(!rst), .pop_req_n(!pop_req), .push_req_n(!push_req), .diag_n(1'b1),
	.data_in(data_in), .empty(empty), .almost_empty(almost_empty),
	.half_full(half_full), .almost_full(almost_full), .full(full),
	.error(error), .data_out(), .peek_out(data_out) );

  assign data_valid = !empty;
endmodule
