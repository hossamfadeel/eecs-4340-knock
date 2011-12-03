class fifo;
  int data[5];
  bit valid[5];
  int read_index, write_index;
  bit is_full;

  function new();
    reset();
  endfunction

  function reset();
    read_index = 0;
    write_index = 0;
    is_full = 0;
    for(int i=0; i<5; i++) begin
      valid[i] = 0;
    end
  endfunction

  function push(int d);
    valid[write_index] = 1;
    data[write_index] = d;
    write_index = inc(write_index);
    
    if(read_index == write_index) begin
      is_full = 1;
    end
  endfunction

  function int pop();
    int temp;
    temp = data[read_index];
    valid[read_index] = 0;
    read_index = inc(read_index);
    is_full = 0;
    return temp;
  endfunction

  function bit full();
    return is_full;
  endfunction

  function int inc(int i);
    if(i == 4) begin
      return 0;
    end else begin
      return i + 1;
    end
  endfunction

  function int data_out();
    return data[read_index];
  endfunction

  function int data_valid();
    return valid[read_index];
  endfunction
endclass
