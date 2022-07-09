`timescale 1ns / 1ps
module MSKskinny_encrypt #(parameter d = 2)(clk, en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, sel, en, en_glitch, done, rnd, init, TK1_init, TK2_init, K, PT, update_CKSM_o);
localparam and_pini_mul_nrnd = d*(d-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;

//PARAMETERS
parameter W = 8;
//INPUT / OUTPUT
(* fv_type = "clock" *) input clk;
(* fv_type="control" *) input sel, en, done, en_glitch, en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2;
(* syn_keep = "true", keep = "true", fv_type = "random", fv_count = 16,  fv_rnd_count_0 = and_pini_nrnd, fv_rnd_lat_0 = 0, fv_rnd_count_1 = and_pini_nrnd, fv_rnd_lat_1 = 0, fv_rnd_count_2 = and_pini_nrnd, fv_rnd_lat_2 = 0, fv_rnd_count_3 = and_pini_nrnd, fv_rnd_lat_3 = 0, fv_rnd_count_4 = and_pini_nrnd, fv_rnd_lat_4 = 0, fv_rnd_count_5 = and_pini_nrnd, fv_rnd_lat_5 = 0, fv_rnd_count_6 = and_pini_nrnd, fv_rnd_lat_6 = 0, fv_rnd_count_7 = and_pini_nrnd, fv_rnd_lat_7 = 0, fv_rnd_count_8 = and_pini_nrnd, fv_rnd_lat_8 = 0, fv_rnd_count_9 = and_pini_nrnd, fv_rnd_lat_9 = 0, fv_rnd_count_10 = and_pini_nrnd, fv_rnd_lat_10 = 0, fv_rnd_count_11 = and_pini_nrnd, fv_rnd_lat_11 = 0, fv_rnd_count_12 = and_pini_nrnd, fv_rnd_lat_12 = 0, fv_rnd_count_13 = and_pini_nrnd, fv_rnd_lat_13 = 0, fv_rnd_count_14 = and_pini_nrnd, fv_rnd_lat_14 = 0, fv_rnd_count_15 = and_pini_nrnd, fv_rnd_lat_15 = 0 *) input [16*2*and_pini_nrnd-1:0] rnd;
(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 6 *) input [6*d-1 : 0] init;
input [127:0] TK1_init, TK2_init;
(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 128 *) input [128*d-1 : 0] K;
(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 128 *) input [128*d-1 : 0] PT;
(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 6, fv_count = 128 *) output [128*d-1 : 0] update_CKSM_o;
// INTERMEDIATE VALUES
wire [128*d-1 : 0] update_C;
wire [128*d-1 : 0] TK1, TK2, TK3, PT_rounded;
wire [64*d-1 : 0] K1, K2, K3, tweak1, msk_K, msk_K_ok, cst_0, msk_K_ok_F;
wire  [128*d-1 : 0] PT_rounding;
wire [128*d-1 : 0] update, update_CK, update_CKS;
wire [6*d-1 : 0] roundcst;
wire[127 : 0] UMSKupdate_C, UMSKupdate_CK, UMSKupdate, UMSKupdate_CKS;
wire [127:0] TK1_out, TK2_out, umskTK3, PT_umsk;
wire [128*d-1 : 0] update_CKSM, K_out;
wire [128*d-1 : 0] outzeros;
wire [64-1:0] umsk_K;

wire [5:0] roundcst_test;

gen_TK1 TK1generation (clk, sel, en, TK1_init, TK1_out);
gen_TK2 TK2generation (clk, sel, en, TK2_init, TK2_out);
MSKgen_K #(d) Kgen (sel, en, clk, K, TK3);
/*
genvar k;
generate
	for(k=0; k<128; k=k+1) begin
		assign umskTK3[k] = ^(TK3[d*(k+1)-1:d*k]);
	end
endgenerate
*/
MSKcst #(.d(d), .count(128)) cstTK1 (TK1_out, TK1);
MSKcst #(.d(d), .count(128)) cstTK2 (TK2_out, TK2);

MSKmux #(.d(d), .count(128)) mux1 (sel, PT, PT_rounding, PT_rounded);

// SBOX 

MSKsbox #(d) sbox1 (PT_rounded[W*d-1 : 0], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[0 +: 2*and_pini_nrnd], clk, update[W*d-1 : 0]);
MSKsbox #(d) sbox2 (PT_rounded[2*W*d-1 : W*d], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[2*W*d-1 : W*d]);
MSKsbox #(d) sbox3 (PT_rounded[3*W*d-1 : 2*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[2*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[3*W*d-1 : 2*d*W]);
MSKsbox #(d) sbox4 (PT_rounded[4*W*d-1 : 3*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[3*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[4*W*d-1 : 3*d*W]);

MSKsbox #(d) sbox5 (PT_rounded[5*W*d-1 : 4*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[4*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[5*W*d-1 : 4*d*W]);
MSKsbox #(d) sbox6 (PT_rounded[6*W*d-1 : 5*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[5*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[6*W*d-1 : 5*d*W]);
MSKsbox #(d) sbox7 (PT_rounded[7*W*d-1 : 6*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[6*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[7*W*d-1 : 6*d*W]);
MSKsbox #(d) sbox8 (PT_rounded[8*W*d-1 : 7*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[7*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[8*W*d-1 : 7*d*W]);

MSKsbox #(d) sbox9 (PT_rounded[9*W*d-1 : 8*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[8*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[9*W*d-1 : 8*d*W]);
MSKsbox #(d) sbox10 (PT_rounded[10*W*d-1 : 9*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[9*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[10*W*d-1 : 9*d*W]);
MSKsbox #(d) sbox11 (PT_rounded[11*W*d-1 : 10*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[10*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[11*W*d-1 : 10*d*W]);
MSKsbox #(d) sbox12 (PT_rounded[12*W*d-1 : 11*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[11*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[12*W*d-1 : 11*d*W]);

MSKsbox #(d) sbox13 (PT_rounded[13*W*d-1 : 12*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[12*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[13*W*d-1 : 12*d*W]);
MSKsbox #(d) sbox14 (PT_rounded[14*W*d-1 : 13*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[13*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[14*W*d-1 : 13*d*W]);
MSKsbox #(d) sbox15 (PT_rounded[15*W*d-1 : 14*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[14*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[15*W*d-1 : 14*d*W]);
MSKsbox #(d) sbox16 (PT_rounded[16*W*d-1 : 15*d*W], en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, rnd[15*2*and_pini_nrnd +: 2*and_pini_nrnd], clk, update[16*W*d-1 : 15*d*W]);

genvar i;
generate
	for(i=0; i<128; i=i+1) begin
		assign PT_umsk[i] = ^(PT_rounded[d*(i+1)-1:d*i]);
	end
endgenerate


genvar k;
generate
	for(k=0; k<128; k=k+1) begin
		assign UMSKupdate[k] = ^(update[d*(k+1)-1:d*k]);
	end
endgenerate

// ARC ART MC SR

// ARC
LFSR1 lfsr1 (clk, sel, en, roundcst_test);
MSKcst #(.d(d), .count(6)) roundcstmsk (roundcst_test, roundcst);

MSKaddConst #(d) addConst1 (update, roundcst, update_C);
/*
genvar i;
generate
	for(i=0; i<128; i=i+1) begin
		assign UMSKupdate_C[i] = ^(update_C[d*(i+1)-1:d*i]);
	end
endgenerate
*/
// ART
assign K1 = TK1[16*d*W-1 : 8*d*W];
assign K2 = TK2[16*d*W-1 : 8*d*W];
assign K3 = TK3[16*d*W-1 : 8*d*W]; // key


MSKxor #(.d(d), .count(64)) xor1 (K1, K2, tweak1); 
MSKxor #(.d(d), .count(64)) xor2 (tweak1, K3, msk_K); 

MSKcst #(.d(d), .count(64)) cst_key ({(64){1'b0}}, cst_0);
MSKmux #(.d(d), .count(64)) mux_key (en_glitch, msk_K, cst_0, msk_K_ok);

MSKreg #(.d(d), .count(64)) reg_key (clk, msk_K_ok, msk_K_ok_F);

MSKxor #(.d(d), .count(64)) xor3 (update_C[128*d-1 : 64*d], msk_K_ok_F, update_CK[128*d-1 : 64*d]);

assign update_CK[64*d-1 : 0] = update_C[64*d-1 : 0];
/*
genvar a;
generate
	for(a=0; a<64; a=a+1) begin
		assign umsk_K[a] = ^(msk_K_ok_F[d*(a+1)-1:d*a]);
	end
endgenerate

genvar j;
generate
	for(j=0; j<128; j=j+1) begin
		assign UMSKupdate_CK[j] = ^(update_CK[d*(j+1)-1:d*j]);
	end
endgenerate
*/
// SR

MSKShiftRows #(d) ShiftRow1 (update_CK, update_CKS);

/*
genvar m;
generate
	for(m=0; m<128; m=m+1) begin
		assign UMSKupdate_CKS[m] = ^(update_CK[d*(m+1)-1:d*m]);
	end
endgenerate
*/
// MC

MSKMixColumn #(d) MixCol1 (update_CKS, PT_rounding);
assign update_CKSM = PT_rounding;


MSKcst #(.d(d), .count(128)) cst_out ({(128){1'b0}}, outzeros);

MSKmux #(.d(d), .count(128)) mux_out (done, update_CKSM, outzeros, update_CKSM_o);

endmodule