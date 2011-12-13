module node5 #(
  parameter int NODE_X = 0,
  parameter int NODE_Y = 0
)
(
  clock_interface.dut clk,
  reset_interface.dut reset,
  node_interface.dut local_node,
  node_interface.dut node_0,
  node_interface.dut node_1,
  node_interface.dut node_2,
  node_interface.dut node_3
);
  parameter NUM_INTERFACES = 5;

  wire buffer_full_out[NUM_INTERFACES-1:0], sending_data[NUM_INTERFACES-1:0];
  wire [15:0] data_out[NUM_INTERFACES-1:0];
  wire buffer_full_in[NUM_INTERFACES-1:0], receiving_data[NUM_INTERFACES-1:0];
  wire [15:0] data_in[NUM_INTERFACES-1:0];
  wire data_valid[NUM_INTERFACES-1:0];
  wire [7:0] local_addr;

  wire [1:0] grant_0;
  wire [1:0] grant_1;
  wire [3:0] grant_2;
  wire [3:0] grant_3;
  wire [3:0] grant_4;

  wire [7:0] packet_addr [4:0];

  assign local_addr[7:4] = NODE_Y[3:0];
  assign local_addr[3:0] = NODE_X[3:0];

  wire [16:0] buffer_data_out [4:0];

  converter c0 (node_0, buffer_full_out[0], sending_data[0], data_out[0], buffer_full_in[0], receiving_data[0], data_in[0]);
  converter c1 (node_1, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
  converter c2 (node_2, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);
  converter c3 (node_3, buffer_full_out[3], sending_data[3], data_out[3], buffer_full_in[3], receiving_data[3], data_in[3]);
  converter c4 (local_node, buffer_full_out[4], sending_data[4], data_out[4], buffer_full_in[4], receiving_data[4], data_in[4]);

  generate
    for(genvar i = 0; i <= NUM_INTERFACES-1; i = i + 1) begin
      assign sending_data[i] = !buffer_full_in[i] & data_valid[i];

      fifo buffer ( .clk(clk.clk),
                    .rst(reset.reset),
                    .push_req(receiving_data[i]),
                    .pop_req(sending_data[i]),
                    .data_in(data_in[i]),
                    .full(buffer_full_out[i]),
                    .data_valid(data_valid[i]),
                    .data_out(buffer_data_out[i])
                  );

	  address_counter addr(
        			.clk(clk.clk),
                    .rst(reset.reset),
       				.interface_flit_length(data_in[i][15:8]),
       				.buffer_flit_length(buffer_data_out[i][15:8]),
					.buffer_data_valid(data_valid[i]),
					.interface_flit_address(data_in[i][7:0]),
					.buffer_flit_address(buffer_data_out[i][7:0]),        
      		 		.buffer_pop(sending_data[i]),
      				.receiving_data(receiving_data[i]),

					.flit_address_o(packet_addr),
					);
    end

  endgenerate

  controller5 ctrl5(//input
 					.clk(clk.clk), 
					.rst(reset.reset),
					.packet_addr, 
					.local_addr, 
					.buffer_full_in,
					.packet_valid(data_valid),
					//output
					.grant_0, .grant_1, .grant_2, .grant_3, .grant_4, 
					.grant_v(sengding_data) 
					);

	MUX_2 mux_n(
			.data0(buffer_data_out[1]),
			.data1(buffer_data_out[4]),
			.select0(grant_0[0]),
			.select1(grant_0[1]),
			.data_o(data_out[0])
	);

	MUX_2 mux_s(
			.data0(buffer_data_out[0]),
			.data1(buffer_data_out[4]),
			.select0(grant_1[0]),
			.select1(grant_1[1]),
			.data_o(data_out[1])
	);

	MUX_4 mux_e(
			.data0(buffer_data_out[0]),
			.data1(buffer_data_out[1]),
			.data2(buffer_data_out[3]),
			.data3(buffer_data_out[4]),
			.select0(grant_2[0]),
			.select1(grant_2[1]),
			.select2(grant_2[2]),
			.select3(grant_2[3]),
			.data_o(data_out[2])
	);

	MUX_4 mux_w(
			.data0(buffer_data_out[0]),
			.data1(buffer_data_out[1]),
			.data2(buffer_data_out[2]),
			.data3(buffer_data_out[4]),
			.select0(grant_3[0]),
			.select1(grant_3[1]),
			.select2(grant_3[2]),
			.select3(grant_3[3]),
			.data_o(data_out[3])
	);

	MUX_4 mux_l(
			.data0(buffer_data_out[0]),
			.data1(buffer_data_out[1]),
			.data2(buffer_data_out[2]),
			.data3(buffer_data_out[3]),
			.select0(grant_4[0]),
			.select1(grant_4[1]),
			.select2(grant_4[2]),
			.select3(grant_4[3]),
			.data_o(data_out[4])
	);

endmodule
