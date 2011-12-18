module fifo_kev #(
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
  output [WIDTH-1:0] data_out,
	output [WIDTH-1:0] next_data_out,
	output next_data_valid
/*
	output test_head_push,
	output test_fifo_push,
	output test_head_wrdata,
	output fifo_empty,
	output head_empty */
);

wire empty;
wire almost_empty;
wire half_full;
wire almost_full;
wire error;
wire fifo_data_out;
wire head_empty;
wire fifo_empty;

logic head_push;
logic fifo_push;
logic [WIDTH-1:0] head_wrdata;

//assign test_head_push = head_push;
//assign test_fifo_push = fifo_push;
//assign test_head_wrdata = head_wrdata;

always_comb begin
//	head_push = (push_req & head_empty) || (push_req & pop_req) || (pop_req & !fifo_empty);	
	fifo_push = (!pop_req & push_req & (!head_empty & !full)) | (pop_req & push_req & !fifo_empty);
	head_wrdata = ((push_req & head_empty)|| (!head_empty & push_req & pop_req & fifo_empty))? data_in : next_data_out;
	
	if(head_empty) begin
		if(push_req) begin
			head_push = 1'b1;
		end
		else begin
			head_push = 1'b0;
		end
	end
	else begin //head_not empty
		if(pop_req) begin
			if(!fifo_empty) begin
				head_push = 1'b1;
			end
			else begin
				if (push_req) begin
					head_push = 1'b1;
				end
				else begin
					head_push = 1'b0;
				end
			end
		end
		else begin
			head_push = 1'b0;
		end
	end
end

DW_fifo_s1_sf #(WIDTH, 2, ae_level, af_level, err_mode, rst_mode)
	buffer_head (.clk(clk), .rst_n(!rst), .pop_req_n(!pop_req), .push_req_n(!head_push), .diag_n(1'b1),
	.data_in(head_wrdata), .empty(head_empty), .almost_empty(),
	.half_full(), .almost_full(), .full(),
	.error(error), .data_out(), .peek_out(data_out) );

DW_fifo_s1_sf #(WIDTH, (depth-1), ae_level, af_level, err_mode, rst_mode)
	buffer (.clk(clk), .rst_n(!rst), .pop_req_n(!pop_req), .push_req_n(!fifo_push), .diag_n(1'b1),
	.data_in(data_in), .empty(fifo_empty), .almost_empty(almost_empty),
	.half_full(half_full), .almost_full(almost_full), .full(full),
	.error(error), .data_out(), .peek_out(next_data_out) );

  assign data_valid = !head_empty;
	assign next_data_valid = !fifo_empty;
endmodule
