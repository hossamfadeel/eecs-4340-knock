class reset_transaction extends transaction;
  rand bit reset;
  constraint c_reset {
    reset dist { 1 := e.cfg.reset_density,
                 0 := (10000 - e.cfg.reset_density)};
  }

  function new(const ref environment e);
    super.new(e);
  endfunction

  function void do_reset();
    reset = 1;
    action();
  endfunction

  function void action();
    if (reset == 0) return;

    e.t.perform("reset", "Resetting...");
    e.d.reset();
  endfunction

  function void check();
  endfunction
endclass
