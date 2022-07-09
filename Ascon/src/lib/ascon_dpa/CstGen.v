`timescale 1ns/1ps
module CstGen (
    clk,
    sel,
    en,
    outmux
);
    input sel, en, clk;
    output wire [7:0] outmux;

    wire [7:0] init, rounding_cst, rounded_cst;
    reg [7:0] rounding_muxed;
    reg [3:0] a, b, a_new, b_new;

    assign init = 8'hF0;

    assign rounding_cst = (sel) ? init : rounded_cst;

    assign outmux = (en) ? rounding_cst : rounding_muxed;
    always @ (posedge clk) begin
        rounding_muxed <= outmux;
            a <= rounding_muxed[7:4];
            b <= rounding_muxed[3:0];
            a_new <= a - 1;
            b_new <= b + 1;
    end

  assign rounded_cst[8-1:4] = a_new;
  assign rounded_cst[3:0] = b_new;

endmodule