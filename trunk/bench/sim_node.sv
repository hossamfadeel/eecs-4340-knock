typedef class data;

class sim_node;
  class out_data;
    bit buffer_full, sending_data;
    int data_out;
		int next_data_out;
    
    function copy(out_data base);
      buffer_full = base.buffer_full;
      sending_data = base.sending_data;
      data_out = base.data_out;
			next_data_out = base.next_data_out;
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
  int dir_map[5]; //north, south, east, west, local
  int b_count, this_x, this_y, this_i, node_index, capture_node[], capture_if[];
  int address[], flit_count[];
  bit req_table[5][3][5]; // buffer, state, req_line
  int popping_int[];
  bit is_sending[];
  int req_s[5];
  fifo buffer[]; //north, south, east, west, local
  out_data od[];
  in_data id[];

  function copy(sim_node base);
    dir_map = base.dir_map;
    b_count = base.b_count;
    this_x = base.this_x;
    this_y = base.this_y;
    this_i = base.this_i;
    node_index = base.node_index;
    capture_node = base.capture_node;
    capture_if = base.capture_if;
    address = base.address;
    flit_count = base.flit_count;
    req_table = base.req_table;
    req_s = base.req_s;
    popping_int = base.popping_int;
    is_sending = base.is_sending;
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
    node_index = `INDEX(x,y) -1;
    `ifdef NOC_MODE
      this_i = `INDEX(x,y) - 1;
    `else
      this_i = 0;
    `endif

    d = _d;

    if(`TOP(y) && `LEFT(x)) begin
      b_count = 3;
      dir_map = '{-1, 0, 1, -1, 2};
    end else if (`TOP(y) && `RIGHT(x)) begin
      b_count = 3;
      dir_map = '{-1, 0, -1, 1, 2};
    end else if (`BOTTOM(y) && `LEFT(x)) begin
      b_count = 3;
      dir_map = '{0, -1, 1, -1, 2};
    end else if (`BOTTOM(y) && `RIGHT(x)) begin
      b_count = 3;
      dir_map = '{0, -1, -1, 1, 2};
    end else if (`TOP(y)) begin
      b_count = 4;
      dir_map = '{-1, 0, 1, 2, 3};
    end else if (`BOTTOM(y)) begin
      b_count = 4;
      dir_map = '{0, -1, 1, 2, 3};
    end else if (`LEFT(x)) begin
      b_count = 4;
      dir_map = '{0, 1, 2, -1, 3};
    end else if (`RIGHT(x)) begin
      b_count = 4;
      dir_map = '{0, 1, -1, 2, 3};
    end else begin
      b_count = 5;
      dir_map = '{0, 1, 2, 3, 4};
    end

    buffer = new[b_count];
    od = new[b_count];
    id = new[b_count];
    address = new[b_count];
    flit_count = new[b_count];
    capture_node = new[b_count-1];
    capture_if = new[b_count-1];
    popping_int = new[b_count];
    is_sending = new[b_count];
    for(int i=0; i<b_count; i++) begin
      buffer[i] = new;
      od[i] = new;
      id[i] = new;
      address[i] = 0;
      flit_count[i] = 0;
    end

    for(int i=0; i<5; i++) begin
      for(int j=0; j<b_count-2;j++) begin
        for(int k=0; k<5; k++) begin
          req_table[i][j][k] = 0;
        end
      end
      req_s[i] = 0; 
    end

    if(`TOP(y) && `LEFT(x)) begin
      capture_node = '{n_south, n_east};
      capture_if = '{`DIR_NORTH, `DIR_WEST};
    end else if (`TOP(y) && `RIGHT(x)) begin
      capture_node = '{n_south, n_west};
      capture_if = '{`DIR_NORTH, `DIR_EAST};
    end else if (`BOTTOM(y) && `LEFT(x)) begin
      capture_node = '{n_north, n_east};
      capture_if = '{`DIR_SOUTH, `DIR_WEST};
    end else if (`BOTTOM(y) && `RIGHT(x)) begin
      capture_node = '{n_north, n_west};
      capture_if = '{`DIR_SOUTH, `DIR_EAST};
    end else if (`TOP(y)) begin
      capture_node = '{n_south, n_east, n_west};
      capture_if = '{`DIR_NORTH, `DIR_WEST, `DIR_EAST};
    end else if (`BOTTOM(y)) begin
      capture_node = '{n_north, n_east, n_west};
      capture_if = '{`DIR_SOUTH, `DIR_WEST, `DIR_EAST};
    end else if (`LEFT(x)) begin
      capture_node = '{n_north, n_south, n_east};
      capture_if = '{`DIR_SOUTH, `DIR_NORTH, `DIR_WEST};
    end else if (`RIGHT(x)) begin
      capture_node = '{n_north, n_south, n_west};
      capture_if = '{`DIR_SOUTH, `DIR_NORTH, `DIR_EAST};
    end else begin
      capture_node = '{n_north, n_south, n_east, n_west};
      capture_if = '{`DIR_SOUTH, `DIR_NORTH, `DIR_WEST, `DIR_EAST};
    end
  endfunction

  function capture();
    //$display("Node %d Capture: ", `INDEX(this_x, this_y));
    for(int i=0; i<b_count-1; i++) begin
      int bid = d.nodes[capture_node[i]-1].get_buffer_id(capture_if[i]);
      //$display("\tInterface: %d", i);
      //$display("\t\tCN: %d", capture_node[i]);
      //$display("\t\tCI: %d", capture_if[i]);
      //$display("\t\tCDM: %d", dm[capture_if[i]]);
      id[i].buffer_full = d.next_nodes[capture_node[i]-1].od[bid].buffer_full;
      id[i].receiving_data = d.next_nodes[capture_node[i]-1].od[bid].sending_data;
      id[i].data_in = d.next_nodes[capture_node[i]-1].od[bid].data_out;
    end
  endfunction

  function send();
    int data_out[] = new[b_count];    
		int next_data_out[] = new[b_count];
    bit requests[5][5];
    int grant[5] = '{-1, -1, -1, -1, -1};

    $display("%0d:: Node %0d Status:", $time, node_index);
    for(int i=0; i<b_count; i++) begin
      $display("\tInterface %0d:", i);
      $display("\t\tDV: %0b", buffer[i].data_valid());
      $display("\t\tBD: %h", buffer[i].data_out());
      $display("\t\tBF: %0b", buffer[i].full());
      $display("\t\tADDR: %h", address[i]);
      $display("\t\tFC: %h", flit_count[i]);
    end

    for(int i=0; i<b_count; i++) begin
      int req_from, req_to;
      req_to = -1;
      req_from = i;

      //$display("Address[%0d] = %0d", i, address[i]);
      if(buffer[i].data_valid() && (address[i][3:0] > `GETY(node_index))) begin
        req_to = get_buffer_id(`DIR_SOUTH);
      end else if(buffer[i].data_valid() && (address[i][3:0] < `GETY(node_index))) begin
        req_to = get_buffer_id(`DIR_NORTH);
      end else if(buffer[i].data_valid() && (address[i][3:0] == `GETY(node_index))) begin
        if(buffer[i].data_valid() && (address[i][7:4] > `GETX(node_index))) begin
          req_to = get_buffer_id(`DIR_EAST);
        end else if(buffer[i].data_valid() && (address[i][7:4] < `GETX(node_index))) begin
          req_to = get_buffer_id(`DIR_WEST);
        end else if(buffer[i].data_valid() && (address[i][7:4] == `GETX(node_index))) begin
          req_to = get_buffer_id(`DIR_LOCAL);
        end
      end

      assert(req_to!=req_from) else $display("Request from and to same interface!");
      
      if (req_to != -1) begin
        $display("%0d Requests %0d", req_from, req_to);
        if(id[req_to].buffer_full) begin
          $display("\tBut buffer is full");
        end
        requests[req_to][req_from] = 1;
      end
    end

    for(int i=0; i<b_count; i++) begin 
      if(!id[i].buffer_full) begin
        if(no_reqs(req_table[i][0])) begin
          grant[i] = get_grant(requests[i]);
        end else begin
          grant[i] = get_grant(req_table[i][0]);
        end
      end 

      if(grant[i] > -1) begin
        $display("Interface %0d Grants %0d", i, grant[i]);
    //    $display("Pointer is at %0d", req_s[i]);

        requests[i][grant[i]] = 0;
        for(int j=0; j<3; j++) begin
         // if(d.next_nodes[this_i].req_table[i][j][grant[i]] == 1) begin
         //   $display("Clearing %0d in Column %0d", grant[i], j);
         // end
          d.next_nodes[this_i].req_table[i][j][grant[i]] = 0;
        end

        if(no_reqs(d.next_nodes[this_i].req_table[i][0])) begin
         // $display("First column is empty");

          if (d.next_nodes[this_i].req_s[i] != 0) begin
           // $display("Decrementing pointer");
            d.next_nodes[this_i].req_s[i]--;
          end
          for(int j=0; j<b_count-3;j++) begin
           // $display("Shift");
            d.next_nodes[this_i].req_table[i][j] = d.next_nodes[this_i].req_table[i][j+1];
          end
        end

        if (no_reqs(requests[i]) == 0) begin
          for(int k=0; k<5; k++) begin
            if(d.next_nodes[this_i].req_table[i][d.next_nodes[this_i].req_s[i]-1][k] != requests[i][k]) begin
             // $display("Adding row");
              d.next_nodes[this_i].req_table[i][d.next_nodes[this_i].req_s[i]] = requests[i];
              d.next_nodes[this_i].req_s[i]++;
              break;
            end
          end
        end
      end

      for(int j=0; j<3; j++) begin
       // $display("[%0d][%0d]: %b%b%b%b%b", i, j, d.next_nodes[this_i].req_table[i][j][0], d.next_nodes[this_i].req_table[i][j][1], d.next_nodes[this_i].req_table[i][j][2], d.next_nodes[this_i].req_table[i][j][3], d.next_nodes[this_i].req_table[i][j][4]);
      end
    end

   /* 
    for(int i=0; i<5; i++) begin
    for(int j=0; j<3; j++) begin
      $display("[%0d][%0d]: %b%b%b%b%b", i, j, d.next_nodes[this_i].req_table[i][j][0], d.next_nodes[this_i].req_table[i][j][1], d.next_nodes[this_i].req_table[i][j][2], d.next_nodes[this_i].req_table[i][j][3], d.next_nodes[this_i].req_table[i][j][4]);
    end
  end
*/
    //$display("Node %0d Outputs:", node_index);

    for(int i=0; i<b_count; i++) begin
      popping_int[i] = 0;
    end

    for(int i=0; i<b_count; i++) begin
      is_sending[i] = 1'b0;
      data_out[i] = buffer[i].data_out();
      next_data_out[i] = buffer[i].next_data_out();

      if(grant[i] > -1) begin
        int temp;
        is_sending[i] = 1'b1;
        temp = d.next_nodes[this_i].buffer[grant[i]].pop();
        popping_int[grant[i]] = 1;
        $display("Popping %0d from B%0d", temp,  grant[i]);
      end
      //$display("\tInterface %0d:", i);
      //$display("\t\tSD: %b", is_sending[i]);
      //$display("\t\tDO%0d: %h",i, data_out[i]);
    end

    $display("%0d:: Node %0d Outputs:", $time, this_i);
    for(int i=0; i<b_count; i++) begin
      d.next_nodes[this_i].od[i].buffer_full = buffer[i].full();
      d.next_nodes[this_i].od[i].sending_data = is_sending[i];
      d.next_nodes[this_i].od[i].data_out = is_sending[i] ? data_out[grant[i]] : 0; //data_out[i];

      $display("\tInterface %0d:", i);
      $display("\t\tBFO: %b", d.next_nodes[this_i].od[i].buffer_full);
      $display("\t\tSD: %0b", d.next_nodes[this_i].od[i].sending_data);
      $display("\t\tDO: %h",  d.next_nodes[this_i].od[i].data_out);
    end
  endfunction

  function receive();
    $display("%0d:: Node %0d Inputs:", $time, node_index);
    for(int i=0; i<b_count; i++) begin
      $display("\tInterface %0d:", i);
      $display("\t\tBFI: %b", id[i].buffer_full);
      $display("\t\tRD: %0b", id[i].receiving_data);
      $display("\t\tDI: %h", id[i].data_in);
    end

    for(int i=0; i<b_count; i++) begin
      if(id[i].receiving_data) begin
        $display("Pushing %h onto B%0d of N%0d", id[i].data_in, i, this_i);
        d.next_nodes[this_i].buffer[i].push(id[i].data_in);
      end
    end

    for(int i=0; i<b_count; i++) begin
      if(flit_count[i] == 0) begin
        if(id[i].receiving_data) begin
         // $display("Address %0d from DI = %h", i, id[i].data_in[7:0]);
          d.next_nodes[this_i].flit_count[i] = id[i].data_in[15:8]+1;
          d.next_nodes[this_i].address[i] = id[i].data_in[7:0];
        end else begin
          d.next_nodes[this_i].flit_count[i] = 0;
        end
      end else if (flit_count[i] == 1) begin
        if(popping_int[i] == 1) begin
          if(d.next_nodes[this_i].buffer[i].data_valid()) begin
            int dout = d.next_nodes[this_i].buffer[i].data_out();
           // $display("Address %0d from NDO = %h", i, dout[7:0]);
            d.next_nodes[this_i].flit_count[i] = dout[15:8]+1;
            d.next_nodes[this_i].address[i] = dout[7:0];
          end else begin
            if(id[i].receiving_data) begin
             // $display("Address %0d from DI = %h", i, id[i].data_in[7:0]);
              d.next_nodes[this_i].flit_count[i] = id[i].data_in[15:8]+1;
              d.next_nodes[this_i].address[i] = id[i].data_in[7:0];
            end else begin
             // $display("Address %0d Kept", i);
              d.next_nodes[this_i].flit_count[i] --;
              d.next_nodes[this_i].address[i] = address[i];
            end
          end
        end else begin
          d.next_nodes[this_i].flit_count[i] = flit_count[i];
          d.next_nodes[this_i].address[i] = address[i];
        end
      end else if (is_sending[i]) begin
        d.next_nodes[this_i].flit_count[i] --;
        d.next_nodes[this_i].address[i] = address[i];
      end else begin
        d.next_nodes[this_i].flit_count[i] = flit_count[i];
        d.next_nodes[this_i].address[i] = address[i];
      end
    end
  endfunction

  function int get_grant(bit reqs[5]);
    for(int i = 0; i < 5; i ++) begin
      if(reqs[i] == 1) begin
        return i;
      end
    end
    return -1;
  endfunction

  function bit no_reqs(bit reqs[5]);
    for(int i = 0; i < 5; i ++) begin
      if(reqs[i] == 1) begin
        return 0;
      end
    end
    return 1;
  endfunction

  function int get_buffer_id(int dir);
    return dir_map[dir];
  endfunction

  function reset();
    for(int i=0; i<b_count; i++) begin
      buffer[i].reset();
      od[i].buffer_full = buffer[i].full();
    end
  endfunction
endclass
