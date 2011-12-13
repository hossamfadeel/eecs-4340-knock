class environment;
  data d;
  configuration cfg;
  tracker t;
  reset_transaction rst;
  node_transaction in_data[`INTERFACES];

  int transaction_count;

  function new();
    d = new();
    cfg = new();
    t = new();

    rst = new(this);
    for(int i=0; i<`INTERFACES; i=i+1) begin
      in_data[i] = new(this, i);
    end

    transaction_count = 0;
  endfunction

  function gen();

    rst.randomize();
    for(int i=0; i<`INTERFACES; i=i+1) begin
      in_data[i].randomize();
    end

    if(rst.reset) begin
      rst.action(); 
    end else begin
      for(int i=0; i<`INTERFACES; i=i+1) begin
        in_data[i].action();
      end
      for(int i=0; i<`NODE_COUNT; i=i+1) begin
        d.nodes[i].process();
      end
    end
  endfunction

  function check(int i, bit bf, bit sd, int data_out);
     int node_index, output_index;

    `ifdef NOC_MODE
      node_index = i-1;
      output_index = 0;
    `else
      node_index = 0;
      output_index = i-1;
    `endif

      if(d.next_nodes[node_index].od[output_index].buffer_full == bf &&
         d.next_nodes[node_index].od[output_index].sending_data == sd &&
         d.next_nodes[node_index].od[output_index].data_out == data_out) begin
        t.pass();
       // $display("Node %0d, Output %0d", node_index, output_index);
       // $display("\tReceived BF: %b", bf);
       // $display("\tReceived SD: %b", sd);
       // $display("\tReceived DO: %h", data_out);
      end else begin
        $display("Node %0d, Output %0d", node_index, output_index);
        $display("\tExpected BF: %b, Received: %b", d.next_nodes[node_index].od[output_index].buffer_full, bf);
        $display("\tExpected SD: %b, Received: %b", d.next_nodes[node_index].od[output_index].sending_data, sd);
        $display("\tExpected DO: %h, Received: %h", d.next_nodes[node_index].od[output_index].data_out, data_out);

        t.fail("");
      end
  endfunction

  function shift();
    d.shift();
  endfunction
endclass
