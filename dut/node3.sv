module node3 #(
  parameter int NODE_X = 0,
  parameter int NODE_Y = 0
)
(
  clock_interface.dut clk,
  reset_interface.dut reset,
  node_interface.dut local_node,
  node_interface.dut node_0,
  node_interface.dut node_1
);
  parameter NUM_INTERFACES = 3;

  wire buffer_full_out[NUM_INTERFACES-1:0], sending_data[NUM_INTERFACES-1:0];
  wire [15:0] data_out[NUM_INTERFACES-1:0];

  wire buffer_full_in[NUM_INTERFACES-1:0], receiving_data[NUM_INTERFACES-1:0];
  wire [15:0] data_in[NUM_INTERFACES-1:0];

  wire [15:0] buffer_out[NUM_INTERFACES-1:0];
  wire [7:0] packet_addr[NUM_INTERFACES-1:0];
  wire data_valid[NUM_INTERFACES-1:0];

  wire [1:0] grant_1;
  wire [1:0] grant_2;
  wire [2:0] grant_v;

  converter c0 (node_0, buffer_full_out[0], sending_data[0], data_out[0], buffer_full_in[0], receiving_data[0], data_in[0]);
  converter c1 (node_1, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
  converter c2 (local_node, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);

  wire [7:0] local_addr = {NODE_X[3:0], NODE_Y[3:0]};

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
                    .data_out(buffer_out[i])
                  );

      address_counter addr (  .clk(clk.clk),
                              .rst(reset.reset),
                              .interface_flit_length(data_in[i][15:8]),
                              .interface_flit_address(data_in[i][7:0]),
                              .buffer_flit_length(buffer_out[i][15:8]),
                              .buffer_flit_address(buffer_out[i][7:0]),       
                              .buffer_data_valid(data_valid[i]),
                              .buffer_pop(sending_data[i]),
                              .receiving_data(receiving_data[i]),
                              .flit_address_o(packet_addr[i])
			   );

      //assign data_out[i][15:8] = 8'h00;
      //assign data_out[i][7:0] = packet_addr[i];
    end

	if (`TOP(NODE_Y) & `RIGHT(NODE_X)) begin
		controller3_ne ne(.clk(clk.clk),
                        .reset(reset.reset),
						.packet_addr,
						.local_addr,
						.buffer_full_in,

						.grant_1,
						.grant_2,
						.grant_v
						);

		assign data_out[0] = sending_data[0] ? buffer_out[0] : 16'b0;

		MUX_2 mux_e(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);

		MUX_2 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[2])
		);

	end

    else if (`TOP(NODE_Y) & `LEFT(NODE_X)) begin
		controller3_nw nw(.clk(clk.clk),
                .rst(reset.reset),
  		.packet_addr(packet_addr),
  		.local_addr,
  		.buffer_full_in,
  
  		.grant_1,
  		.grant_2,
  		.grant_v
  		); 

		assign data_out[0] = sending_data[0] ? buffer_out[0] : 16'b0;

		mux2_1 mux_w(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);

		mux2_1 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[2])
		);

	end

	else if (`BOTTOM(NODE_Y) & `LEFT(NODE_X)) begin
		controller3_sw sw(.clk(clk.clk),
                        .reset(reset.reset),
						.packet_addr,
						.local_addr,
						.buffer_full_in,

						.grant_1,
						.grant_2,
						.grant_v
						); 

		assign data_out[0] = sending_data[0] ? buffer_out[0] : 16'b0;

		MUX_2 mux_e(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);

		MUX_2 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[2])
		);

	end

	else begin
		controller3_se se(.clk(clk.clk),
                        .reset(reset.reset),
						.packet_addr,
						.local_addr,
						.buffer_full_in,

						.grant_1,
						.grant_2,
						.grant_v
						);
		assign data_out[0] = sending_data[0] ? buffer_out[0] : 16'b0;
		MUX_2 mux_w(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);

		MUX_2 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[2])
		);

	end
  endgenerate
endmodule
