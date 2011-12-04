module flipflop #(parameter int BITS = 1) (
	input clk,
	input [BITS-1:0] data_i,
	output reg [BITS-1:0] data_o
);

	always_ff @(posedge clk) begin
		data_o <= data_i;
	end
endmodule
