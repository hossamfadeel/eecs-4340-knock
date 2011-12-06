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
    x >= 0;
    x <= e.cfg.node_addr_mask_x[node_index];
    y >= 0;
    y <= e.cfg.node_addr_mask_y[node_index];
  }

  function new(const ref environment e, int index);
    super.new(e);

    node_index = index;
  endfunction

  function void post_randomize();
    super.post_randomize();

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
