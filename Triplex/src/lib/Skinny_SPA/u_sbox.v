`timescale 1ns/1ps
module u_sbox(in, out);

input [7:0] in;
output [7:0] out;

wire nand1, nand2, nand3, nand4, nand5, nand6, nand7, nand8;

assign nand1 = ~in[7] & ~in[6];
assign out[6] = nand1 ^ in[4];
assign nand2 = ~in[2] & ~in[3];
assign out[5] = in[0] ^ nand2;

assign nand3 = ~in[2] & ~in[1];
assign out[2] = in[6] ^ nand3;
assign nand4 = ~out[6] & ~out[5];
assign out[7] = nand4 ^ in[5];

assign nand5 = ~out[5] & ~in[3];
assign out[3] = nand5 ^ in[1];
assign nand6 = ~out[7] & ~out[2];
assign out[1] = nand6 ^ in[7];

assign nand7 = ~out[7] & ~out[6];
assign out[4] = nand7 ^ in[3];
assign nand8 = ~out[3] & ~out[1];
assign out[0] = nand8 ^ in[2];

endmodule
