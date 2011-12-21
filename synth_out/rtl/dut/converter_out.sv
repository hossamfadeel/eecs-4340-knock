module converter_out(
  node_interface n,
  output buffer_full_out, sending_data,
  output [15:0] data_out,
  input buffer_full_in, receiving_data,
  input [15:0] data_in
);
  assign n.buffer_full_out = buffer_full_out;
  assign n.sending_data = sending_data;
  assign n.data_out = data_out;
  assign buffer_full_in = n.buffer_full_in;
  assign receiving_data = n.receiving_data;
  assign data_in = n.data_in;
endmodule
