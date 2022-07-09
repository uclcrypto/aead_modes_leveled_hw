`timescale 1ns/1ps
module lfsr_D (clk, sel, en, outmux2);
input clk, sel, en;
output [56-1:0] outmux2;

wire [56-1:0] outmux1, D_rounded;
reg [56-1:0] D_rounding;

assign outmux1 = (sel) ? {{(48){1'b0}},{1'b1},{(7){1'b0}}} : D_rounded;
assign outmux2 = (en) ? outmux1 : D_rounding;
always @(posedge clk) begin
    D_rounding <= outmux2;
end

assign D_rounded[55:8] = D_rounding[54:7];
assign D_rounded[7] = D_rounding[6] ^ D_rounding[55];
assign D_rounded[6:5] = D_rounding[5:4];
assign D_rounded[4] = D_rounding[3] ^ D_rounding[55];
assign D_rounded[3] = D_rounding[2];
assign D_rounded[2] = D_rounding[1] ^ D_rounding[55];
assign D_rounded[1] = D_rounding[2];
assign D_rounded[0] = D_rounded[55];

endmodule