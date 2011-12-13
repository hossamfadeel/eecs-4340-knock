class node_transaction extends transaction;
  int node_index;
  int data;

  rand bit buffer_full;
  rand bit sending;
  rand int x, y;

  constraint c_node {
    buffer_full dist { 1 := e.cfg.node_r_density[node_index],
                       0 := (10000 - e.cfg.node_r_density[node_index])};
    sending dist { 1 := e.cfg.node_s_density[node_index],
                   0 := (10000 - e.cfg.node_s_density[node_index])};

    solve x before y;
    x >= 0;
    x <= e.cfg.node_addr_mask_x[node_index];
    y >= 0;
    y <= e.cfg.node_addr_mask_y[node_index];

    `ifdef NOC_MODE
      x == `GETX(node_index) -> y != `GETY(node_index);
    `else
      x == `NODE_X -> y != `NODE_Y;
    `endif
  }

  function new(const ref environment e, int index);
    super.new(e);

    node_index = index;
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

    data = (x << 4) + y;
  endfunction

  function void action();
    `ifdef NOC_MODE
      e.d.nodes[node_index].id[0].buffer_full = buffer_full;
      e.d.nodes[node_index].id[0].receiving_data = sending;
      e.d.nodes[node_index].id[0].data_in = data;
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