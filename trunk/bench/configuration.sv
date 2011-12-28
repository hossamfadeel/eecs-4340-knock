class configuration;
  rand int unsigned  max_cycles, max_transactions,
                reset_density,
                node_r_density[`INTERFACES], node_s_density[`INTERFACES],
                node_addr_mask_x[`INTERFACES], node_addr_mask_y[`INTERFACES],
                address_mode, heavy_mode, random_mode;

  constraint c_config {
    max_cycles <= 50000;
    max_transactions == 0;
    reset_density <= 10000;
    foreach(node_r_density[i]){
      node_r_density[i] <= 10000;
    }
    foreach(node_s_density[i]){
      node_s_density[i] <= 10000;
    }
    foreach(node_addr_mask_x[i]){
      node_addr_mask_x[i] <= (`NOC_SIZE*`NOC_SIZE) -1;
    }
    foreach(node_addr_mask_y[i]){
      node_addr_mask_y[i] <= (`NOC_SIZE*`NOC_SIZE) -1;
    }
    address_mode <= 1;
  }

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
    
      for(int i = 0; i < `INTERFACES; i++) begin
        int j;

        rval = $fscanf(file, {"node_r_density[", "%d", "] %f"}, j, node_r_density_r[i]);
        rval = $fscanf(file, {"node_s_density[", "%d", "] %f"}, j, node_s_density_r[i]);
        rval = $fscanf(file, {"node_addr_mask_x[", "%d", "] %d"}, j, node_addr_mask_x[i]);
        rval = $fscanf(file, {"node_addr_mask_y[", "%d", "] %d"}, j, node_addr_mask_y[i]);

        node_r_density[i]  = node_r_density_r[i] * 10000;
        node_s_density[i]  = node_s_density_r[i] * 10000;

/*        $display("J: %0d", j);
        $display("Loaded r[%d] = %d", i, node_r_density[i]);
        $display("Loaded s[%d] = %d", i, node_s_density[i]);
        $display("Loaded mask_x[%d] = %d", i, node_addr_mask_x[i]);
        $display("Loaded mask_y[%d] = %d", i, node_addr_mask_y[i]);*/
      end

    rval = $fscanf(file, "address_mode %d",        address_mode);
    rval = $fscanf(file, "heavy_mode %d",          heavy_mode);
    rval = $fscanf(file, "random_mode %d",         random_mode);

    $fclose(file);

    if (random_mode == 1) begin
      this.randomize();
    end
  endfunction
endclass
