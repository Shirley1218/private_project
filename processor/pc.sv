module pc (
    input clk,
    input reset,
    input enable,
    input branch,
	 input [15:0] branch_addr,
    output logic [15:0] pc_out
);

always_ff @(posedge clk) begin
    if(reset)
        pc_out <= 16'b0;
    else if(enable)
        pc_out <= (branch) ? branch_addr : (pc_out + 2'd2);
end

endmodule