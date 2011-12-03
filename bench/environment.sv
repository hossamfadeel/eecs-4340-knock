class environment;
  data d;
  configuration cfg;
  tracker t;
  reset_transaction rst;

  function new();
    d = new();
    cfg = new();
    t = new();

    rst = new(this);
  endfunction

  function gen();
    rst.randomize();

    if(rst.reset) begin
      rst.action(); 
    end
  endfunction

  function check(int i, bit bf, bit sd, int data_out);
    `ifdef NODE_TYPE0

    `else
      if(d.nodes[0].od[i-1].buffer_full == bf &&
         d.nodes[0].od[i-1].sending_data == sd &&
         d.nodes[0].od[i-1].data_out == data_out) begin
        t.pass();
      end else begin
        t.fail("");
      end
    `endif
  endfunction

  function shift();
    d.shift();
  endfunction
endclass
