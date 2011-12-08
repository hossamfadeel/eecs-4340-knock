module controller5
(	
	input clk,
	input rst,	
	input [7:0] packet_addr [4:0],
	input [4:0] buffer_full_in,

	output logic [1:0] grant_0,
	output logic [1:0] grant_1,
	output logic [3:0] grant_2,
	output logic [3:0] grant_3,
	output logic [3:0] grant_4,
	output logic [5:0] grant_v
);

	wire [3:0] request [4:0];

	arbiter2 arbiter_n(
	//input
		.clk, .rst, .request(request[0][1:0]), .buffer_full_i(buffer_full_in[0]),
	//output
		.grant(grant_0), .grant_v_o(grant_v[0])
	);

	arbiter2 arbiter_s(
	//input
		.clk, .rst, .request(request[1][1:0]), .buffer_full_i(buffer_full_in[1]),
	//output
		.grant(grant_1), .grant_v_o(grant_v[1])
	);

	arbiter4 arbiter_e(
	//input
		.clk, .rst, .request(request[2]), .buffer_full_i(buffer_full_in[2]),
	//output
		.grant(grant_2), .grant_v_o(grant_v[2])
	);
	
	arbiter4 arbiter_w(
	//input
		.clk, .rst, .request(request[3]), .buffer_full_i(buffer_full_in[3]),
	//output
		.grant(grant_3), .grant_v_o(grant_v[3])
	);

	arbiter4 arbiter_l(
	//input
		.clk, .rst, .request(request[4]), .buffer_full_i(buffer_full_in[4]),
	//output
		.grant(grant_4), .grant_v_o(grant_v[4])
	);

endmodule
