module controller3_se
(	
	input clk,
	input rst,	
	input [7:0] packet_addr [2:0],
	input [7:0] local_addr,
	input [2:0] buffer_full_in,

	output logic [1:0] grant_1,
	output logic [1:0] grant_2,
	output logic [2:0] grant_v
);

	wire [1:0] request [2:0];

//to North
	assign grant_v[0] = (request[0][0] & (!buffer_full_in[0]));

	arbiter2 arbiter_w(
	//input
		.clk, .rst, .request(request[1]), .buffer_full_i(buffer_full_in[1]),
	//output
		.grant(grant_1), .grant_v_o(grant_v[2])
	);
	
	arbiter2 arbiter_l(
	//input
		.clk, .rst, .request(request[2]), .buffer_full_i(buffer_full_in[2]),
	//output
		.grant(grant_2), .grant_v_o(grant_v[2])
	);

	dccl dccl_n(
			.packet_addr_y_i(packet_addr[0][3:0]),
			.packet_addr_x_i(packet_addr[0][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(),
			.south_req(),
			.east_req(),
			.west_req(request[1][0]),
			.local_req(request[2][0])
	);

	dccl dccl_w(
			.packet_addr_y_i(packet_addr[3][3:0]),
			.packet_addr_x_i(packet_addr[3][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(),
			.south_req(),
			.east_req(),
			.west_req(),
			.local_req(request[2][1])
	);

	dccl dccl_l(
			.packet_addr_y_i(packet_addr[4][3:0]),
			.packet_addr_x_i(packet_addr[4][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(request[0][0]),
			.south_req(),
			.east_req(),
			.west_req(request[1][1]),
			.local_req()
	);

endmodule
