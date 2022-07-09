`timescale 1ns/1ps
module ShiftRows (state, update);

parameter W = 8;

input [128-1 : 0] state;
output [128-1 : 0] update;

//ROW 1
assign update [16*W - 1 : 12*W] = state [16*W - 1 : 12*W];
//ROW 2
assign update [12*W - 1 : 11*W] = state [9*W - 1 : 8*W];
assign update [11*W - 1 : 8*W] = state [12*W - 1 : 9*W];
//ROW 3
assign update [8*W - 1 : 6*W] = state [6*W - 1 : 4*W];
assign update [6*W - 1 : 4*W] = state [8*W - 1 : 6*W];

//ROW 4
assign update [4*W - 1 : W] = state [3*W - 1 : 0];
assign update [W - 1 : 0] = state [4*W - 1 : 3*W];

endmodule