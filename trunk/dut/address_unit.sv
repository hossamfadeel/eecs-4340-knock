module address_unit(
	input clk,
	input reset,
	input count,
	input [7:0] packet_in,
	
	output logic [7:0] packet_addr
);

	wire [3:0] addr_x_o;
	wire [3:0] addr_y_o;

	assign packet_addr[3:0] = count ? packet_addr[3:0] : addr_x_o;
	assign packet_addr[7:4] = count ? packet_addr[7:4] : addr_y_o;

	register  #(.BITS(4))
		addr_x(
			//input
			.clk(clk),
			.enable_i(count),
			.data_i(packet_in[3:0]),
			.reset(reset),


			//out
			.data_o(addr_x_o)

			);

	register  #(.BITS(4))
		addr_y(
			//input
			.clk(clk),
			.enable_i(count),
			.data_i(packet_in[7:4]),
			.reset(reset),


			//out
			.data_o(addr_y_o)

			);

endmodule
