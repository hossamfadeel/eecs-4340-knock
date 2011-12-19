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

  wire [1:0] grant_1;
  wire [1:0] grant_2;
  wire [2:0] grant_v;
  wire [2:0] pop_v;

  converter c0 (node_0, buffer_full_out[0], sending_data[0], data_out[0], buffer_full_in[0], receiving_data[0], data_in[0]);
  converter c1 (node_1, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
  converter c2 (local_node, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);

  assign sending_data = grant_v;

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

	if (`TOP(NODE_Y) & `RIGHT(NODE_X)) begin
		controller3_ne ne(
                  .clk(clk.clk),
                  .rst(reset.reset),
                  .packet_addr,
                  .local_addr,
                  .packet_valid(data_valid),
                  .buffer_full_in,
                  .grant_1,
                  .grant_2,
                  .grant_v,
                  .pop_v
                );

		assign data_out[0] = grant_v[0] ? buffer_out[2] : 16'b0;
		mux2_1 mux_e(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);

		mux2_1 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.data_o(data_out[2])
		);

	end

    else if (`TOP(NODE_Y) & `LEFT(NODE_X)) begin
		controller3_nw nw(.clk(clk.clk),
                  .rst(reset.reset),
                  .packet_addr,
                  .local_addr,
                  .packet_valid(data_valid),
                  .buffer_full_in,
                  
                  .grant_1,
                  .grant_2,
                  .grant_v,
                  .pop_v
                ); 

		assign data_out[0] = grant_v[0] ? buffer_out[2] : 16'b0;
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
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.data_o(data_out[2])
		);
	end

	else if (`BOTTOM(NODE_Y) & `LEFT(NODE_X)) begin
		controller3_sw sw(.clk(clk.clk),
                  .rst(reset.reset),
                  .packet_addr,
                  .local_addr,
                  .packet_valid(data_valid),
                  .buffer_full_in,
                  
                  .grant_1,
                  .grant_2,
                  .grant_v,
                  .pop_v
                ); 

		assign data_out[0] = grant_v[0] ? buffer_out[2] : 16'b0;

		mux2_1 mux_e(
				.data0(buffer_out[0]),
				.data1(buffer_out[2]),
				.select0(grant_1[0]),
				.select1(grant_1[1]),
				.data_o(data_out[1])
		);

		mux2_1 mux_l(
				.data0(buffer_out[0]),
				.data1(buffer_out[1]),
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.data_o(data_out[2])
		);

	end

	else begin
		controller3_se se(.clk(clk.clk),
                  .rst(reset.reset),
                  .packet_addr,
                  .local_addr,
                  .packet_valid(data_valid),
                  .buffer_full_in,
                  
                  .grant_1,
                  .grant_2,
                  .grant_v,
                  .pop_v
                );

		assign data_out[0] = grant_v[0] ? buffer_out[2] : 16'b0;
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
				.select0(grant_2[0]),
				.select1(grant_2[1]),
				.data_o(data_out[2])
		);

	end
  endgenerate
endmodule
