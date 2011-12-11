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
  wire [4:0] grant_v;

  wire [7:0] packet_addr [4:0];

  assign local_addr[7:4] = NODE_Y[3:0];
  assign local_addr[3:0] = NODE_X[3:0];

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
                    .data_out(data_out[i])
                  );


      counter c ( .clk(clk.clk),
                  .reset(reset.reset),
                  .flit_length(8'h01),
                  .count_enable(receiving_data[i]),
                  .is_address(address_write_enable[i])
                );

      address_unit au ( .clk(clk.clk),
                        .reset(reset.reset),
                        .write_enable(address_write_enable[i]),
                        .interface_data_in(data_in([i][7:0])),
						.buffer_data_in(data_out[i][7:0]),
						.data_select(data_valid[i]),
                        .data_out(packet_addr[i])
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
					.grant_0, .grant_1, .grant_2, .grant_3, .grant_4, .grant_v 
					);


endmodule
