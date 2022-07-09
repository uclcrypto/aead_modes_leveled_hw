`timescale 1ns/1ps
module addConst (in, roundcst, out);
input [128-1 : 0] in;
input [6-1 : 0] roundcst;
output [128-1 : 0] out;

assign out[123:120] = in[123:120] ^ roundcst[3:0];
assign out[89:88] = in[89:88] ^ roundcst[5:4];
assign out[57] = ~in[57];
assign out[128 - 1 : 124] = in[128 - 1 : 124];
assign out[120 - 1 : 90] = in[120 - 1 : 90];
assign out[88 - 1 : 58] = in[88 - 1 : 58];
assign out[57 - 1 : 0] = in[57 - 1 : 0];

endmodule