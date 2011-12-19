module arbiter2
(	
	input clk,
	input rst,	
	input [1:0] request,
	input buffer_full_i,
	output logic [1:0] grant,
	output logic grant_v_o
);

	logic req_en;
	logic [1:0] req_i;
	wire [1:0] req_o;
	logic [1:0] req_m;
	logic tail_en;
	logic tail_i;
	wire tail_o;

	logic [1:0] request_c;

	register #(.BITS(2))
		req_record(
		//input
		.clk(clk),
		.enable_i(req_en),
		.data_i(req_i),
		.reset(rst),

		//out
		.data_o(req_o)

		);

	register  #(.BITS(1))
		tail(
			//input
			.clk(clk),
			.enable_i(tail_en),
			.data_i(tail_i),
			.reset(rst),


			//out
			.data_o(tail_o)

			);


	always_comb begin
		if (!buffer_full_i & (request!=0)) begin
			
			if(tail_o==0) begin

				case(request)
				1:	begin
					grant_v_o=1;
					grant=2'b01;
					tail_en=0;
					req_en=0;
				end
				2:	begin
					grant_v_o=1;
					grant=2'b10;
					tail_en=0;
					req_en=0;
				end
				3:	begin
					grant_v_o=1;
					grant=2'b01;
					tail_en=1;
					tail_i=1'b1;
					req_en=1'b1;
					req_i=2'b10;
				end
				default:	begin
					grant_v_o=0;
					grant=2'b00;
					tail_en=0;
					req_en=0;
				end
				endcase

			end

			else begin			
				grant_v_o=1;

				case(req_o)
				1:	begin
					grant=2'b01;
				end
				2:	begin
					grant=2'b10;
				end
				3:	begin
					grant=2'b01;
				end
				default:	begin
					grant=2'b00;
				end	
				endcase			

                                request_c = request & (!grant);

				if (req_o==1 | req_o==2) begin
					if (request_c==0) begin
						req_en=1'b0;
						tail_i=1'b0;
						tail_en=1;
					end
					else begin
						tail_en=0;
						req_en=1'b1;
						req_i=request_c;
					end
				end
				else begin
					req_en=1'b1;
					req_i=request_c;
					tail_i=1'b1;
					tail_en=1;
				end
			end
		end
		else begin
			grant_v_o=0;
			grant=2'b00;
			tail_en=0;
			req_en=0;
		end		
	end

endmodule

