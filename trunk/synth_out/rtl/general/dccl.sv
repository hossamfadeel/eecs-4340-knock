module dccl(
input [3:0] packet_addr_y_i,
input [3:0] packet_addr_x_i,
input [3:0] local_addr_y_i,
input [3:0] local_addr_x_i,
input packet_valid_i,

output logic north_req,
output logic east_req,
output logic south_req,
output logic west_req,
output logic local_req
);


wire x_le;
wire x_gt;
wire y_le;
wire y_gt;
logic y_equal;
logic x_equal;


always_comb begin


	if(packet_addr_y_i == local_addr_y_i) begin
		y_equal = 1'b1;
	end
	else begin
		y_equal = 1'b0;
	end
	if(packet_addr_x_i == local_addr_x_i) begin
		x_equal = 1'b1;
	end
	else begin
		x_equal = 1'b0;
	end
	


	if(packet_valid_i) begin
		if(y_equal && x_equal) begin //both equal
			north_req = 0;
			east_req = 0;
			south_req = 0;
			west_req = 0;
			local_req = 1;
		end
		else begin // not both equal
			if(y_equal) begin  //only y equal
				if(x_le) begin
					north_req = 0;
					east_req = 0;
					south_req = 0;
					west_req = 1;
					local_req = 0;		
				end
				else if(x_gt) begin
					north_req = 0;
					east_req = 1;
					south_req = 0;
					west_req = 0;
					local_req = 0;	
				end
			end
			else begin //y not equal,
				if(y_le) begin
					north_req = 1;
					east_req = 0;
					south_req = 0;
					west_req = 0;
					local_req = 0;		
				end
				else if(y_gt) begin
					north_req = 0;
					east_req = 0;
					south_req = 1;
					west_req = 0;
					local_req = 0;	
				end
			end	
		end
	end
	else begin
					north_req = 0;
					east_req = 0;
					south_req = 0;
					west_req = 0;
					local_req = 0;
	end
end


DW01_cmp2_knock #(.width(4)) comp_x(
.A(packet_addr_x_i),
.B(local_addr_x_i),
.LEQ(1'b1),
.TC(1'b0),
.LT_LE(x_le),
.GE_GT(x_gt)
								);	

DW01_cmp2_knock #(.width(4)) comp_y(
.A(packet_addr_y_i),
.B(local_addr_y_i),
.LEQ(1'b1),
.TC(1'b0),
.LT_LE(y_le),
.GE_GT(y_gt)
								);	




endmodule





