module address_unit(
	input clk,
	input reset,
	input write_enable,
	input [7:0] data_in,
	output logic [7:0] data_out
);

	register  #(.BITS(4)) addr_x(
		//input
		.clk(clk),
		.reset(reset),
		.enable_i(write_enable),
		.data_i(data_in[3:0]),
		//out
		.data_o(data_out[3:0])
	);

	register  #(.BITS(4)) addr_y(
		//input
		.clk(clk),
		.reset(reset),
		.enable_i(write_enable),
		.data_i(data_in[7:4]),
		//out
		.data_o(data_out[7:4])
	);
endmodule
