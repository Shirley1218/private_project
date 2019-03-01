module mux(
	input wire data_in1,
	input wire data_in2,
	input		  sel,
	output reg mux_out 
);
	assign mux_out = (sel) ? data_in1 : data_in2;
	
endmodule

