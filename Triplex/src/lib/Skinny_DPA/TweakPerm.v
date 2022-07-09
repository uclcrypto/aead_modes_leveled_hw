`timescale 1ns / 1ps
module TweakPerm (
    state, 
    update
);

parameter W = 8;

input [128-1 : 0] state;
output [128-1 : 0] update;

assign update[W-1 : 0] = state[9*W-1 : 8*W];
assign update[2*W-1 : W] = state[10*W-1 : 9*W];
assign update[3*W-1 : 2*W] = state[11*W-1 : 10*W];
assign update[4*W-1 : 3*W] = state[12*W-1 : 11*W];

assign update[5*W-1 : 4*W] = state[13*W-1 : 12*W];
assign update[6*W-1 : 5*W] = state[14*W-1 : 13*W];
assign update[7*W-1 : 6*W] = state[15*W-1 : 14*W];
assign update[8*W-1 : 7*W] = state[16*W-1 : 15*W];

assign update[9*W-1 : 8*W] = state[5*W-1 : 4*W];
assign update[10*W-1 : 9*W] = state[4*W-1 : 3*W];
assign update[11*W-1 : 10*W] = state[2*W-1 : W];
assign update[12*W-1 : 11*W] = state[6*W-1 : 5*W];

assign update[13*W-1 : 12*W] = state[3*W-1 : 2*W];
assign update[14*W-1 : 13*W] = state[8*W-1 : 7*W];
assign update[15*W-1 : 14*W] = state[W-1 : 0];
assign update[16*W-1 : 15*W] = state[7*W-1 : 6*W];

endmodule