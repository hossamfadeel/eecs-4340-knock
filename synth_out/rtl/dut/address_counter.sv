module address_counter#(parameter ADD_WIDTH = 8)
(
  input clk,
  input rst,
  input [ADD_WIDTH-1:0] interface_flit_length,
  input [ADD_WIDTH-1:0] buffer_flit_length,
  input buffer_data_valid,
  input [7:0] interface_flit_address,
  input [7:0] buffer_flit_address,  
  input buffer_pop,
  input receiving_data,

  output [7:0] flit_address_o

  //testing
  //output [ADD_WIDTH-1:0] nc_o,
  //output [ADD_WIDTH-1:0] cc_o, 
  //output count_done,
  //output [7:0] mod_flit_add

);

  logic [ADD_WIDTH-1:0] next_count;
  wire [ADD_WIDTH-1:0] current_count;
  logic is_address;

  logic [7:0] flit_address;
  logic  count_enable;
  
  //assign cc_o = current_count;
  //assign nc_o = next_count;
  //assign count_done = is_address;
  //assign mod_flit_add = flit_address;


  always_comb begin
    next_count = current_count;
    flit_address = flit_address_o;
    count_enable = 1'b0;
    is_address = 1'b0;

    if(rst) begin
      next_count = 0;
      flit_address = 0;
      count_enable = 0;
      is_address = 0;
    end else begin
    //LOAD FUNCTION
    if(current_count == 0) begin
      if(receiving_data) begin
        next_count = interface_flit_length+1;
        flit_address = interface_flit_address;
        count_enable = 1'b1;
        is_address =1'b1;
      end
    end else if(current_count == 1) begin
      if(buffer_pop && buffer_data_valid) begin //buffer has the next flit head
        next_count = buffer_flit_length+1;
        flit_address = buffer_flit_address;
        count_enable = 1'b1;
        is_address =1'b1;
      end else if(buffer_pop && receiving_data) begin //buffer has last data flit and new flip head is coming in from interface
        next_count = interface_flit_length+1;
        flit_address = interface_flit_address;
        count_enable = 1'b1;
        is_address =1'b1;
      end else begin //no new data
        if(buffer_pop) begin
          next_count = current_count -1'b1;
          count_enable = 1'b1;
          flit_address = 0;
          is_address =1'b0;
        end else begin
          next_count = current_count;
          count_enable = 1'b0;
          flit_address = 0;
          is_address =1'b0;
        end
      end
    end else begin //current_count greater than 1
      if(buffer_pop) begin
        next_count = current_count - 1'b1;
        count_enable = 1'b1;
        is_address =1'b0;
      end else begin
        count_enable =1'b0;
        next_count = current_count;
        is_address =1'b0;
      end    
    end
  end
  end

  register #(.BITS(ADD_WIDTH)) count_reg (
    .clk(clk),
    .reset(rst),
    .enable_i(count_enable),
    .data_i(next_count),
    .data_o(current_count)      
  );

  register #(.BITS(4'd8)) address_reg (
    .clk(clk),
    .reset(rst),
    .enable_i(is_address),
    .data_i(flit_address),
    .data_o(flit_address_o)      
  );



endmodule
