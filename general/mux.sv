module mux #(
  parameter WIDTH = 16
)
(
  input [WIDTH-1:0] data0;
  input [WIDTH-1:0] data1;
  input [WIDTH-1:0] data2;
  input [WIDTH-1:0] data3;

  input select0, select1, select2, select3;
  output logic [WIDTH-1:0] data_o;

);

always @(posedge clk) begin
  case({select0,select1,select2,select3})
    4'b1000: data_o = data0;
    4'b0100: data_o = data1;
    4'b0010: data_o = data2;
    4'b0001: data_o = data3;
    default: data_o = 16'b0;
  endcase
end

endmodule
