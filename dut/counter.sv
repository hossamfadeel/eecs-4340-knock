module counter#(parameter ADD_WIDTH = 5)
(
	input clk,
	input reset,
	input [ADD_WIDTH-1:0] flip_length,
	input receiving_data,
	output count_done_o;
);


wire [ADD_WIDTH-1:0] next_count;
wire [ADD_WIDTH-1:0] current_count;

always_comb begin
	if(reset) begin
			next_count = {ADD_WIDTH-1{0}};
		end
	else if(receiving_data == 1'b1) 
		begin
			next_count = flip_length;
		end
	else
		begin
			next_count = current_count - 1'b1;
		end

	if(current_count == 0)
		begin
			count_done_o = 1'b1;
		end

end





register ff	#(.BITS(ADD_WIDTH))(
			//input
			.clk(clk),
                        .enable_i(1'b1),
			.data_i(next_count),
			.reset(reset),
			
			
			//out
			.data_o(current_count)
			
			);

endmodule
