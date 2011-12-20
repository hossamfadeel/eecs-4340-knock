module node4 #(
  parameter int NODE_X = 0,
  parameter int NODE_Y = 0
)
(
  clock_interface.dut clk,
  reset_interface.dut reset,
  node_interface.dut local_node,
  node_interface.dut node_0,
  node_interface.dut node_1,
  node_interface.dut node_2
);
  parameter NUM_INTERFACES = 4;

  wire [NUM_INTERFACES-1:0] buffer_full_out, sending_data;
  wire [15:0] data_out[NUM_INTERFACES-1:0];

  wire [NUM_INTERFACES-1:0] buffer_full_in, receiving_data;
  wire [15:0] data_in[NUM_INTERFACES-1:0];

  wire [15:0] buffer_out[NUM_INTERFACES-1:0];
  wire [7:0] packet_addr[NUM_INTERFACES-1:0];
  wire [15:0] next_buffer_out[NUM_INTERFACES-1:0];
  wire next_data_valid[NUM_INTERFACES-1:0];
  wire [NUM_INTERFACES-1:0] data_valid;

  wire [7:0] local_addr = {NODE_X[3:0], NODE_Y[3:0]};

  wire [2:0] grant_0;
  wire [2:0] grant_1;
  wire [2:0] grant_2;
  wire [2:0] grant_3;
  wire [3:0] grant_v;
  wire [3:0] pop_v;

  assign sending_data = grant_v;

  converter_out c3 (local_node, buffer_full_out[3], sending_data[3], data_out[3], buffer_full_in[3], receiving_data[3], data_in[3]);

  generate
    for(genvar i = 0; i <= NUM_INTERFACES-1; i = i + 1) begin
      fifo_kev buffer ( .clk(clk.clk),
                    .rst(reset.reset),
                    .push_req(receiving_data[i]),
                    .pop_req(pop_v[i]),
                    .data_in(data_in[i]),
                    .full(buffer_full_out[i]),
                    .data_valid(data_valid[i]),
                    .data_out(buffer_out[i]),
                    .next_data_out(next_buffer_out[i]),
                    .next_data_valid(next_data_valid[i])
                  );

      address_counter addr (  .clk(clk.clk),
                              .rst(reset.reset),
                              .interface_flit_length(data_in[i][15:8]),
                              .interface_flit_address(data_in[i][7:0]),
                              .buffer_flit_length(next_buffer_out[i][15:8]),
                              .buffer_flit_address(next_buffer_out[i][7:0]),       
                              .buffer_data_valid(next_data_valid[i]),
                              .buffer_pop(pop_v[i]),
                              .receiving_data(receiving_data[i]),
                              .flit_address_o(packet_addr[i])
			   );
    end

	if (`TOP(NODE_Y)) begin

		converter_out c0 (node_0, buffer_full_out[0], sending_data[0], data_out[0], buffer_full_in[0], receiving_data[0], data_in[0]);
		`CONVERTER c1 (node_1, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
		converter_out c2 (node_2, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);

		controller4_edge_n n(.clk(clk.clk),
                        .rst(reset.reset),
						.packet_addr,
						.local_addr,
						.packet_valid(data_valid),
						.buffer_full_in,

						.grant_1,
						.grant_2,
						.grant_3,
						.grant_v,
						.pop_v
						);

		assign data_out[0] = sending_data[0] ? buffer_out[3] : 16'b0;

		mux3_1 mux_e(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.data2(buffer_out[3]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.select2(grant_1[2]),
				.data_o(data_out[1])
		);

		mux3_1 mux_w(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[3]),
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.select2(grant_2[2]),
				.data_o(data_out[2])
		);

		mux3_1 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[2]),
				.select0(grant_3[0]),
				.select1(grant_3[1]),
				.select2(grant_3[2]),
				.data_o(data_out[3])
		);
	end

    else if (`BOTTOM(NODE_Y)) begin

		`CONVERTER c0 (node_0, buffer_full_out[0], sending_data[0], data_out[0], buffer_full_in[0], receiving_data[0], data_in[0]);
		`CONVERTER c1 (node_1, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
		converter_out c2 (node_2, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);

		controller4_edge_s s(.clk(clk.clk),
                        .rst(reset.reset),
						.packet_addr,
						.local_addr,
						.packet_valid(data_valid),
						.buffer_full_in,

						.grant_1,
						.grant_2,
						.grant_3,
						.grant_v,
						.pop_v
						); 

		assign data_out[0] = sending_data[0] ? buffer_out[3] : 16'b0;

		mux3_1 mux_e(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.data2(buffer_out[3]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.select2(grant_1[2]),
				.data_o(data_out[1])
		);

		mux3_1 mux_w(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[3]),
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.select2(grant_2[2]),
				.data_o(data_out[2])
		);

		mux3_1 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[2]),
				.select0(grant_3[0]),
				.select1(grant_3[1]),
				.select2(grant_3[2]),
				.data_o(data_out[3])
		);
	end

	else if (`RIGHT(NODE_X)) begin

		`CONVERTER c0 (node_0, buffer_full_out[0], sending_data[0], data_out[0], buffer_full_in[0], receiving_data[0], data_in[0]);
		converter_out c1 (node_1, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
		converter_out c2 (node_2, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);

		controller4_edge_e e(.clk(clk.clk),
                        .rst(reset.reset),
						.packet_addr,
						.local_addr,
						.packet_valid(data_valid),
						.buffer_full_in,

						.grant_0(grant_0[1:0]),						
						.grant_1(grant_1[1:0]),
						.grant_2,
						.grant_3,
						.grant_v,
						.pop_v
						); 

		mux2_1 mux_n(
				.data0(buffer_out[1]),
				.data1(buffer_out[3]),
				.select0(grant_0[0]),
				.select1(grant_0[1]),
				.data_o(data_out[0])
		);

		mux2_1 mux_s(
				.data0(buffer_out[0]),
				.data1(buffer_out[3]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);


		mux3_1 mux_w(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[3]),
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.select2(grant_2[2]),
				.data_o(data_out[2])
		);

		mux3_1 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[2]),
				.select0(grant_3[0]),
				.select1(grant_3[1]),
				.select2(grant_3[2]),
				.data_o(data_out[3])
		);
	end

	else begin

		`CONVERTER c0 (node_0, buffer_full_out[0], sending_data[0], data_out[0], buffer_full_in[0], receiving_data[0], data_in[0]);
		converter_out c1 (node_1, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
		`CONVERTER c2 (node_2, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);

		controller4_edge_w w(.clk(clk.clk),
                        .rst(reset.reset),
						.packet_addr,
						.local_addr,
						.packet_valid(data_valid),
						.buffer_full_in,

						.grant_0(grant_0[1:0]),						
						.grant_1(grant_1[1:0]),
						.grant_2,
						.grant_3,
						.grant_v,
						.pop_v
						); 

		mux2_1 mux_n(
				.data0(buffer_out[1]),
				.data1(buffer_out[3]),
				.select0(grant_0[0]),
				.select1(grant_0[1]),
				.data_o(data_out[0])
		);

		mux2_1 mux_s(
				.data0(buffer_out[0]),
				.data1(buffer_out[3]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);


		mux3_1 mux_e(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[3]),
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.select2(grant_2[2]),
				.data_o(data_out[2])
		);

		mux3_1 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.data2(buffer_out[2]),
				.select0(grant_3[0]),
				.select1(grant_3[1]),
				.select2(grant_3[2]),
				.data_o(data_out[3])
		);
	end

  endgenerate
endmodule
