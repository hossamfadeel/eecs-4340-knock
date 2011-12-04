module node3(
	clock_interface.dut clk,
	reset_interface.dut reset,
	node_interface.dut local_node,
	node_interface.dut node_0,
	node_interface.dut node_1
);
  wire pop;

  fifo local_buffer ( .clk(clk.clk),
                      .rst(reset.reset),
                      .push_req(local_node.receiving_data),
                      .pop_req(pop),
                      .data_in(local_node.data_in),
                      .full(local_node.buffer_full_out),
                      .data_out(local_node.data_out)
                    );
endmodule
