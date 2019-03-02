module 2_1mux
#( paramater DATA_WIDTH = 16 )
(
	input [DATA_WIDTH-1:0] data_in1,
	input [DATA_WIDTH-1:0] data_in2,
	input		  sel,
	output [DATA_WIDTH-1:0] mux_out 
);
	assign mux_out = (sel) ? data_in1 : data_in2;
	
endmodule

module 4_1mux
#( paramater DATA_WIDTH = 16 )
(
	input [DATA_WIDTH-1:0] data_in1,
	input [DATA_WIDTH-1:0] data_in2,
	input [DATA_WIDTH-1:0] data_in3,
	input [DATA_WIDTH-1:0] data_in4,
	input	[1:0]	  sel,
	output [DATA_WIDTH-1:0] mux_out 
);

	always_comb begin
		case (sel) 
			2'b00 : mux_out = data_in1;
			2'b01 : mux_out = data_in2;
			2'b10 : mux_out = data_in3;
			2'b11 : mux_out = data_in4;
		endcase 
	end 
	
endmodule

module 5_1mux
#( paramater DATA_WIDTH = 16 )
(
	input [DATA_WIDTH-1:0] data_in1,
	input [DATA_WIDTH-1:0] data_in2,
	input [DATA_WIDTH-1:0] data_in3,
	input [DATA_WIDTH-1:0] data_in4,
	input [DATA_WIDTH-1:0] data_in5,
	input	[2:0]	  sel,
	output [DATA_WIDTH-1:0] mux_out 
);

	always_comb begin
		case (sel) 
			2'b000 : mux_out = data_in1;
			2'b001 : mux_out = data_in2;
			2'b010 : mux_out = data_in3;
			2'b011 : mux_out = data_in4;
			2'b011 : mux_out = data_in5;
			default: mux_out = DATA_WIDTH'd0;
		endcase 
	end 
	
endmodule