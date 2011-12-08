module node3(
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

  converter c1 (local_node, buffer_full_out[1], sending_data[1], data_out[1], buffer_full_in[1], receiving_data[1], data_in[1]);
  converter c2 (node_0, buffer_full_out[2], sending_data[2], data_out[2], buffer_full_in[2], receiving_data[2], data_in[2]);
  converter c3 (node_1, buffer_full_out[3], sending_data[3], data_out[3], buffer_full_in[3], receiving_data[3], data_in[3]);

  wire [1:NUM_INTERFACES] pop;
  assign pop = {NUM_INTERFACES{buffer_full_in[1]}};

  generate
    for(genvar i = 1; i <= NUM_INTERFACES; i = i + 1) begin
      fifo buffer ( .clk(clk.clk),
                    .rst(reset.reset),
                    .push_req(receiving_data[i]),
                    .pop_req(1'b1),
                    .data_in(data_in[i]),
                    .full(buffer_full_out[i]),
                    .data_out(data_out[i])
                  );
    end
  endgenerate
endmodule