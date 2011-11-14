class configuration;
  int unsigned max_cycles, density_reset;

  real density_reset_r;

  function new();
    int rval;
    int file = $fopen("bench/params.cfg", "r");

    rval = $fscanf(file, "max_cycles %d",         max_cycles);
    rval = $fscanf(file, "density_reset %f",      density_reset_r);

    $fclose(file);

    density_reset  = density_reset_r * 10000;
  endfunction
endclass
