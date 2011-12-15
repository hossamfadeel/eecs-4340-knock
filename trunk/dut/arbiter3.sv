module arbiter3
(	
	input clk,
	input rst,	
	input [2:0] request,
	input buffer_full_i,
	output logic [2:0] grant,
	output logic grant_v_o
);

	logic [1:0] req_en;
	logic [2:0] req_i [1:0];
	wire [2:0] req_o [1:0];
	logic [2:0] req_m;
	logic tail_en;
	logic [1:0] tail_i;
	wire [1:0] tail_o;
	logic shift;

	logic [2:0] request_c;

	generate
		for (genvar iter = 0; iter < 2; iter++) begin
			register #(.BITS(3))
				req_record(
				//input
				.clk(clk),
				.enable_i(req_en[iter]),
				.data_i(req_i[iter]),
				.reset(rst),

				//out
				.data_o(req_o[iter])
		
				);
		end

		for (iter = 0; iter < 2; iter++) begin
			register  #(.BITS(1))
				tail(
					//input
					.clk(clk),
					.enable_i(tail_en),
					.data_i(tail_i[iter]),
					.reset(rst),
		
		
					//out
					.data_o(tail_o[iter])
		
					);
		end
	endgenerate


	always_comb begin
		if (!buffer_full_i & (request!=0)) begin
			
			if(tail_o==0) begin

				case(request)
				1:	begin
					grant_v_o=1;
					grant=3'b001;
					tail_en=0;
					req_en=0;
				end
				2:	begin
					grant_v_o=1;
					grant=3'b010;
					tail_en=0;
					req_en=0;
				end
				3:	begin
					grant_v_o=1;
					grant=3'b001;
					tail_en=1;
					tail_i=2'b01;
					req_en=2'b01;
					req_i[0]=3'b010;
				end
				4:	begin
					grant_v_o=1;
					grant=3'b100;
					tail_en=0;
				end
				5:	begin
					grant_v_o=1;
					grant=3'b001;
					tail_en=1;
					tail_i=2'b01;
					req_en=2'b01;
					req_i[0]=3'b100;
				end				
				6:	begin
					grant_v_o=1;
					grant=3'b010;
					tail_en=1;
					tail_i=2'b01;
					req_en=2'b01;
					req_i[0]=3'b100;
				end				
				7:	begin
					grant_v_o=1;
					grant=3'b001;
					tail_en=1;
					tail_i=2'b01;
					req_en=2'b01;
					req_i[0]=3'b110;
				end				
				default:	begin
					grant_v_o=0;
					tail_en=0;
					req_en=0;
				end
				endcase

			end

			else begin			
				shift=(req_o[0]==1|req_o[0]==2|req_o[0]==4) ? 1 : 0;
				grant_v_o=1;
				request_c=request & (!grant);
				
				if (shift) begin

				//tail_o cannot be 0 in this case
					if (tail_o==2) begin
						req_i[0]=req_o[1] & !grant;
						if (request_c==0) begin
							req_en=2'b01;
							tail_i=2'b01;
							tail_en=1;
						end
						else begin
							tail_en=0;
							req_en=2'b11;
							req_i[1]=request_c;
						end
					end
					else begin
						if (request_c==0) begin
							req_en=2'b00;
							tail_i=2'b00;
							tail_en=1;
						end
						else begin
							tail_en=0;
							req_en=2'b01;
							req_i[0]=request_c;
						end
					end

					case(req_o[0])
					1:	begin
						grant=3'b001;
					end
					2:	begin
						grant=3'b010;
					end
					4:	begin
						grant=3'b100;
					end
					default:	begin
						grant=3'b000;
					end	
					endcase			
				
				end
				else begin
					tail_en=1;
				//tail_o cannot be 2 or 0 in this case

					req_i[0]=req_m;
					req_i[1]=request_c & (!req_m);
					tail_en=1;
					tail_i=2'b10;
					req_en=2'b11;

					case(req_o[0])
					3:	begin
						grant=3'b001;
						req_m=3'b010;
					end
					5:	begin
						grant=3'b001;
						req_m=3'b100;
					end				
					6:	begin
						grant=3'b010;
						req_m=3'b100;
					end				
					7:	begin
						grant=3'b001;
						req_m=3'b110;
					end								
					default:	begin
						grant=3'b000;
						req_m=3'b000;
					end
					endcase
				end				
			end
		end
		else begin
			grant_v_o=0;
			grant=3'b000;
			tail_en=0;
			req_en=0;
		end		
	end

endmodule

