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
// logic MemWrite; // write enable to mem
logic ALUSrc;//0 for rd2, 1 for imm_ext
logic RegDst;// 0 for Rx, 1 for R7
logic [2:0] WBSrc;//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
logic PCSrc; //0 for br 1 for pc+2  
logic BrSrc; // 0 for rd1, 1 for pc + offset  
logic ExtSel; //0 for imm8, 1 for imm11
logic NZ; //should update NZ
logic pc_enable; // enable pc jump
logic BSrc;// 0 for rd2, 1 for imm_ext
logic busy;//loading or storing, use old rx
logic [15:0] rd1, rd2, pc_out,wd,pc_nxt, imm_ext, pc_in, br, alu_out;
logic mem_sel;//0 for reading instruction, 1 for reading other memory
logic [1:0] br_sel; // 0 = always br(no condition) , 1 = branch if Z == 1, 2 = branch if N == 1
logic br_cond;
logic ld;

logic fetch;
logic alu_zero, alu_neg;
reg zero,neg;

reg [2:0] last_rx;
// reg [15:0] last_rd1;
assign ws = RegDst ? 3'b111 : (busy ? last_rx : i_mem_rddata[7:5]);

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

assign o_mem_wrdata = rd1;

pc my_pc(
    .clk(clk),
    .reset(reset),
    .enable(pc_enable & br_cond), // enable branch , next pc_out = in + 2
	.incr(fetch & (~ld)),
    .i_addr(pc_in),
    .pc_out(pc_out)
	//.pc_nxt(pc_nxt)
);
logic br_ahread; // branch discard next bubble
assign br_ahread = (PCSrc == 1'b0) & br_cond;
assign o_mem_addr = mem_sel ? rd2 : (br_ahread ? pc_in : pc_out);
assign o_mem_rd = fetch ? 1'b1 : 1'b0; // todo: read from data mem
assign opcode = i_mem_rddata[4:0];

// non_pipelined_state fsm(
// 	.clk(clk),
//     .reset(reset),
//     .fetch(fetch)
// );

opcode_decoder my_control(
	.clk(clk),
	.reset(reset),

	//input opcode
	.opcode(opcode),
	
	// output signals
	.ALUOp(ALUOp),// 0 for add, 1 for sub
	.RegWrite(RegWrite),// write enable to regitor files
	.MemWrite(o_mem_wr), // write enable to mem
	.ALUSrc(ALUSrc),//0 for rd2, 1 for imm_ext
	.RegDst(RegDst),// 0 for Rx, 1 for R7
	.WBSrc(WBSrc),//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
	.PCSrc(PCSrc),//0 for br 1 for pc+2  
	.BrSrc(BrSrc), // 0 for rd1, 1 for pc + offset
	.ExtSel(ExtSel), //0 for imm8, 1 for imm11
	.NZ(NZ), //should update NZ
	.mem_sel(mem_sel),
	.BSrc(BSrc),
	.pc_enable(pc_enable),
	.fetch(fetch),
	.BrCond(br_sel), // 0 = always br(no condition) , 1 = branch if Z == 1, 2 = branch if N == 1
	.busy(busy),
	.ld(ld)
);


logic [7:0] imm8;
logic [15:0] imm_8_ext;
assign imm8 = i_mem_rddata[15:8];
logic [10:0] imm11;
logic [15:0] imm_11_ext;
assign imm11 = i_mem_rddata[15:5];
logic [15:0] mem_in;
assign mem_in = i_mem_rddata;
logic [15:0] mvhi_out;
assign mvhi_out = {imm8,rd1[7:0]};

sign_ext imm8_(
	.in(imm8),
	.out(imm_8_ext)
);

sign_ext #(11) imm11_ (
	.in(imm11),
	.out(imm_11_ext)
);

assign imm_ext = ExtSel ? imm_11_ext : imm_8_ext;
six_one_mux sel_to_wd
(
	.data_in1(mem_in),
	.data_in2(alu_out),
	.data_in3(pc_out),
	.data_in4(rd2),
	.data_in5(imm_ext),
	.data_in6(mvhi_out),
	.sel(WBSrc),
	.mux_out(wd)
);


four_one_mux #(1) sel_to_br
(
	.data_in1(1'b1),
	.data_in2(zero),
	.data_in3(neg),
	.data_in4(), // not used
	.sel(br_sel), // 0 = always br(no condition) , 1 = branch if Z == 1, 2 = branch if N == 1
	.mux_out(br_cond)
);
assign br = br_cond ? ( BrSrc ? pc_out + imm_ext * 2 : rd1 ): pc_out; // branch to pc + imm if condition meet


two_one_mux sel_to_pc
(
	.data_in1(pc_out),
	.data_in2(br),
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


always_ff @ (posedge clk or posedge reset) begin
	if(reset) begin
		last_rx <= 3'b000;
		// last_rd1 <= 16'd0;
	end
	else begin
		last_rx <= i_mem_rddata[7:5];
		// last_rd1 <= rd1;
	end
end



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