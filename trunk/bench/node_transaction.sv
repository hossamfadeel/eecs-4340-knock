class node_transaction extends transaction;
  int from;
  int node_index;
  int data;
  int current_bytes;

  rand bit buffer_full;
  rand bit sending;
  rand int x, y;
  rand int bytes;
  rand int packet_data;

  constraint c_node {
    buffer_full dist { 1 := e.cfg.node_r_density[node_index],
                       0 := (10000 - e.cfg.node_r_density[node_index])};
    e.cfg.heavy_mode == 1'b1 -> buffer_full == 0;

    sending dist { 1 := e.cfg.node_s_density[node_index],
                   0 := (10000 - e.cfg.node_s_density[node_index])};
    e.cfg.heavy_mode == 1 -> sending == 1;

    bytes >= 0;
    bytes < 4;//2**8;
    e.cfg.address_mode == 0 -> bytes == 0;

    packet_data >= 0;
    packet_data < 2**16;

    solve x before y;
    x >= 0;
    x <= e.cfg.node_addr_mask_x[node_index];
    x < `NOC_SIZE;
    y >= 0;
    y <= e.cfg.node_addr_mask_y[node_index];
    y < `NOC_SIZE;


    `ifdef NOC_MODE
      x != `GETX(node_index) || y != `GETY(node_index);
    `else
      from == -1 -> x != `NODE_X || y != `NODE_Y;
      from > -1 -> x != `GETX(from) || y != `GETY(from);
      from > -1 && from == `INDEX(`NODE_X-1, `NODE_Y)-1 -> y == `GETY(from) && x > `GETX(from);
      from > -1 && from == `INDEX(`NODE_X+1, `NODE_Y)-1 -> y == `GETY(from) && x < `GETX(from) ;
      from > -1 && from == `INDEX(`NODE_X, `NODE_Y+1)-1 -> y < `GETY(from);
      from > -1 && from == `INDEX(`NODE_X, `NODE_Y-1)-1 -> y > `GETY(from);
    `endif
  }

  function new(const ref environment e, int index, int from_index);
    super.new(e);

    node_index = index;
    current_bytes = 0;
    from = from_index;
  endfunction

  function void post_randomize();
    super.post_randomize();

    `ifdef NOC_MODE
      if(e.d.nodes[node_index].buffer[0].full()) begin
    `else
      if(e.d.nodes[0].buffer[node_index].full()) begin
    `endif
        sending = 0;
      end

    if (sending) begin
      e.transaction_count++;
    end

    if (current_bytes == 0) begin
      data = (bytes << 8) + (x << 4) + y;
      current_bytes = bytes;
    end else begin
      data = packet_data;
      if(sending) begin
        current_bytes--;
      end
    end
  endfunction

  function void action();
    `ifdef NOC_MODE
      int bid = e.d.nodes[node_index].get_buffer_id(`DIR_LOCAL);

      e.d.nodes[node_index].id[bid].buffer_full = buffer_full;
      e.d.nodes[node_index].id[bid].receiving_data = sending;
      e.d.nodes[node_index].id[bid].data_in = data;
      e.d.nodes[node_index].capture();
    `else
      e.d.nodes[0].id[node_index].buffer_full = buffer_full;
      e.d.nodes[0].id[node_index].receiving_data = sending;
      e.d.nodes[0].id[node_index].data_in = data;
    `endif
  endfunction

  function void check();
  endfunction
endclass
