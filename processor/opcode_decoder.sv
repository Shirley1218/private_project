
// This is the control module for cpu
// It takes a 5-bit opcode and set the coresponding control signal
module opcode_decoder(

	//input opcode
	input [4:0] opcode,
	
	// output signals
	output ALUOp,
	output RegWrite,
	output MemWrite,
	output ALUSrc,
	output RegSel,
	output MemRd,
	output Mem2Reg,
	output Branch
);

	always_comb begin
    case(opcode[3:0])
        OP_MV:  
        OP_ADD:
        OP_SUB:
        OP_CMP:
        OP_LD:  
        OP_ST:  
        OP_MVI:
		  OP_SUBI:
		  OP_COMPI:
        OP_JR:
        OP_JNR:
        OP_JZR:
        OP_J:
		  OP_JZ:
		  OP_JN:
		  OP_CALL:
        default:
    endcase  
    
end
endmodule