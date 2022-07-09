`timescale 1ns/1ps
module encrypt_spa (
    clk, 
    sel1, 
    sel2, 
    sel_cst, 
    done, 
    in, 
    out
);
input clk, sel1, sel2, sel_cst, done;
input [320-1:0] in;
output [320-1:0] out;

    // PARAMETERS
    parameter W = 64;
    parameter L = 16;
    parameter B = 80;

    wire [7:0] rnd_cst, rnd_cst_muxed;
    wire [B-1:0] in1, in2, in3, in4;
    wire [B-1:0] L1, L2, L3, L4;
    wire [W-1:0] line1_roundingCT_CS, line2_roundingCT_CS, line3_roundingCT_CS, line4_roundingCT_CS, line5_roundingCT_CS;
    wire [B-1:0] muxed1, muxed2, muxed3, muxed4;
    wire [B-1:0] outmux1, outmux2, outmux3, outmux4, outmux4_C_F;
    wire [B-1:0] sbox_out;
    reg [B-1:0] outmux1_F, outmux2_F, outmux3_F, outmux4_F;
    reg  [B-1:0] sbox_out_f;
    wire [320-1:0] full_roundingCT_CS, roundingCT_CSL, zero_output, full_roundingCT_CS_ok;

    assign in4 = {in[4*W +: 16], in[3*W +: 16], in[2*W +: 16], in[W +: 16], in[0 +: 16]};
    assign in3 = {in[4*W + L +: 16], in[3*W + L +: 16], in[2*W + L +: 16], in[W + L +: 16], in[L +: 16]};
    assign in2 = {in[4*W + 2*L +: 16], in[3*W + 2*L +: 16], in[2*W + 2*L +: 16], in[W + 2*L+: 16], in[2*L +: 16]};
    assign in1 = {in[4*W + 3*L +: 16], in[3*W + 3*L +: 16], in[2*W + 3*L +: 16], in[W + 3*L +: 16], in[3*L +: 16]};

    CstGen_spa cstgen (clk, sel1, sel2, rnd_cst);

    // DATAPATH LAYERS
    assign muxed1 = (sel1) ? in1 : L1;
    assign outmux1 = (sel2) ? muxed1 : sbox_out;
    always @(posedge clk) begin
        outmux1_F <= outmux1;
    end

    assign muxed2 = (sel1) ? in2 : L2;
    assign outmux2 = (sel2) ? muxed2 : outmux1_F;
    always @(posedge clk) begin
        outmux2_F <= outmux2;
    end

    assign muxed3 = (sel1) ? in3 : L3;
    assign outmux3 = (sel2) ? muxed3 : outmux2_F;
    always @(posedge clk) begin
        outmux3_F <= outmux3;
    end

    assign muxed4 = (sel1) ? in4 : L4;
    assign outmux4 = (sel2) ? muxed4 : outmux3_F;
    always @(posedge clk) begin
        outmux4_F <= outmux4;
    end

    // PERMUTATION C    
    assign rnd_cst_muxed = (sel_cst) ? rnd_cst : {(8){1'b0}};
    assign outmux4_C_F[2*L +: 8] = rnd_cst_muxed ^ outmux4_F[2*L +: 8];
    assign outmux4_C_F[B-1 : 40] = outmux4_F[B-1 : 40];
    assign outmux4_C_F[2*L-1 : 0] = outmux4_F[2*L-1 : 0];

    // PERMUTATION S
    genvar i;
    generate 
    for(i=0; i<16; i = i + 1) begin: sboxs //outmux4_C_F
        Sbox sboxi (
            .clk(clk),
            .in({outmux4_C_F[4*L + i +: 1], outmux4_C_F[3*L + i +: 1], outmux4_C_F[2*L + i +: 1], outmux4_C_F[L + i +: 1], outmux4_C_F[i +: 1]}),
            .out({sbox_out[4*L + i +: 1], sbox_out[3*L + i +: 1], sbox_out[2*L + i +: 1], sbox_out[L + i +: 1], sbox_out[i +: 1]})
        );
    end
    endgenerate

    // PERMUTATION L
    // Line reconstruction
    assign line1_roundingCT_CS = {sbox_out[4*L +: L], outmux1_F[4*L +: L], outmux2_F[4*L +: L], outmux3_F[4*L +: L]};
    assign line2_roundingCT_CS = {sbox_out[3*L +: L], outmux1_F[3*L +: L], outmux2_F[3*L +: L], outmux3_F[3*L +: L]};
    assign line3_roundingCT_CS = {sbox_out[2*L +: L], outmux1_F[2*L +: L], outmux2_F[2*L +: L], outmux3_F[2*L +: L]};
    assign line4_roundingCT_CS = {sbox_out[L +: L], outmux1_F[L +: L], outmux2_F[L +: L], outmux3_F[L +: L]};
    assign line5_roundingCT_CS = {sbox_out[0 +: L], outmux1_F[0 +: L], outmux2_F[0 +: L], outmux3_F[0 +: L]};
    // Full state reconstruction
    assign full_roundingCT_CS = {line1_roundingCT_CS, line2_roundingCT_CS, line3_roundingCT_CS, line4_roundingCT_CS, line5_roundingCT_CS};
    
    PermL permL (full_roundingCT_CS, roundingCT_CSL);

    assign L4 = {roundingCT_CSL[4*W +: 16], roundingCT_CSL[3*W +: 16], roundingCT_CSL[2*W +: 16], roundingCT_CSL[W +: 16], roundingCT_CSL[0 +: 16]};
    assign L3 = {roundingCT_CSL[4*W + L +: 16], roundingCT_CSL[3*W + L +: 16], roundingCT_CSL[2*W + L +: 16], roundingCT_CSL[W + L +: 16], roundingCT_CSL[L +: 16]};
    assign L2 = {roundingCT_CSL[4*W + 2*L +: 16], roundingCT_CSL[3*W + 2*L +: 16], roundingCT_CSL[2*W + 2*L +: 16], roundingCT_CSL[W + 2*L+: 16], roundingCT_CSL[2*L +: 16]};
    assign L1 = {roundingCT_CSL[4*W + 3*L +: 16], roundingCT_CSL[3*W + 3*L +: 16], roundingCT_CSL[2*W + 3*L +: 16], roundingCT_CSL[W + 3*L +: 16], roundingCT_CSL[3*L +: 16]};
    
    assign out = (done) ? roundingCT_CSL : {(320){1'b0}};
endmodule