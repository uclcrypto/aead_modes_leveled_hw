`timescale 1ns/1ps
module u_LFSR3 (state, update);
input [8 - 1 : 0] state;
output [8 - 1 : 0] update;

assign update[7] = state[0] ^ state [6];
assign update[7 - 1 : 0] = state[7: 1];

endmodule
