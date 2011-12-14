typedef class data;

class sim_node;
  class out_data;
    bit buffer_full, sending_data;
    int data_out;
    
    function copy(out_data base);
      buffer_full = base.buffer_full;
      sending_data = base.sending_data;
      data_out = base.data_out;
    endfunction
  endclass
  class in_data;
    bit buffer_full, receiving_data;
    int data_in;

    function copy(in_data base);
      buffer_full = base.buffer_full;
      receiving_data = base.receiving_data;
      data_in = base.data_in;
    endfunction
  endclass

  data d;
  int dir_map[4]; //east, south, west, north
  int b_count, this_x, this_y, this_i, capture_node[], capture_if[];
  int address[], flit_count[];
  fifo buffer[]; //local, east, south, west, north 
  out_data od[];
  in_data id[];

  function copy(sim_node base);
    dir_map = base.dir_map;
    b_count = base.b_count;
    this_x = base.this_x;
    this_y = base.this_y;
    this_i = base.this_i;
    capture_node = base.capture_node;
    capture_if = base.capture_if;
    address = base.address;
    flit_count = base.flit_count;
    for(int i=0; i<b_count; i++) begin
      buffer[i].copy(base.buffer[i]);
      od[i].copy(base.od[i]);
      id[i].copy(base.id[i]);
    end
  endfunction

  function new(const ref data _d, input int x, int y);
    int n_east = `INDEX(x+1,y);
    int n_south = `INDEX(x,y+1);
    int n_west = `INDEX(x-1,y);
    int n_north = `INDEX(x,y-1);

    this_x = x;
    this_y = y;
    `ifdef NOC_MODE
      this_i = `INDEX(x,y) - 1;
    `else
      this_i = 0;
    `endif
    d = _d;

    if(`TOP(y) && `LEFT(x)) begin
      b_count = 3;
      dir_map = '{0, 1, -1, -1};
    end else if (`TOP(y) && `RIGHT(x)) begin
      b_count = 3;
      dir_map = '{-1, 0, 1, -1};
    end else if (`BOTTOM(y) && `LEFT(x)) begin
      b_count = 3;
      dir_map = '{0, -1, -1, 1};
    end else if (`BOTTOM(y) && `RIGHT(x)) begin
      b_count = 3;
      dir_map = '{-1, -1, 0, 1};
    end else if (`TOP(y)) begin
      b_count = 4;
      dir_map = '{0, 1, 2, -1};
    end else if (`BOTTOM(y)) begin
      b_count = 4;
      dir_map = '{0, -1, 1, 2};
    end else if (`LEFT(x)) begin
      b_count = 4;
      dir_map = '{0, 1, -1, 2};
    end else if (`RIGHT(x)) begin
      b_count = 4;
      dir_map = '{-1, 0, 1, 2};
    end else begin
      b_count = 5;
      dir_map = '{0, 1, 2, 3};
    end

    buffer = new[b_count];
    od = new[b_count];
    id = new[b_count];
    address = new[b_count];
    flit_count = new[b_count];
    capture_node = new[b_count-1];
    capture_if = new[b_count-1];
    for(int i=0; i<b_count; i++) begin
      buffer[i] = new;
      od[i] = new;
      id[i] = new;
      address[i] = 0;
      flit_count[i] = 0;
    end

    if(`TOP(y) && `LEFT(x)) begin
      capture_node = '{n_east, n_south};
      capture_if = '{`DIR_WEST, `DIR_NORTH};
    end else if (`TOP(y) && `RIGHT(x)) begin
      capture_node = '{n_south, n_west};
      capture_if = '{`DIR_NORTH, `DIR_EAST};
    end else if (`BOTTOM(y) && `LEFT(x)) begin
      capture_node = '{n_east, n_north};
      capture_if = '{`DIR_WEST, `DIR_SOUTH};
    end else if (`BOTTOM(y) && `RIGHT(x)) begin
      capture_node = '{n_west, n_north};
      capture_if = '{`DIR_EAST, `DIR_SOUTH};
    end else if (`TOP(y)) begin
      capture_node = '{n_east, n_south, n_west};
      capture_if = '{`DIR_WEST, `DIR_NORTH, `DIR_EAST};
    end else if (`BOTTOM(y)) begin
      capture_node = '{n_east, n_west, n_north};
      capture_if = '{`DIR_WEST, `DIR_EAST, `DIR_SOUTH};
    end else if (`LEFT(x)) begin
      capture_node = '{n_east, n_south, n_north};
      capture_if = '{`DIR_WEST, `DIR_NORTH, `DIR_SOUTH};
    end else if (`RIGHT(x)) begin
      capture_node = '{n_south, n_west, n_north};
      capture_if = '{`DIR_NORTH, `DIR_EAST, `DIR_SOUTH};
    end else begin
      capture_node = '{n_east, n_south, n_west, n_north};
      capture_if = '{`DIR_WEST, `DIR_NORTH, `DIR_EAST, `DIR_SOUTH};
    end
  endfunction

  function capture();
    //$display("Node %d Capture: ", `INDEX(this_x, this_y));
    for(int i=0; i<b_count-1; i++) begin
      int dm[] = d.nodes[capture_node[i]-1].dir_map;
      //$display("\tInterface: %d", i);
      //$display("\t\tCN: %d", capture_node[i]);
      //$display("\t\tCI: %d", capture_if[i]);
      //$display("\t\tCDM: %d", dm[capture_if[i]]);
      id[i+1].buffer_full = d.nodes[capture_node[i]-1].od[dm[capture_if[i]]].buffer_full;
      id[i+1].receiving_data = d.nodes[capture_node[i]-1].od[dm[capture_if[i]]].sending_data;
      id[i+1].data_in = d.nodes[capture_node[i]-1].od[dm[capture_if[i]]].data_out;
    end
  endfunction

  function process();
    bit is_sending[] = new[b_count];
    int data_out[] = new[b_count];    

    $display("Node %0d Inputs:", this_i+1);
    for(int i=0; i<b_count; i++) begin
      $display("\tInterface %0d:", i);
      $display("\t\tBF: %b", id[i].buffer_full);
      $display("\t\tRD: %b", id[i].receiving_data);
      $display("\t\tDI: %h", id[i].data_in);
    end

    //$display("Node %0d Outputs:", this_i+1);
    for(int i=0; i<b_count; i++) begin
      is_sending[i] = 1'b0;
      data_out[i] = buffer[i].data_out();

      if(!id[i].buffer_full && buffer[i].data_valid()) begin
        is_sending[i] = 1'b1;
        d.next_nodes[this_i].buffer[i].pop();
      end
      //$display("\tInterface %0d:", i);
      //$display("\t\tSD: %b", is_sending[i]);
      //$display("\t\tDO%0d: %h",i, data_out[i]);
    end

    for(int i=0; i<b_count; i++) begin
      if(flit_count[i] == 0) begin
        if(!d.next_nodes[this_i].buffer[i].data_valid() && id[i].receiving_data) begin
          d.next_nodes[this_i].flit_count[i] = id[i].data_in[15:8];
          d.next_nodes[this_i].address[i] = id[i].data_in[7:0];
        end else if(d.next_nodes[this_i].buffer[i].data_valid()) begin
          d.next_nodes[this_i].flit_count[i] = data_out[i][15:8];
          d.next_nodes[this_i].address[i] = data_out[i][7:0];
        end
      end else if (flit_count[i] == 1) begin
        if(is_sending[i]) begin
          if(d.next_nodes[this_i].buffer[i].data_valid()) begin
            $display("Interface %0d Here1", i);
            d.next_nodes[this_i].flit_count[i] = data_out[i][15:8];
            d.next_nodes[this_i].address[i] = data_out[i][7:0];
          end else begin
            if(id[i].receiving_data) begin
              $display("Interface %0d Here2", i);
              d.next_nodes[this_i].flit_count[i] = id[i].data_in[15:8];
              d.next_nodes[this_i].address[i] = id[i].data_in[7:0];
            end else begin
              $display("Interface %0d Here3", i);
              d.next_nodes[this_i].flit_count[i] --;
              d.next_nodes[this_i].address[i] = address[i];
            end
          end
        end
      end else if (is_sending[i]) begin
        d.next_nodes[this_i].flit_count[i] --;
        d.next_nodes[this_i].address[i] = address[i];
      end
      
      $display("Address for Interface %0d: %h", i, address[i]);
      $display("Packets Remaining for Interface %0d: %0d", i, d.next_nodes[this_i].flit_count[i]);

      if(id[i].receiving_data) begin
        d.next_nodes[this_i].buffer[i].push(id[i].data_in);
      end
    end

    for(int i=0; i<b_count; i++) begin
      d.next_nodes[this_i].od[i].buffer_full = buffer[i].full();
      d.next_nodes[this_i].od[i].sending_data = is_sending[i];
      d.next_nodes[this_i].od[i].data_out = address[i]; //data_out[i];
    end
  endfunction

  function reset();
    for(int i=0; i<b_count; i++) begin
      buffer[i].reset();
      od[i].buffer_full = buffer[i].full();
    end
  endfunction
endclass
