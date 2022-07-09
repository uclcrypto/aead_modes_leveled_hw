`timescale 1ns/1ps
module u_LFSR1 (
    state,
    update
);

input [5:0] state;
output [5:0] update;

assign update[0] = 1 ^ state[5] ^ state[4];
assign update[5:1] = state [4:0];

endmodule