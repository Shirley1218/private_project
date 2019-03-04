
// This is the control module for cpu
// It takes a 5-bit opcode and set the coresponding control signal
module opcode_decoder(
	input clk,
	input reset,
	//input opcode
	input [4:0] opcode,
	
	// output signals
	output logic ALUOp,// 0 for add, 1 for sub
	output logic RegWrite,// write enable to regitor files
	output logic MemWrite, // write enable to mem
	output logic ALUSrc,//0 for rd2, 1 for imm_ext
	output logic RegDst,// 0 for Rx, 1 for R7
	output logic [2:0] WBSrc,//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8, 101 for {imm8,[rx][7:0]}
	output logic [1:0] PCSrc,//00 for br, 01 for rind, 10 for pc+2  
	output logic ExtSel, //0 for imm8, 1 for imm11
	output logic NZ, //should update NZ
	output logic mem_sel, //1 for reading instruction, 1 for reading other memory
	output logic BSrc,
	output logic pc_enable,
	output logic fetch,
	output logic busy
);
enum int unsigned
{
    IDLE,
    FETCH,
    LOAD,
    STORE1,
	STORE2
} state, nextstate;

logic ld, st;
// Clocked always block for making state registers
always_ff @ (posedge clk or posedge reset) begin
	if (reset) state <= IDLE;
	else if (ld) state <= LOAD;
	else if (st) state <= STORE1;
	else state <= nextstate;
end

always_comb begin
	nextstate = state;
	fetch = 1'b0;
	case (state)
        IDLE:
            begin
                fetch = 1'b0;
                nextstate = FETCH;
				busy = 1'b0;
            end
		FETCH:
            begin
                fetch = 1'b1;
                nextstate = FETCH;
				busy = 1'b0;
            end
        LOAD:
            begin
                fetch = 1'b1;
                nextstate = FETCH;
				busy = 1'b1;
            end
        STORE1:
            begin
                fetch = 1'b0;
                nextstate = STORE2;
				busy = 1'b1;
            end
		STORE2:
            begin
                fetch = 1'b0;
                nextstate = FETCH;
				busy = 1'b1;
            end
	endcase
end

always_comb begin
	if(state == FETCH) begin
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
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
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
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
			5'b00010:begin//sub
				ALUOp = 1'b1;
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
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
			5'b00011:begin//cmp
				ALUOp = 1'b1;
				RegWrite = 1'b0;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegDst = 1'b0;
				WBSrc = 3'b100;
				PCSrc = 2'b10;
				ExtSel = 1'b0;
				NZ = 1'b1;
				mem_sel = 1'b0;
				BSrc = 1'b0;
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
			5'b00100:begin//ld
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
				mem_sel = 1'b1;
				pc_enable = 1'b0;
				ld = 1'b1;
				st = 1'b0;
			end
			5'b00101:begin//st
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
				mem_sel = 1'b0;
				pc_enable = 1'b0;
				ld = 1'b0;
				st = 1'b1;
			end
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
				BSrc = 1'b0;
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
			5'b10001:begin//addi
				ALUOp = 1'b0;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b001;
				PCSrc = 2'b10;
				ExtSel = 1'b0;
				NZ = 1'b1;
				mem_sel = 1'b0;
				BSrc = 1'b1;
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
			5'b10010:begin//subi
				ALUOp = 1'b1;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b001;
				PCSrc = 2'b10;
				ExtSel = 1'b0;
				NZ = 1'b1;
				mem_sel = 1'b0;
				BSrc = 1'b1;
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
			5'b10011:begin//cmpi
				ALUOp = 1'b1;
				RegWrite = 1'b0;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b001;
				PCSrc = 2'b10;
				ExtSel = 1'b0;
				NZ = 1'b1;
				mem_sel = 1'b0;
				BSrc = 1'b1;
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
			5'b10110:begin//mvhi
				ALUOp = 1'b0;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegDst = 1'b0;
				WBSrc = 3'b101;
				PCSrc = 2'b10;
				ExtSel = 1'b0;
				NZ = 1'b0;
				mem_sel = 1'b0;
				BSrc = 1'b1;
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
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
				PCSrc = 2'b0;
				ExtSel = 1'b0;
				NZ = 1'b0;
				mem_sel = 1'b0;
				BSrc = 1'bx;
				pc_enable = 1'b0;
				ld = 1'b0;
				st = 1'b0;
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
				PCSrc = 2'b11;
				ExtSel = 1'bx;
				NZ = 1'b0;
				BSrc = 1'b0;
				mem_sel = 1'b0;
				pc_enable = 1'b1;
				ld = 1'b0;
				st = 1'b0;
			end
		endcase
	end
	else if (state == LOAD)begin
		ALUOp = 1'b0;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		ALUSrc = 1'b0;
		RegDst = 1'b0;
		WBSrc = 3'b000;
		PCSrc = 2'b10;
		ExtSel = 1'bx;
		NZ = 1'b0;
		BSrc = 1'b0;
		mem_sel = 1'b0;
		pc_enable = 1'b1;
		ld = 1'b0;
		st = 1'b0;
	end

	else begin 
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
		mem_sel = 1'b0;
		pc_enable = 1'b1;
		ld = 1'b0;
		st = 1'b0;
	end
    
end
endmodule