program automatic dccl_bench (
  input clk,

  output reg [3:0] packet_addr_y_i,
  output reg [3:0] packet_addr_x_i,
  output reg [3:0] local_addr_y_i,
  output reg [3:0] local_addr_x_i,
  output reg packet_valid_i,
  
  input north_req,
  input east_req,
  input south_req,
  input west_req,
  input local_req

);
  bit ex_n, ex_e, ex_s, ex_w, ex_l;
  int fails, total;

  initial begin
    fails = 0;
    total = 0;

    for(int node_i = 0; node_i < 16; node_i++) begin
      local_addr_y_i = `GETY(node_i);
      local_addr_x_i = `GETX(node_i);
      for(int p_i = 0; p_i < 16; p_i++) begin
        if (node_i != p_i) begin
          packet_addr_y_i = `GETY(p_i);
          packet_addr_x_i = `GETX(p_i);
          packet_valid_i  = 1'b1;
        end else begin
          packet_valid_i  = 1'b0;
        end

        ex_n = 1'b0;
        ex_e = 1'b0;
        ex_s = 1'b0;
        ex_w = 1'b0;
        ex_l = 1'b0;

        if(packet_valid_i && (`GETY(p_i) > `GETY(node_i))) begin
          ex_s = 1'b1;
        end else if(packet_valid_i && (`GETY(p_i) < `GETY(node_i))) begin
          ex_n = 1'b1;
        end else if(packet_valid_i && (`GETY(p_i) == `GETY(node_i))) begin
          if(packet_valid_i && (`GETX(p_i) > `GETX(node_i))) begin
            ex_e = 1'b1;
          end else if(packet_valid_i && (`GETX(p_i) < `GETX(node_i))) begin
            ex_w = 1'b1;
          end else if(packet_valid_i && (`GETX(p_i) == `GETX(node_i))) begin
            ex_l = 1'b1;
          end
        end

        @(posedge clk);

        total++;
        if(ex_n != north_req ||
           ex_s != south_req ||
           ex_w != west_req ||
           ex_e != east_req ||
           ex_l != local_req) begin

          $display("Local %0d,%0d : Packet %0d,%0d", `GETX(node_i), `GETY(node_i), `GETX(p_i), `GETY(p_i));
          $display("North Expected: %b, Received: %b", ex_n, north_req);
          $display("South Expected: %b, Received: %b", ex_s, south_req);
          $display("West Expected: %b, Received: %b", ex_w, west_req);
          $display("East Expected: %b, Received: %b", ex_e, east_req);
          $display("Local Expected: %b, Received: %b", ex_l, local_req);

          fails++;
        end
      end
    end

    $display("==================================");
    $display("Fails: %0d", fails);
    $display("Total: %0d", total);
  end
endprogram
