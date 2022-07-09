`timescale 1ns/1ps
module CstGen_spa (
clk, 
sel, 
en, 
rounding);

input clk, sel, en;
output reg [7:0] rounding;

wire [7:0] rounded, init, outmux1, outmux;

assign init = 8'hF0;

assign outmux1 = (sel) ? init : rounded;
assign outmux = (en) ? outmux1 : rounding;

always @(posedge clk) begin
    rounding <= outmux;
end

assign rounded[4 +: 4] = rounding[4 +: 4] - 4'b0001;
assign rounded[0 +: 4] = rounding[0 +: 4] + 4'b0001;

endmodule