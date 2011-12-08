module counter#(parameter ADD_WIDTH = 5)
(
	input clk,
	input reset,
	input [ADD_WIDTH-1:0] flit_length,
	input receiving_data,
	output logic count_done_o,
	//output logic [ADD_WIDTH-1:0] cc_o
);


logic [ADD_WIDTH-1:0] next_count;
wire [ADD_WIDTH-1:0] current_count;

always_comb begin
	if(reset) begin
			next_count = 0;
		end
	else if(receiving_data == 1'b1) 
		begin
			next_count = flit_length;
		end
	else if(current_count != 0)
		begin
			next_count = current_count - 1'b1;
		end


	if(current_count == 0)
		begin
			count_done_o = 1'b1;
		end
	else
		begin
			count_done_o =1'b0;
		end



end


//assign cc_o = current_count;


register #(.BITS(ADD_WIDTH)) fffg (
			//input
			.clk(clk),
      .enable_i(1'b1),
			.data_i(next_count),
			.reset(reset),
			
			
			//out
			.data_o(current_count)
			
			);

endmodule
