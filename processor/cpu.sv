module cpu(

	input					clk,
	input					reset,
	
	output [15:0]		o_mem_addr,
	output      		o_mem_rd,

	input  [15:0]		i_mem_rddata,
	output      		o_mem_wr,
	output [15:0] 		o_mem_wrdata

);


logic [2:0] rs1, rs2, ws;
logic [4:0] opcode,
logic ALUOp,// 0 for add, 1 for sub
logic RegWrite,// write enable to regitor files
logic MemWrite, // write enable to mem
logic ALUSrc,//0 for rd2, 1 for imm_ext
logic RegDst,// 0 for Rx, 1 for R7
logic [2:0] WBSrc,//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
logic [1:0] PCSrc,//00 for br, 01 for rind, 10 for pc+2  
logic ExtSel, //0 for imm8, 1 for imm11
logic NZ, //should update NZ
logic [15:0] rd1, rd2, pc_out,
module gprs_top(

	.clk(clk),
	.reset(reset),
	
	// input ports
	input [2:0] rs1, // read register 1
	input [2:0] rs2, // read register 2
	input [2:0] ws,  // write register
	input [15:0] wd,  // write data
	
	
	// output ports
	output logic [15:0] rd1, // read data 1
	output logic [15:0] rd2, // read data 2
	
	// Control signal
	input we				// Reg Write
);

pc my_pc(
    .clk(clk),
    .reset(reset),
    input enable,
    input branch,
	 input [15:0] branch_addr,
    output logic [15:0] pc_out
);

opcode_decoder my_control(

	//input opcode
	input [4:0] opcode,
	
	// output signals
	output ALUOp,// 0 for add, 1 for sub
	output RegWrite,// write enable to regitor files
	output MemWrite, // write enable to mem
	output ALUSrc,//0 for rd2, 1 for imm_ext
	output RegDst,// 0 for Rx, 1 for R7
	output [2:0] WBSrc,//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
	output [1:0] PCSrc,//00 for br, 01 for rind, 10 for pc+2  
	output ExtSel, //0 for imm8, 1 for imm11
	output NZ, //should update NZ
);
alu_16 my_alu(
    input [15:0] data_in_a,
    input [15:0] data_in_b,
    input sub,
    output logic [15:0] alu_out,
    output logic zero,
    output logic neg
);
endmodule