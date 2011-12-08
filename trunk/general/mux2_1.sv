module mux #(
  parameter WIDTH = 16
)
(
  input [WIDTH-1:0] data0,
  input [WIDTH-1:0] data1,

  input select0, select1,
  output logic [WIDTH-1:0] data_o

);

always begin
  case({select1,select0})
    4'b10: data_o = data1;
    4'b01: data_o = data0;
    default: data_o = 16'b0;
  endcase
end

endmodule
