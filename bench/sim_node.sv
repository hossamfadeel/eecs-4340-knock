class sim_node;
  class out_data;
    bit buffer_full, sending_data;
    int data_out;
  endclass
  class in_data;
    bit buffer_full, receiving_data;
    int data_in;
  endclass

  int b_count, this_x, this_y;
  fifo buffer[]; //local, north, south, east, west 
  out_data od[];
  in_data id[];

  function new(int x, int y);
    this_x = x;
    this_y = y;

    if(`TOP(y) && `LEFT(x)) begin
      b_count = 3;
    end else if (`TOP(y) && `RIGHT(x)) begin
      b_count = 3;
    end else if (`BOTTOM(y) && `LEFT(x)) begin
      b_count = 3;
    end else if (`BOTTOM(y) && `RIGHT(x)) begin
      b_count = 3;
    end else if (`TOP(y)) begin
      b_count = 4;
    end else if (`BOTTOM(y)) begin
      b_count = 4;
    end else if (`LEFT(x)) begin
      b_count = 4;
    end else if (`RIGHT(x)) begin
      b_count = 4;
    end else begin
      b_count = 5;
    end

    buffer = new[b_count];
    od = new[b_count];
    id = new[b_count];
    for(int i=0; i<b_count; i++) begin
      buffer[i] = new;
      od[i] = new;
      id[i] = new;
    end
  endfunction

  function reset();
    for(int i=0; i<b_count; i++) begin
      buffer[i].reset();
      od[i].buffer_full = buffer[i].full();
    end
  endfunction
endclass
