class data;
  sim_node nodes[`NODE_COUNT];
  sim_node next_nodes[`NODE_COUNT];

  function new();
    `ifdef NOC_MODE
      for(int x = 0; x<`NOC_SIZE;x++) begin
        for(int y = 0; y<`NOC_SIZE;y++) begin
          nodes[x + y*`NOC_SIZE] = new(this, x, y);
          next_nodes[x + y*`NOC_SIZE] = new(this, x, y);
        end
      end
    `else
      nodes[0] = new(this, `NODE_X, `NODE_Y);
      next_nodes[0] = new(this, `NODE_X, `NODE_Y);
    `endif
  endfunction

  function reset();
      for(int i = 0; i<`NODE_COUNT;i++) begin
        next_nodes[i].reset();
      end
  endfunction

  function shift();
    for(int i = 0; i<`NODE_COUNT;i++) begin
      nodes[i].copy(next_nodes[i]);
    end
  endfunction
endclass
