`timescale 1ns / 1ps
module gen_TK1 (
    clk,
    sel,
    en,
    TK1_init,
    TK1_rounding
);
    input sel, en, clk;
    input [127:0] TK1_init;
    output reg [127:0] TK1_rounding;

    wire [127:0] outmux1, outmux2, TK1_rounded;

    assign outmux1 = (sel) ? TK1_init : TK1_rounded;

    assign outmux2 = (en) ? outmux1 : TK1_rounding;

    always @ (posedge clk) begin
        TK1_rounding <= outmux2;
    end

    TweakPerm TK1_perm (TK1_rounding, TK1_rounded);

endmodule