interface node_interface (
  input bit clk
);

  logic buffer_full_in, buffer_full_out;
  logic receiving_data, sending_data;
  logic [15:0] data_in, data_out;
  
  clocking cb @(posedge clk);
    output buffer_full_in, receiving_data, data_in;
    input buffer_full_out, sending_data, data_out;
  endclocking

  modport dut(input buffer_full_in, receiving_data, data_in, output buffer_full_out, sending_data, data_out);
  modport bench(clocking cb);
endinterface
