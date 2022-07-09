`timescale 1ns / 1ps
module MSK_PermL #(parameter d = 2) (state, update); 
    parameter W = 64;

    (* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 320 *) input [5*W*d-1 : 0] state;
    (* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 320 *) output [5*W*d-1 : 0] update;

    wire [W*d-1 : 0] x0, x1, x2, x3, x4;
    wire [W*d-1 : 0] x0_p1, x0_p2, x1_p1, x1_p2, x2_p1, x2_p2, x3_p1, x3_p2, x4_p1, x4_p2;
    wire [W*d-1 : 0] x0_modif, x1_modif, x2_modif, x3_modif, x4_modif;

    wire [63:0] x0_p1umsk,x0_p2umsk, x0unmsk,x0clear;

    assign x0 = state[5*W*d-1 : 4*W*d];
    assign x1 = state[4*W*d-1 : 3*W*d];
    assign x2 = state[3*W*d-1 : 2*W*d];
    assign x3 = state[2*W*d-1 : W*d];
    assign x4 = state[W*d-1 : 0];

    //L1
    assign x0_p1 = {x0[19*d-1 : 0], x0[64*d-1 : 19*d]};
    assign x0_p2 = {x0[28*d-1 : 0], x0[64*d-1 : 28*d]};
    MSKxor #(.d(d), .count(64)) xor1 (x0_p1, x0_p2, x0_modif);
    MSKxor #(.d(d), .count(64)) xor2 (x0, x0_modif, update[5*W*d-1 : 4*W*d]);
    //L2
    assign x1_p1 = {x1[61*d-1 : 0], x1[64*d-1 : 61*d]};
    assign x1_p2 = {x1[39*d-1 : 0], x1[64*d-1 : 39*d]};
    MSKxor #(.d(d), .count(64)) xor3 (x1_p1, x1_p2, x1_modif);
    MSKxor #(.d(d), .count(64)) xor4 (x1, x1_modif, update[4*W*d-1 : 3*W*d]);
    //L3
    assign x2_p1 = {x2[d-1 : 0], x2[64*d-1 : d]};
    assign x2_p2 = {x2[6*d-1 : 0], x2[64*d-1 : 6*d]};
    MSKxor #(.d(d), .count(64)) xor5 (x2_p1, x2_p2, x2_modif);
    MSKxor #(.d(d), .count(64)) xor6 (x2, x2_modif, update[3*W*d-1 : 2*W*d]);
    //L4
    assign x3_p1 = {x3[10*d-1 : 0], x3[64*d-1 : 10*d]};
    assign x3_p2 = {x3[17*d-1 : 0], x3[64*d-1 : 17*d]};
    MSKxor #(.d(d), .count(64)) xor7 (x3_p1, x3_p2, x3_modif);
    MSKxor #(.d(d), .count(64)) xor8 (x3, x3_modif, update[2*W*d-1 : W*d]);
    //L5
    assign x4_p1 = {x4[7*d-1 : 0], x4[64*d-1 : 7*d]};
    assign x4_p2 = {x4[41*d-1 : 0], x4[64*d-1 : 41*d]};
    MSKxor #(.d(d), .count(64)) xor9 (x4_p1, x4_p2, x4_modif);
    MSKxor #(.d(d), .count(64)) xor10 (x4, x4_modif, update[W*d-1 : 0]);

endmodule