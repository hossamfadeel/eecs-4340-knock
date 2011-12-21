module register #(parameter int BITS = 1) (
	input clk, enable_i, reset,
	input [BITS-1:0] data_i,
	input [BITS-1:0] data_o
);

	wire [BITS-1:0] write_data;

	flipflop #(.BITS(BITS)) FF (.clk(clk), .data_i(write_data), .data_o(data_o));

	assign write_data = reset ? 0 : (enable_i ? data_i : data_o);
endmodule
