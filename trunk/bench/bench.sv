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

    reset.cb.reset <= 1'b0;
    @(clk.cb);

    repeat (env.cfg.max_cycles) begin
      env.gen();

      reset.cb.reset <= ~env.rst.reset;
      for(int i = 1; i<=`INTERFACES; i++) begin
        vnode[i].cb.receiving_data <= 1'b1;
        vnode[i].cb.data_in <= 1'b0;
      end

      @(clk.cb);
      for(int i = 1; i<=`INTERFACES; i++) begin
        env.check(i,
                  vnode[i].cb.buffer_full_out,
                  vnode[i].cb.sending_data,
                  vnode[i].cb.data_out
                 );
        //$display("Node Out %h: %d", i, vnode[i].cb.data_out);
        //$display("Full Out %h: %d", i, vnode[i].cb.buffer_full_out);
      end

      env.shift();
    end
    
    env.t.done();
    $finish;
  end
endprogram
