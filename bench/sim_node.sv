typedef class data;

class sim_node;
  class out_data;
    bit buffer_full, sending_data;
    int data_out;
  endclass
  class in_data;
    bit buffer_full, receiving_data;
    int data_in;
  endclass

  data d;
  int b_count, this_x, this_y, capture_node[], capture_if[];
  fifo buffer[]; //local, east, south, west, north 
  out_data od[];
  in_data id[];

  function new(const ref data _d, input int x, int y);
    int n_east = `INDEX(x+1,y);
    int n_south = `INDEX(x,y+1);
    int n_west = `INDEX(x-1,y);
    int n_north = `INDEX(x,y-1);

    this_x = x;
    this_y = y;
    d = _d;

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
    capture_node = new[b_count-1];
    capture_if = new[b_count-1];
    for(int i=0; i<b_count; i++) begin
      buffer[i] = new;
      od[i] = new;
      id[i] = new;
    end

    if(`TOP(y) && `LEFT(x)) begin
    end else if (`TOP(y) && `RIGHT(x)) begin
    end else if (`BOTTOM(y) && `LEFT(x)) begin
    end else if (`BOTTOM(y) && `RIGHT(x)) begin
    end else if (`TOP(y)) begin
    end else if (`BOTTOM(y)) begin
    end else if (`LEFT(x)) begin
    end else if (`RIGHT(x)) begin
    end else begin
    end
  endfunction

  function capture();
    for(int i=0; i<b_count-1; i++) begin
      //id[i+1].buffer_full = d.nodes[capture_node[i]].od[capture_if[i]].buffer_full;
      //id[i+1].receiving_data = d.nodes[capture_node[i]].od[capture_if[i]].sending_data;
      //id[i+1].data_in = d.nodes[capture_node[i]].od[capture_if[i]].data_out;
    end
  endfunction

  function process();
    //TODO: act on captured inputs
  endfunction

  function reset();
    for(int i=0; i<b_count; i++) begin
      buffer[i].reset();
      od[i].buffer_full = buffer[i].full();
    end
  endfunction
endclass
