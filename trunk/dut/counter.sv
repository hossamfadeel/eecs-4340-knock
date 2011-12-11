module counter#(parameter ADD_WIDTH = 8)
(
	input clk,
	input reset,
	input [ADD_WIDTH-1:0] flit_length,
	input count_enable,
	output logic is_address
	//output logic [ADD_WIDTH-1:0] cc_o
);

  logic [ADD_WIDTH-1:0] next_count;
  logic [ADD_WIDTH-1:0] current_count;

  always_comb begin
    if(reset) begin
      next_count = 0;
    end else if(count_enable == 1'b1) begin
      next_count = flit_length;
    end else if(current_count != 0) begin
      next_count = current_count - 1'b1;
    end

    if(current_count == 0) begin
      is_address = 1'b1;
    end else begin
      is_address =1'b0;
    end
  end

  register #(.BITS(ADD_WIDTH)) count_reg (
    .clk(clk),
    .reset(reset),
    .enable_i(count_enable),
    .data_i(next_count),
    .data_o(current_count)			
  );
endmodule
