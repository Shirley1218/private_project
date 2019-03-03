module cpu(

	input					clk,
	input					reset,
	
	output [15:0]		o_mem_addr,
	output      		o_mem_rd,

	input  [15:0]		i_mem_rddata,
	output      		o_mem_wr,
	output [15:0] 		o_mem_wrdata

);


logic [2:0] ws;
logic [4:0] opcode;
logic ALUOp;// 0 for add, 1 for sub
wire RegWrite;// write enable to regitor files
logic MemWrite; // write enable to mem
logic ALUSrc;//0 for rd2, 1 for imm_ext
logic RegDst;// 0 for Rx, 1 for R7
logic [2:0] WBSrc;//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
logic [1:0] PCSrc;//00 for br, 01 for rind, 10 for pc+2  
logic ExtSel; //0 for imm8, 1 for imm11
logic NZ; //should update NZ
logic pc_enable; // unused
logic BSrc;// 0 for rd2, 1 for imm_ext
logic [15:0] rd1, rd2, pc_out,wd,pc_nxt, imm_ext, pc_in, br, alu_out;
logic mem_sel;//0 for reading instruction, 1 for reading other memory

logic fetch;
logic alu_zero, alu_neg;
reg zero,neg;

assign ws = RegDst ? 3'b111 : i_mem_rddata[7:5] ;
logic [2:0] rs1,rs2;
assign rs1 = i_mem_rddata[7:5];
assign rs2 = i_mem_rddata[10:8];

gprs_top gprs(

	.clk(clk),
	.reset(reset),
	
	// input ports
	.rs1(rs1), // read register 1
	.rs2(rs2), // read register 2
	.ws(ws),  // write register
	.wd(wd),  // write data
	
	
	// output ports
	.rd1(rd1), // read data 1
	.rd2(rd2), // read data 2
	
	// Control signal
	.we(RegWrite)				// Reg Write
);

pc my_pc(
    .clk(clk),
    .reset(reset),
    .enable(fetch),
    .i_addr(pc_in),
    .pc_out(pc_out),
	.pc_nxt(pc_nxt)
);

assign o_mem_addr = mem_sel ? rd2 : pc_in;
assign o_mem_rd = 1'b1;// shall we always read from memory?
assign br = pc_nxt + imm_ext * 2;
assign opcode = i_mem_rddata[4:0];

non_pipelined_state fsm(
	.clk(clk),
    .reset(reset),
    .fetch(fetch)
);

opcode_decoder my_control(

	//input opcode
	.opcode(opcode),
	
	// output signals
	.ALUOp(ALUOp),// 0 for add, 1 for sub
	.RegWrite(RegWrite),// write enable to regitor files
	.MemWrite(MemWrite), // write enable to mem
	.ALUSrc(ALUSrc),//0 for rd2, 1 for imm_ext
	.RegDst(RegDst),// 0 for Rx, 1 for R7
	.WBSrc(WBSrc),//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
	.PCSrc(PCSrc),//00 for br, 01 for rind, 10 for pc+2  
	.ExtSel(ExtSel), //0 for imm8, 1 for imm11
	.NZ(NZ), //should update NZ
	.mem_sel(mem_sel),
	.BSrc(BSrc),
	.pc_enable(pc_enable)
);

logic [15:0] mem_in;
assign mem_in = i_mem_rddata;
five_one_mux sel_to_wd
(
	.data_in1(mem_in),
	.data_in2(alu_out),
	.data_in3(pc_nxt),
	.data_in4(rd2),
	.data_in5(imm_ext),
	.sel(WBSrc),
	.mux_out(wd)
);


four_one_mux sel_to_pc
(
	.data_in1(br),
	.data_in2(rd1),
	.data_in3(pc_nxt),
	.data_in4(16'd0),
	.sel(PCSrc),
	.mux_out(pc_in)
);

alu_16 my_alu(
    .data_in_a(rd1),
    .data_in_b(BSrc ? imm_ext : rd2),
    .sub(ALUOp),
    .alu_out(alu_out),
    .zero(alu_zero),
    .neg(alu_neg)
);

logic [7:0] imm;
assign imm = i_mem_rddata[15:8];

sign_ext imm8_(
	.in(imm),
	.out(imm_ext)
);


always_ff @ (posedge clk or posedge reset) begin
	if(reset) begin
		zero <= 1'b0;
		neg <= 1'b0;
	end
	else if(NZ)begin
		zero <= alu_zero;
		neg <= alu_neg;
	end
	else begin
		zero <= zero;
		neg <= neg;
	end
end
endmodule