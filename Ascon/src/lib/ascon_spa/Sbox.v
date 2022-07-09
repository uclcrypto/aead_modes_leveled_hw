`timescale 1ns/1ps
module Sbox (clk, in, out);
// INPUT / OUTPUT
input clk;
input [5-1 : 0] in;
output [5-1 : 0] out;

// INTERMEDIATE VALUES

wire x_xor1_0, x_xor2_0, x_xor1_1, x_xor1_2, x_xor2_2, x_xor1_3, x_xor1_4;
wire x_out_0, x_out_1, x_out_2, x_out_3, x_out_4;

// PROCESSING

assign x_xor1_0 = in[4] ^ in[0];
assign x_out_0 = (1 ^ x_xor1_0) & in[3];
assign x_xor2_0 = x_xor1_0 ^ x_out_1;
assign out[4] = x_xor2_0 ^ out[0];

assign x_xor1_1 = in[3] ^ x_out_2;
assign x_out_1 = (1 ^ in[3]) & x_xor1_2;
assign out[3] = x_xor1_1 ^ x_xor2_0;

assign x_xor1_2 = in[3] ^ in[2];
assign x_out_2 = (1 ^ x_xor1_2) & in[1];
assign x_xor2_2 = x_xor1_2 ^ x_out_3;
assign out[2] = 1 ^ x_xor2_2;

assign x_xor1_3 = in[1] ^ x_out_4;
assign x_out_3 = (1 ^ in[1]) & x_xor1_4;
assign out[1] = x_xor1_3 ^ x_xor2_2;

assign x_xor1_4 = in[0] ^ in[1];
assign out[0] = x_out_0 ^ x_xor1_4;
assign x_out_4 = (1 ^ x_xor1_4) & x_xor1_0;
endmodule