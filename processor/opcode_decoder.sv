
// This is the control module for cpu
// It takes a 5-bit opcode and set the coresponding control signal
module opcode_decoder(

	//input opcode
	input [4:0] opcode,
	
	// output signals
	output logic ALUOp,// 0 for add, 1 for sub
	output logic RegWrite,// write enable to regitor files
	output logic MemWrite, // write enable to mem
	output logic ALUSrc,//0 for rd2, 1 for imm_ext
	output logic RegDst,// 0 for Rx, 1 for R7
	output logic [2:0] WBSrc,//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
	output logic [1:0] PCSrc,//00 for br, 01 for rind, 10 for pc+2  
	output logic ExtSel, //0 for imm8, 1 for imm11
	output logic NZ, //should update NZ
	output logic mem_sel, //0 for reading instruction, 1 for reading other memory
	output logic BSrc // 0 for imm_ext, 1 for rd2
);

always_comb begin
    case(opcode)
        5'b00000: begin//mv
            ALUOp = 1'bx;
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			ALUSrc = 1'bx;
			RegDst = 1'b0;
			WBSrc = 3'b011;
			PCSrc = 2'b10;
			ExtSel = 1'bx;
			NZ = 1'b0;
			mem_sel = 1'b0;
			BSrc = 1'b0;
        end
        5'b00001:begin//add
            ALUOp = 1'b0;
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegDst = 1'b0;
			WBSrc = 3'b001;
			PCSrc = 2'b10;
			ExtSel = 1'bx;
			NZ = 1'b0;
			mem_sel = 1'b0;
			BSrc = 1'b0;
        end
        // 5'b00010:begin//sub
        // end
        // 5'b00011:begin//cmp
        // end
        // 5'b00100:begin//ld
        // end
        // 5'b00101:begin//st
        // end
        5'b10000:begin//mvi
			ALUOp = 1'b0;
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegDst = 1'b0;
			WBSrc = 3'b100;
			PCSrc = 2'b10;
			ExtSel = 1'b0;
			NZ = 1'b0;
			mem_sel = 1'b0;
        end
        // 5'b10001:begin//addi
        // end
        // 5'b10010:begin//subi
        // end
        // 5'b10011:begin//cmpi
        // end
        // 5'b10110:begin//mvhi
        // end
        // 5'b01000:begin//jr
        // end
        // 5'b01001:begin//jzr
        // end
        // 5'b01010:begin//jnr
        // end
        // 5'b01100:begin//callr
        // end
        5'b11000:begin//j
			ALUOp = 1'b0;
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegDst = 1'b0;
			WBSrc = 3'b100;
			PCSrc = 2'b10;
			ExtSel = 1'b0;
			NZ = 1'b0;
			mem_sel = 1'b0;
        end
        // 5'b11001:begin//jz
        // end
        // 5'b11010:begin//jn
        // end
        // 5'b11100:begin//call

        // end
        default: begin
			ALUOp = 1'b0;
			RegWrite = 1'b0;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegDst = 1'b0;
			WBSrc = 3'b001;
			PCSrc = 2'b10;
			ExtSel = 1'bx;
			NZ = 1'b0;
			BSrc = 1'b0;
		end
    endcase
    
end
endmodule