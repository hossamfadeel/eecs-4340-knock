module fifo (

);
parameter width = 16;
parameter depth = 5;
parameter ae_level = 1;
parameter af_level = 1;
parameter err_mode = 0;
parameter rst_mode = 1;

input clk;
input rst;
input push_req;
input pop_req;
input diag = 1;
input [width-1:0] data_in;
output empty;
output almost_empty;
output half_full;
output almost_full;
output full;
output error;
output [width-1:0] data_out;

DW_fifo_s1_sf #(width, depth, ae_level, af_level, err_mode, rst_mode)
	buffer (.clk(clk), .rst_n(rst), .push_req_n(push_req), .diag_n(diag),
	.data_in(data_in), .empty(empty), .almost_empty(almost_empty),
	.half_full(half_full), .almost_full(almost_full), .full(full),
	.error(error), .data_out(data_out) );


endmodule
