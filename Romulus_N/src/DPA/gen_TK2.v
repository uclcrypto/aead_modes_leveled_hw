`timescale 1ns / 1ps
module gen_TK2 (
    clk,
    sel,
    en,
    TK2_init,
    TK2_rounding
);
    parameter W = 8;

    input sel, en, clk;
    input [127:0] TK2_init;
    output reg [127:0] TK2_rounding;

    wire [127:0] outmux1, outmux2, TK2_rounded, TK2_P;

    assign outmux1 = (sel) ? TK2_init : TK2_rounded;

    assign outmux2 = (en) ? outmux1 : TK2_rounding;

    always @ (posedge clk) begin
        TK2_rounding <= outmux2;
    end

    TweakPerm TK1_perm (TK2_rounding, TK2_P);
    LFSR2 LFSR_TK2_1 (TK2_P[16*W-1 : 15*W], TK2_rounded[16*W-1 : 15*W]);
    LFSR2 LFSR_TK2_2 (TK2_P[15*W-1 : 14*W], TK2_rounded[15*W-1 : 14*W]);
    LFSR2 LFSR_TK2_3 (TK2_P[14*W-1 : 13*W], TK2_rounded[14*W-1 : 13*W]);
    LFSR2 LFSR_TK2_4 (TK2_P[13*W-1 : 12*W], TK2_rounded[13*W-1 : 12*W]);
    LFSR2 LFSR_TK2_5 (TK2_P[12*W-1 : 11*W], TK2_rounded[12*W-1 : 11*W]);
    LFSR2 LFSR_TK2_6 (TK2_P[11*W-1 : 10*W], TK2_rounded[11*W-1 : 10*W]);
    LFSR2 LFSR_TK2_7 (TK2_P[10*W-1 : 9*W], TK2_rounded[10*W-1 : 9*W]);
    LFSR2 LFSR_TK2_8 (TK2_P[9*W-1 : 8*W], TK2_rounded[9*W-1 : 8*W]);
    assign TK2_rounded[8*W-1 : 0] = TK2_P[8*W-1: 0];
endmodule