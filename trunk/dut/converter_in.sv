module converter_in(
  node_interface n,
  output buffer_full_out, sending_data,
  output [15:0] data_out,
  input buffer_full_in, receiving_data,
  input [15:0] data_in
);
  assign n.buffer_full_in = buffer_full_out;
  assign n.receiving_data = sending_data;
  assign n.data_in = data_out;
  assign buffer_full_in = n.buffer_full_out;
  assign receiving_data = n.sending_data;
  assign data_in = n.data_out;
endmodule
  

