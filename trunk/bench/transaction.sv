typedef class environment;

virtual class transaction;
  environment e;
  string outString = "";

  function new(const ref environment _env);
    e = _env;
  endfunction

  virtual function void action();
  endfunction
endclass
