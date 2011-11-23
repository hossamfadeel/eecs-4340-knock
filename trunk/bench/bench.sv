program automatic bench (
  clock_interface.bench clk,
  reset_interface.bench reset,
  node_interface.bench local_node [1:16] 
);
  environment env;

  initial begin
    env = new();

    reset.cb.reset <= 1;
    @(clk.cb);

    repeat (env.cfg.max_cycles) begin
      env.gen();

      reset.cb.reset <= env.rst.reset;

      @(clk.cb);
      env.check();

      env.shift();
    end
    
    env.t.done();
    $finish;
  end
endprogram
