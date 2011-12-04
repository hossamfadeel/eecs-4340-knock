class configuration;
  int unsigned  max_cycles, max_transactions,
                reset_density,
                local_r_density, local_s_density,
                local_addr_mask_x, local_addr_mask_y,
                node_r_density[`INTERFACES], node_s_density[`INTERFACES],
                node_addr_mask_x[`INTERFACES], node_addr_mask_y[`INTERFACES],
                address_mode, heavy_mode, random_mode;

  real reset_density_r;
  real local_r_density_r, local_s_density_r;
  real node_r_density_r[`INTERFACES], node_s_density_r[`INTERFACES];

  function new();
    int rval;
    int file = $fopen(`PARAMS, "r");

    rval = $fscanf(file, "max_cycles %d",         max_cycles);
    rval = $fscanf(file, "max_transactions %d",         max_transactions);
    rval = $fscanf(file, "reset_density %f",      reset_density_r);

    reset_density  = reset_density_r * 10000;
    
    `ifndef NOC_MODE 
      rval = $fscanf(file, "local_r_density %f",  local_r_density_r);
      rval = $fscanf(file, "local_s_density %f",  local_s_density_r);
      rval = $fscanf(file, "local_addr_mask_x %d",  local_addr_mask_x);
      rval = $fscanf(file, "local_addr_mask_y %d",  local_addr_mask_y);

      local_r_density  = local_r_density_r * 10000;
      local_s_density  = local_s_density_r * 10000;
    `endif

    `ifdef NOC_MODE
      for(int i = 0; i < `NOC_SIZE*`NOC_SIZE; i++) begin
    `else
      for(int i = 0; i < `INTERFACES - 1; i++) begin
    `endif
        int j;

        rval = $fscanf(file, {"node_r_density[", "%d", "] %f"}, j, node_r_density_r[i]);
        rval = $fscanf(file, {"node_s_density[", "%d", "] %f"}, j, node_s_density_r[i]);
        rval = $fscanf(file, {"node_addr_mask_x[", "%d", "] %d"}, j, node_addr_mask_x[i]);
        rval = $fscanf(file, {"node_addr_mask_y[", "%d", "] %d"}, j, node_addr_mask_y[i]);

        node_r_density[i]  = node_r_density_r[i] * 10000;
        node_s_density[i]  = node_s_density_r[i] * 10000;
      end

    rval = $fscanf(file, "address_mode %d",        address_mode);
    rval = $fscanf(file, "heavy_mode %d",          heavy_mode);
    rval = $fscanf(file, "random_mode %d",         random_mode);

    $fclose(file);

  endfunction
endclass
