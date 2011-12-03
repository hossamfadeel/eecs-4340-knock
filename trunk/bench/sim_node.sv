class sim_node;
  class out_data;
    bit buffer_full, sending_data;
    int data_out;
  endclass

  int b_count;
  fifo buffer[]; //local, node0, node1, node2, node3
  out_data od[];

  function new(int count);
    b_count = count;
    buffer = new[count];
    od = new[count];
    for(int i=0; i<count; i++) begin
      buffer[i] = new;
      od[i] = new;
    end
  endfunction

  function reset();
    for(int i=0; i<b_count; i++) begin
      buffer[i].reset();
    end
  endfunction
endclass
