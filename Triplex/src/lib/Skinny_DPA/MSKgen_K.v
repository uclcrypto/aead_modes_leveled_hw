`timescale 1ns / 1ps
module MSKgen_K #(parameter d = 2) (sel, en, clk, K, K_rounding_F);

parameter W = 8;

(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 128 *) input [128*d - 1 : 0] K;
(* fv_type = "clock" *) input clk;
(* fv_type="control" *) input sel, en;
(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 6, fv_count = 128 *) output [128*d - 1 : 0] K_rounding_F;

wire [128*d-1 : 0] K_rounded, K_rounding, K_P;

MSKmux #(.d(d), .count(128)) mux1 (sel, K, K_rounded, K_rounding);

MSKregEn #(.d(d), .count(128)) reg1 (clk, en, K_rounding, K_rounding_F);

MSKTweakPerm #(d) TweakPerm3 (K_rounding_F, K_P);

genvar i;
generate
for(i=8;i<16;i=i+1) begin: lfsr3
    MSK_LFSR3 #(.d(d)) lfsri (
        .state(K_P[(i+1)*W*d-1:i*W*d]), 
        .update(K_rounded[(i+1)*W*d-1:i*W*d])
    );
end
endgenerate
assign K_rounded[8*d*W-1 : 0] = K_P[8*d*W-1:0];

endmodule