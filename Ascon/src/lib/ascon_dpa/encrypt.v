`timescale 1ns / 1ps
/*
CLK :     clock
SEL1 :    start dut
SEL2 :    input the computed state in registers
SEL_CST : allow round_constant evolution
DONE :    allow outputing the final state
RND :     randomness for masking
IN :      initial state
OUT :     final state is outputed on CYCLE_CNT = 0, ROUND_CNT = 12

cycle_cnt   : --0--1--2--3--4--5--0--
rnd_cnt     : --0-----------------1--
               <   S  B  O   X   >  
               <IN>              <IN>
*/  
module encrypt #(parameter d = 2) (
    clk,
    sel1,
    sel2,
    sel_cst,
    done,
    rnd,
    in,
    out
);
localparam and_pini_mul_nrnd = d*(d-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;
    // PARAMETERS
    parameter W = 64;
    parameter L = 16;
    parameter B = 80;

    // INPUT
    (* fv_type = "clock" *) input clk;
    (* fv_type = "control" *) input sel1, sel2, sel_cst, done;
    (* syn_keep = "true", keep = "true", fv_type = "random", fv_count = 16,
    fv_rnd_count_0 = and_pini_nrnd, fv_rnd_lat_0 = 0,
    fv_rnd_count_1 = and_pini_nrnd, fv_rnd_lat_1 = 0,
    fv_rnd_count_2 = and_pini_nrnd, fv_rnd_lat_2 = 0,
    fv_rnd_count_3 = and_pini_nrnd, fv_rnd_lat_3 = 0,
    fv_rnd_count_4 = and_pini_nrnd, fv_rnd_lat_4 = 0,
    fv_rnd_count_5 = and_pini_nrnd, fv_rnd_lat_5 = 0,
    fv_rnd_count_6 = and_pini_nrnd, fv_rnd_lat_6 = 0,
    fv_rnd_count_7 = and_pini_nrnd, fv_rnd_lat_7 = 0,
    fv_rnd_count_8 = and_pini_nrnd, fv_rnd_lat_8 = 0,
    fv_rnd_count_9 = and_pini_nrnd, fv_rnd_lat_9 = 0,
    fv_rnd_count_10 = and_pini_nrnd, fv_rnd_lat_10 = 0,
    fv_rnd_count_11 = and_pini_nrnd, fv_rnd_lat_11 = 0,
    fv_rnd_count_12 = and_pini_nrnd, fv_rnd_lat_12 = 0,
    fv_rnd_count_13 = and_pini_nrnd, fv_rnd_lat_13 = 0,
    fv_rnd_count_14 = and_pini_nrnd, fv_rnd_lat_14 = 0,
    fv_rnd_count_15 = and_pini_nrnd, fv_rnd_lat_15 = 0 *) input [and_pini_nrnd*16*5-1 : 0] rnd;
    (* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 320 *) input [320*d-1:0] in;
    // OUTPUT
    (* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 6, fv_count = 320 *) output [320*d-1:0] out;

    // REGS
    reg done_f;
    // WIRE
    wire [7:0] rnd_cst;
    wire [8*d-1:0] msk_rnd_cst, rnd_cst_all, zero_cst;
    wire [W*d-1:0] line1_out, line2_out, line3_out, line4_out, line5_out, line1_roundingCT_CS, line2_roundingCT_CS, line3_roundingCT_CS, line4_roundingCT_CS, line5_roundingCT_CS;
    wire [B*d-1:0] in1, in2, in3, in4;
    wire [B*d-1:0] L1, L2, L3, L4;
    wire [B*d-1:0] muxed1, muxed2, muxed3, muxed4;
    wire [B*d-1:0] outmux1, outmux1_F, outmux2, outmux2_F, outmux3, outmux3_F, outmux4, outmux4_F, outmux4_C_F;
    wire [B*d-1:0] sbox_out;
    wire [320*d-1:0] state_out, full_roundingCT_CS, roundingCT_CSL, zero_output, full_roundingCT_CS_ok;

    // DEBUG
    wire [319:0] rounded_umsk;
    wire [79:0] sbox_out_umsk, outmux4_umsk, outmux4_C_umsk;
    // STATE CONDITIONNING
    assign in4 = {in[4*d*W +: 16*d], in[3*d*W +: 16*d], in[2*d*W +: 16*d], in[d*W +: 16*d], in[0 +: 16*d]};
    assign in3 = {in[4*d*W + L*d +: 16*d], in[3*d*W + L*d +: 16*d], in[2*d*W + L*d +: 16*d], in[d*W + L*d +: 16*d], in[L*d +: 16*d]};
    assign in2 = {in[4*d*W + 2*L*d +: 16*d], in[3*d*W + 2*L*d +: 16*d], in[2*d*W + 2*L*d +: 16*d], in[d*W + 2*L*d+: 16*d], in[2*L*d +: 16*d]};
    assign in1 = {in[4*d*W + 3*L*d +: 16*d], in[3*d*W + 3*L*d +: 16*d], in[2*d*W + 3*L*d +: 16*d], in[d*W + 3*L*d +: 16*d], in[3*L*d +: 16*d]};

    // CONSTANT GENERATION
    CstGen cstgen (clk, sel1, sel2, rnd_cst);

    MSKcst #(.d(d), .count(8)) cst_init (rnd_cst, msk_rnd_cst);
    // DATAPATH LAYERS
    MSKmux #(.d(d), .count(B)) mux1_1 (sel1, in1, L1, muxed1);
    MSKmux #(.d(d), .count(B)) mux1_2 (sel2, muxed1, sbox_out, outmux1);
    MSKreg #(.d(d), .count(B)) reg1 (clk, outmux1, outmux1_F);

    MSKmux #(.d(d), .count(B)) mux2_1 (sel1, in2, L2, muxed2);
    MSKmux #(.d(d), .count(B)) mux2_2 (sel2, muxed2, outmux1_F, outmux2);
    MSKreg #(.d(d), .count(B)) reg2 (clk, outmux2, outmux2_F);
    
    MSKmux #(.d(d), .count(B)) mux3_1 (sel1, in3, L3, muxed3);
    MSKmux #(.d(d), .count(B)) mux3_2 (sel2, muxed3, outmux2_F, outmux3);
    MSKreg #(.d(d), .count(B)) reg3 (clk, outmux3, outmux3_F);

    MSKmux #(.d(d), .count(B)) mux4_1 (sel1, in4, L4, muxed4);
    MSKmux #(.d(d), .count(B)) mux4_2 (sel2, muxed4, outmux3_F, outmux4);
    MSKreg #(.d(d), .count(B)) reg4 (clk, outmux4, outmux4_F);

    
    genvar k;
    generate
        for(k=0; k<80; k=k+1) begin
            assign outmux4_umsk[k] = ^(outmux4_F[d*(k+1)-1:d*k]);
        end
    endgenerate
    

    // PERMUTATION C
    MSKcst #(.d(d), .count(8)) cst_rndcst ({(8){1'b0}}, zero_cst);
    MSKmux #(.d(d), .count(8)) mux_cst (sel_cst, msk_rnd_cst, zero_cst, rnd_cst_all);

    MSKxor #(.d(d), .count(8)) xor1 (outmux4_F[2*L*d +: 8*d], rnd_cst_all, outmux4_C_F[2*L*d +: 8*d]);
    assign outmux4_C_F[B*d-1 : 40*d] = outmux4_F[B*d-1 : 40*d];
    assign outmux4_C_F[2*L*d-1 : 0] = outmux4_F[2*L*d-1 : 0];

    // PERMUTATION S

    genvar i;
    generate 
    for(i=0; i<16; i = i + 1) begin: sboxs //outmux4_C_F
        MSK_Sbox #(.d(d)) sboxi (
            .clk(clk),
            .rnd(rnd[i*5*and_pini_nrnd +: 5*and_pini_nrnd]),
            .in({outmux4_C_F[4*L*d + i*d +: d], outmux4_C_F[3*L*d + i*d +: d], outmux4_C_F[2*L*d + i*d +: d], outmux4_C_F[L*d + i*d +: d], outmux4_C_F[i*d +: d]}),
            .out({sbox_out[4*L*d + i*d +: d], sbox_out[3*L*d + i*d +: d], sbox_out[2*L*d + i*d +: d], sbox_out[L*d + i*d +: d], sbox_out[i*d +: d]})
        );
    end
    endgenerate

    // PERMUTATION L
    // Line reconstruction
    assign line1_roundingCT_CS = {sbox_out[4*L*d +: L*d], outmux1_F[4*L*d +: L*d], outmux2_F[4*L*d +: L*d], outmux3_F[4*L*d +: L*d]};
    assign line2_roundingCT_CS = {sbox_out[3*L*d +: L*d], outmux1_F[3*L*d +: L*d], outmux2_F[3*L*d +: L*d], outmux3_F[3*L*d +: L*d]};
    assign line3_roundingCT_CS = {sbox_out[2*L*d +: L*d], outmux1_F[2*L*d +: L*d], outmux2_F[2*L*d +: L*d], outmux3_F[2*L*d +: L*d]};
    assign line4_roundingCT_CS = {sbox_out[L*d +: L*d], outmux1_F[L*d +: L*d], outmux2_F[L*d +: L*d], outmux3_F[L*d +: L*d]};
    assign line5_roundingCT_CS = {sbox_out[0 +: L*d], outmux1_F[0 +: L*d], outmux2_F[0 +: L*d], outmux3_F[0 +: L*d]};
    // Full state reconstruction
    assign full_roundingCT_CS = {line1_roundingCT_CS, line2_roundingCT_CS, line3_roundingCT_CS, line4_roundingCT_CS, line5_roundingCT_CS};
    
    MSKmux #(.d(d), .count(320)) mux_permL (sel2, full_roundingCT_CS, zero_output, full_roundingCT_CS_ok);
    MSK_PermL #(d) permL (full_roundingCT_CS_ok, roundingCT_CSL);

    assign L4 = {roundingCT_CSL[4*d*W +: 16*d], roundingCT_CSL[3*d*W +: 16*d], roundingCT_CSL[2*d*W +: 16*d], roundingCT_CSL[d*W +: 16*d], roundingCT_CSL[0 +: 16*d]};
    assign L3 = {roundingCT_CSL[4*d*W + L*d +: 16*d], roundingCT_CSL[3*d*W + L*d +: 16*d], roundingCT_CSL[2*d*W + L*d +: 16*d], roundingCT_CSL[d*W + L*d +: 16*d], roundingCT_CSL[L*d +: 16*d]};
    assign L2 = {roundingCT_CSL[4*d*W + 2*L*d +: 16*d], roundingCT_CSL[3*d*W + 2*L*d +: 16*d], roundingCT_CSL[2*d*W + 2*L*d +: 16*d], roundingCT_CSL[d*W + 2*L*d+: 16*d], roundingCT_CSL[2*L*d +: 16*d]};
    assign L1 = {roundingCT_CSL[4*d*W + 3*L*d +: 16*d], roundingCT_CSL[3*d*W + 3*L*d +: 16*d], roundingCT_CSL[2*d*W + 3*L*d +: 16*d], roundingCT_CSL[d*W + 3*L*d +: 16*d], roundingCT_CSL[3*L*d +: 16*d]};

    assign line1_out = {outmux1_F[4*L*d +: L*d], outmux2_F[4*L*d +: L*d], outmux3_F[4*L*d +: L*d], outmux4_F[4*L*d +: L*d]};
    assign line2_out = {outmux1_F[3*L*d +: L*d], outmux2_F[3*L*d +: L*d], outmux3_F[3*L*d +: L*d], outmux4_F[3*L*d +: L*d]};
    assign line3_out = {outmux1_F[2*L*d +: L*d], outmux2_F[2*L*d +: L*d], outmux3_F[2*L*d +: L*d], outmux4_F[2*L*d +: L*d]};
    assign line4_out = {outmux1_F[L*d +: L*d], outmux2_F[L*d +: L*d], outmux3_F[L*d +: L*d], outmux4_F[L*d +: L*d]};
    assign line5_out = {outmux1_F[0 +: L*d], outmux2_F[0 +: L*d], outmux3_F[0 +: L*d], outmux4_F[0 +: L*d]};

    assign state_out = {line1_out, line2_out, line3_out, line4_out, line5_out};

    MSKcst #(.d(d), .count(320)) cst_out ({(320){1'b0}}, zero_output);
    MSKmux #(.d(d), .count(320)) mux_out (done_f, state_out, zero_output, out);
    
    always @(posedge clk) begin
        done_f <= done;
    end
    genvar j;
    generate
        for(j=0; j<320; j=j+1) begin
            assign rounded_umsk[j] = ^(state_out[d*(j+1)-1:d*j]);
        end
    endgenerate
    
endmodule