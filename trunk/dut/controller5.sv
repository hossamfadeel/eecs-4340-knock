module controller5
(	
	input clk,
	input rst,	
	input [7:0] packet_addr [4:0],
	input [7:0] local_addr,
	input [4:0] buffer_full_in,
	input packet_valid,

	output logic [1:0] grant_0,
	output logic [1:0] grant_1,
	output logic [3:0] grant_2,
	output logic [3:0] grant_3,
	output logic [3:0] grant_4,
	output logic [4:0] grant_v
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

	dccl dccl_n(
			.packet_addr_y_i(packet_addr[0][3:0]),
			.packet_addr_x_i(packet_addr[0][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(),
			.south_req(request[1][0]),
			.east_req(request[2][0]),
			.west_req(request[3][0]),
			.local_req(request[4][0])
	);

	dccl dccl_s(
			.packet_addr_y_i(packet_addr[1][3:0]),
			.packet_addr_x_i(packet_addr[1][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(request[0][0]),
			.south_req(),
			.east_req(request[2][1]),
			.west_req(request[3][1]),
			.local_req(request[4][1])
	);

	dccl dccl_e(
			.packet_addr_y_i(packet_addr[2][3:0]),
			.packet_addr_x_i(packet_addr[2][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(),
			.south_req(),
			.east_req(),
			.west_req(request[3][2]),
			.local_req(request[4][2])
	);

	dccl dccl_w(
			.packet_addr_y_i(packet_addr[3][3:0]),
			.packet_addr_x_i(packet_addr[3][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(),
			.south_req(),
			.east_req(request[2][2]),
			.west_req(),
			.local_req(request[4][3])
	);

	dccl dccl_l(
			.packet_addr_y_i(packet_addr[4][3:0]),
			.packet_addr_x_i(packet_addr[4][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid),

			.north_req(request[0][1]),
			.south_req(request[1][1]),
			.east_req(request[2][3]),
			.west_req(request[3][3]),
			.local_req()
	);

endmodule
