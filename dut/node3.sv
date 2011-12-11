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

  wire buffer_full_out[1:NUM_INTERFACES], sending_data[1:NUM_INTERFACES];
  wire [15:0] data_out[1:NUM_INTERFACES];
  wire buffer_full_in[1:NUM_INTERFACES], receiving_data[1:NUM_INTERFACES];
  wire [15:0] data_in[1:NUM_INTERFACES];
  wire data_valid[1:NUM_INTERFACES];
  wire address_write_enable[1:NUM_INTERFACES];

  converter c1 (local_node, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
  converter c2 (node_0, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);
  converter c3 (node_1, buffer_full_out[3], sending_data[3], data_out[3], buffer_full_in[3], receiving_data[3], data_in[3]);

  generate
    for(genvar i = 1; i <= NUM_INTERFACES; i = i + 1) begin
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
                        .data_in(),
                        .data_out()
                      );
    end
  endgenerate
endmodule
