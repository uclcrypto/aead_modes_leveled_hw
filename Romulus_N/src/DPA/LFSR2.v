`timescale 1ns / 1ps
module LFSR2 (
state,
update
);

input [7:0] state;
output [7:0] update;

assign update [0] = state[5] ^ state[7];
assign update[7 : 1] = state[6 : 0];

endmodule
