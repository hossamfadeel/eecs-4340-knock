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

    reset.cb.reset <= 1'b1;
    @(clk.cb);
    reset.cb.reset <= 1'b1;
    @(clk.cb);

    if(env.cfg.max_transactions > 0) begin 
      while(env.transaction_count < env.cfg.max_transactions) begin
        loop_task();
      end
      $display("Max Transactions Reached");
    end else begin
      repeat (env.cfg.max_cycles) begin
        loop_task();
      end
    end
    
    env.t.done();
    $finish;
  end

  task loop_task();
    env.gen();
  
    reset.cb.reset <= env.rst.reset;
    for(int i = 1; i<=`INTERFACES; i++) begin
      vnode[i].cb.buffer_full_in <= env.in_data[i-1].buffer_full;
      vnode[i].cb.receiving_data <= env.in_data[i-1].sending;
      vnode[i].cb.data_in <= env.in_data[i-1].data;
    end
  
    @(clk.cb);
    for(int i = 1; i<=`INTERFACES; i++) begin
      env.check(i,
                vnode[i].cb.buffer_full_out,
                vnode[i].cb.sending_data,
                vnode[i].cb.data_out
               );
    end
  
    env.shift();
  endtask
endprogram

