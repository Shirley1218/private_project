// module non_pipelined_state(

// 	input					clk,
// 	input					reset,
	
//     output logic            fetch
// );

// enum int unsigned
// {
//     IDLE,
//     FETCH,
//     STATE1,
//     STATE2
// } state, nextstate;

// // Clocked always block for making state registers
// always_ff @ (posedge clk or posedge reset) begin
// 	if (reset) state <= IDLE;
// 	else state <= nextstate;
// end

// always_comb begin
// 	nextstate = state;
// 	fetch = 1'b0;
// 	case (state)
//         IDLE:
//             begin
//                 fetch = 1'b0;
//                 nextstate = FETCH;
//             end
// 		FETCH:
//             begin
//                 fetch = 1'b1;
//                 nextstate = FETCH;
//             end
//         STATE1:
//             begin
//                 fetch = 1'b0;
//                 nextstate = STATE2;
//             end
//         STATE2:
//             begin
//                 fetch = 1'b0;
//                 nextstate = FETCH;
//             end
// 	endcase
// end
// endmodule