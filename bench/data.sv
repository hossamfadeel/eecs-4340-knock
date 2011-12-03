class data;
  sim_node nodes[`NODE_COUNT];
  sim_node next_nodes[`NODE_COUNT];

  function new();
    `ifdef NODE_TYPE0
      for(int i = 0; i<`NODE_COUNT;i++) begin
        nodes[i] = new(3);
        next_nodes[i] = new(3);
      end
    `else
        nodes[0] = new(`INTERFACES);
        next_nodes[0] = new(`INTERFACES);
    `endif
  endfunction

  function reset();
      for(int i = 0; i<`NODE_COUNT;i++) begin
        next_nodes[i].reset();
      end
  endfunction

  function shift();
    for(int i = 0; i<`NODE_COUNT;i++) begin
      nodes[i] = next_nodes[i];
    end
  endfunction
endclass
