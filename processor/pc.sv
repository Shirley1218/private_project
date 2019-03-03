module pc (
    input clk,
    input reset,
    input enable,
	input [15:0] i_addr,
    output logic [15:0] pc_out,
    output [15:0] pc_nxt
);
assign pc_nxt = pc_out + 16'd2;
always_ff @(posedge clk or reset) begin
    if(reset)
        pc_out <= 16'b0;
    else if(enable) begin
        pc_out <= i_addr;
    end
    else begin
        pc_out <= pc_out;
    end
end

endmodule