module flip_flop
		(
			//input
			input clk,
			input data_i,
			input reset,
			
			
			//out
			output data_o
			
			);

			reg data_reg;
	
			always_ff @(posedge clk)
				begin
					if(reset)
						begin
							data_reg <= 1'b0;
						end
					else 
						begin
							data_reg <= data_i;
						end
				end

endmodule
