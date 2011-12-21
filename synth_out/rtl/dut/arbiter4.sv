module arbiter4
(	
	input clk,
	input rst,	
	input [3:0] request,
	input buffer_full_i,
	output logic [3:0] grant,
	output logic grant_v_o
);

	logic [2:0] req_en;
	logic [3:0] req_i [2:0];
	wire [3:0] req_o [2:0];
	logic [3:0] req_m;
	logic tail_en;
	logic [1:0] tail_i;
	wire [1:0] tail_o;
	logic shift;

	logic [3:0] request_c;

	generate
		for (genvar iter = 0; iter < 3; iter++) begin
			register #(.BITS(4))
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
					grant=4'b0001;
					tail_en=0;
					req_en=0;
				end
				2:	begin
					grant_v_o=1;
					grant=4'b0010;
					tail_en=0;
					req_en=0;
				end
				3:	begin
					grant_v_o=1;
					grant=4'b0001;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b0010;
				end
				4:	begin
					grant_v_o=1;
					grant=4'b0100;
					tail_en=0;
				end
				5:	begin
					grant_v_o=1;
					grant=4'b0001;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b0100;
				end				
				6:	begin
					grant_v_o=1;
					grant=4'b0010;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b0100;
				end				
				7:	begin
					grant_v_o=1;
					grant=4'b0001;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b0110;
				end				
				8:	begin
					grant_v_o=1;
					grant=4'b1000;
					tail_en=0;
					req_en=0;
				end				
				9:	begin
					grant_v_o=1;
					grant=4'b0001;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b1000;
				end
				10:	begin
					grant_v_o=1;
					grant=4'b0010;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b1000;
				end
				11:	begin
					grant_v_o=1;
					grant=4'b0001;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b1010;
				end
				12:	begin
					grant_v_o=1;
					grant=4'b0100;
					tail_en=1;
					tail_i=2'b01;
					tail_i=tail_o+shift;
					req_en=3'b001;
					req_i[0]=4'b1000;
				end
				13:	begin
					grant_v_o=1;
					grant=4'b0001;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b1100;
				end
				14:	begin
					grant_v_o=1;
					grant=4'b0010;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b1100;
				end
				15:	begin
					grant_v_o=1;
					grant=4'b0001;
					tail_en=1;
					tail_i=2'b01;
					req_en=3'b001;
					req_i[0]=4'b1110;
				end
				default:	begin
					grant_v_o=0;
					tail_en=0;
					req_en=0;
				end
				endcase

			end

			else begin			
				shift=(req_o[0]==1|req_o[0]==2|req_o[0]==4|req_o[0]==8) ? 1 : 0;
				grant_v_o=1;
				
				if (shift) begin

					case(req_o[0])
					1:	begin
						grant=4'b0001;
					end
					2:	begin
						grant=4'b0010;
					end
					4:	begin
						grant=4'b0100;
					end
					8:	begin
						grant=4'b1000;
					end
					default:	begin
						grant=4'b0000;
					end	
					endcase	

					request_c=request & (~grant);

				//tail_o cannot be 0 in this case
					if (tail_o==3) begin
						req_i[0]=req_o[1] & ~grant;
						req_i[1]=req_o[2] & ~grant;
						if (request_c==0 | request_c == req_i[0] |  request_c == req_i[1]) begin
							if (req_i[0] == req_i[1]) begin
								req_en=3'b001;
								tail_i=2'b01;
								tail_en=1;
							end
							else begin
								req_en=3'b011;
								tail_i=2'b10;
								tail_en=1;
							end
						end
						else begin
							if (req_i[0] == req_i[1]) begin
								req_en=3'b011;
								tail_i=2'b10;
								tail_en=1;
								req_i[1]=request_c;
							end
							else begin
								req_en=3'b111;
								req_i[2]=request_c;
								tail_en=0;
							end
						end
					end
					else if (tail_o==2) begin
						req_i[0]=req_o[1] & ~grant;
						if (request_c==0 | request_c == req_i[0]) begin
							req_en=3'b001;
							tail_i=2'b01;
							tail_en=1;
						end
						else begin
							tail_en=0;
							req_en=3'b011;
							req_i[1]=request_c;
						end
					end
					else begin
						if (request_c==0 | request_c == req_o[0]) begin
							req_en=3'b000;
							tail_i=2'b00;
							tail_en=1;
						end
						else begin
							tail_en=0;
							req_en=3'b001;
							req_i[0]=request_c;
						end
					end				
				end
				else begin
					case(req_o[0])
					3:	begin
						grant=4'b0001;
						req_m=4'b0010;
					end
					5:	begin
						grant=4'b0001;
						req_m=4'b0100;
					end				
					6:	begin
						grant=4'b0010;
						req_m=4'b0100;
					end				
					7:	begin
						grant=4'b0001;
						req_m=4'b0110;
					end								
					9:	begin
						grant=4'b0001;
						req_m=4'b1000;
					end
					10:	begin
						grant=4'b0010;
						req_m=4'b1000;
					end
					11:	begin
						grant=4'b0001;
						req_m=4'b1010;
					end
					12:	begin
						grant=4'b0100;
						req_m=4'b1000;
					end
					13:	begin
						grant=4'b0001;
						req_m=4'b1100;
					end
					14:	begin
						grant=4'b0010;
						req_m=4'b1100;
					end
					15:	begin
						grant=4'b0001;
						req_m=4'b1110;
					end
					default:	begin
						grant=4'b0000;
						req_m=4'b0000;
					end
					endcase
					
					request_c=request & (~grant);
				//tail_o cannot be 3 or 0 in this case
					if (tail_o==2) begin
						req_i[0]=req_m;
						req_i[1]=req_o[1] & (~grant) & (~req_m);
						req_i[2]=request_c & (~req_m);
                        if (req_i[2] > 0 & req_i[1] > 0) begin
						  	if (req_i[2] != req_i[1]) begin
							  tail_en=1;
							  tail_i=2'b11;
							  req_en=3'b111;
							end
							else begin
                          	  tail_en=0;
                          	  req_en=3'b011;
							end
                        end
                        else if (req_i[2] == 0 & req_i[1] > 0) begin
                          tail_en=0;
                          req_en=3'b011;
                        end
                        else if (req_i[2] > 0 & req_i[1] == 0) begin
                          tail_en=0;
                          req_en=3'b011;
						  req_i[1]=req_i[2];
                        end
						else begin
						  tail_en=1;
						  tail_i=2'b01;
						  req_en=3'b001;
						end
					end
					else begin
						req_i[0]=req_m;
						req_i[1]=request_c & (~req_m);
                        if (req_i[1] > 0) begin
						  tail_en=1;
						  tail_i=2'b10;
						  req_en=3'b011;
                        end
                        else begin
                          tail_en=0;
                          req_en=3'b001;
                        end
					end
				end				
			end
		end
		else begin
			grant_v_o=0;
			grant=4'b0000;
			tail_en=0;
			req_en=0;
		end		
	end

endmodule

