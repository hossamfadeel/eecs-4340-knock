module mux3_1 #(
  parameter WIDTH = 16
)
(
  input [WIDTH-1:0] data0,
  input [WIDTH-1:0] data1,
  input [WIDTH-1:0] data2,

  input select0, select1, select2,
  output logic [WIDTH-1:0] data_o

);

  always_comb begin
    case({select2,select1,select0})
      4'b100: data_o = data2;
      4'b010: data_o = data1;
      4'b001: data_o = data0;
      default: data_o = {WIDTH{1'b0}};
    endcase
  end

endmodule
