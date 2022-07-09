`timescale 1ns/1ps
module PermL (state, update); 
    parameter W = 64;

    input [5*W-1 : 0] state;
    output [5*W-1 : 0] update;

    wire [W-1 : 0] x0, x1, x2, x3, x4;
    wire [W-1 : 0] x0_p1, x0_p2, x1_p1, x1_p2, x2_p1, x2_p2, x3_p1, x3_p2, x4_p1, x4_p2;
    wire [W-1 : 0] x0_modif, x1_modif, x2_modif, x3_modif, x4_modif;

    assign x0 = state[5*W-1 : 4*W];
    assign x1 = state[4*W-1 : 3*W];
    assign x2 = state[3*W-1 : 2*W];
    assign x3 = state[2*W-1 : W];
    assign x4 = state[W-1 : 0];

    //L1
    assign x0_p1 = {x0[19-1 : 0], x0[64-1 : 19]};
    assign x0_p2 = {x0[28-1 : 0], x0[64-1 : 28]};
    assign x0_modif = x0_p1 ^ x0_p2;
    assign update[5*W-1 : 4*W] = x0 ^ x0_modif;
    //L2
    assign x1_p1 = {x1[61-1 : 0], x1[64-1 : 61]};
    assign x1_p2 = {x1[39-1 : 0], x1[64-1 : 39]};
    assign x1_modif = x1_p1 ^ x1_p2;
    assign update[4*W-1 : 3*W] = x1 ^ x1_modif;
    //L3
    assign x2_p1 = {x2[0], x2[64-1 : 1]};
    assign x2_p2 = {x2[6-1 : 0], x2[64-1 : 6]};
    assign x2_modif = x2_p1 ^ x2_p2;
    assign update[3*W-1 : 2*W] = x2 ^ x2_modif;
    //L4
    assign x3_p1 = {x3[10-1 : 0], x3[64-1 : 10]};
    assign x3_p2 = {x3[17-1 : 0], x3[64-1 : 17]};
    assign x3_modif = x3_p1 ^ x3_p2;
    assign update[2*W-1 : W] = x3 ^ x3_modif;
    //L5
    assign x4_p1 = {x4[7-1 : 0], x4[64-1 : 7]};
    assign x4_p2 = {x4[41-1 : 0], x4[64-1 : 41]};
    assign x4_modif = x4_p1 ^ x4_p2;
    assign update[W-1 : 0] = x4 ^ x4_modif;
endmodule