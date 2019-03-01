module sign_ext #(parameter IN_SIZE = 8, parameter OUT_SIZE = 16)
(
	input [IN_SIZE-1:0] in,
	output [OUT_SIZE-1:0] out;
);
	assign output[IN_SIZE-1:0] = in;
	assign output[OUT_SIZE-1:IN_SIZE] = {32{in[IN_SIZE-1]}};
	
endmodule
