module controller4_edge_w
(	
	input clk,
	input rst,	
	input [7:0] packet_addr [3:0],
	input [7:0] local_addr,
	input [3:0] packet_valid,
	input [3:0] buffer_full_in,

	output logic [1:0] grant_0,
	output logic [1:0] grant_1,
	output logic [2:0] grant_2,
	output logic [2:0] grant_3,
	output logic [3:0] grant_v
);

	wire [2:0] request [3:0];

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
	
	arbiter3 arbiter_e(
	//input
		.clk, .rst, .request(request[2]), .buffer_full_i(buffer_full_in[2]),
	//output
		.grant(grant_2), .grant_v_o(grant_v[2])
	);

	arbiter3 arbiter_l(
	//input
		.clk, .rst, .request(request[3]), .buffer_full_i(buffer_full_in[3]),
	//output
		.grant(grant_3), .grant_v_o(grant_v[3])
	);

	dccl dccl_n(
			.packet_addr_y_i(packet_addr[0][3:0]),
			.packet_addr_x_i(packet_addr[0][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid[0]),

			.north_req(),
			.south_req(request[1][0]),
			.east_req(request[2][0]),
			.west_req(),
			.local_req(request[3][0])
	);

	dccl dccl_s(
			.packet_addr_y_i(packet_addr[1][3:0]),
			.packet_addr_x_i(packet_addr[1][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid[1]),

			.north_req(request[0][0]),
			.south_req(),
			.east_req(request[2][1]),
			.west_req(),
			.local_req(request[3][1])
	);

	dccl dccl_e(
			.packet_addr_y_i(packet_addr[2][3:0]),
			.packet_addr_x_i(packet_addr[2][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid[2]),

			.north_req(),
			.south_req(),
			.east_req(),
			.west_req(),
			.local_req(request[3][2])
	);

	dccl dccl_l(
			.packet_addr_y_i(packet_addr[3][3:0]),
			.packet_addr_x_i(packet_addr[3][7:4]),
			.local_addr_y_i(local_addr[3:0]),
			.local_addr_x_i(local_addr[7:4]),
			.packet_valid_i(packet_valid[3]),

			.north_req(request[0][1]),
			.south_req(request[1][1]),
			.east_req(request[2][2]),
			.west_req(),
			.local_req()
	);

endmodule
