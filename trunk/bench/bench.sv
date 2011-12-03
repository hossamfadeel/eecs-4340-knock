program automatic bench (
  clock_interface.bench clk,
  reset_interface.bench reset,
  node_interface.bench node [1:`INTERFACES] 
);
  environment env;
  virtual interface node_interface.bench vnode[1:`INTERFACES];

  initial begin
    env = new();
    vnode = node;

    reset.cb.reset <= 1;
    @(clk.cb);

    repeat (env.cfg.max_cycles) begin
      env.gen();

      reset.cb.reset <= env.rst.reset;

      @(clk.cb);
      for(int i = 1; i<=`INTERFACES; i++) begin
        env.check(i,
                  vnode[i].cb.buffer_full_out,
                  vnode[i].cb.sending_data,
                  vnode[i].cb.data_out
                 );
      end

      env.shift();
    end
    
    env.t.done();
    $finish;
  end
endprogram
