`timescale 1ns/1ps
module u_encrypt (clk, done, start, TK1, TK2, TK3, PT, out);

parameter W = 8;

input clk, done, start;
input [127:0] TK1, TK2, TK3, PT;
output [127:0] out;

reg [5:0] rounded_cst_F;
wire [5:0] rounded_cst, rounding_cst;
wire [63:0] K1, K2, K3, tweak1, K;
reg [127:0] TK1_rounded_F, TK2_rounded_F, TK3_rounded_F, update_F;
wire [127:0] TK1_rounded, TK2_rounded, TK3_rounded, TK1_rounding, TK2_rounding, TK3_rounding, TK1_perm, TK2_perm, TK3_perm, PT_rounding, update, update_C, update_CK, update_CKS, update_CKSM;

// Tweak generation
assign TK1_rounding = (start) ? TK1 : TK1_rounded_F;
assign TK2_rounding = (start) ? TK2 : TK2_rounded_F;
assign TK3_rounding = (start) ? TK3 : TK3_rounded_F;

TweakPerm tweakperm1 (TK1_rounding, TK1_rounded);
TweakPerm tweakperm2 (TK2_rounding, TK2_perm);
TweakPerm tweakperm3 (TK3_rounding, TK3_perm);


    LFSR2 LFSR_TK2_1 (TK2_perm[16*W-1 : 15*W], TK2_rounded[16*W-1 : 15*W]);
    LFSR2 LFSR_TK2_2 (TK2_perm[15*W-1 : 14*W], TK2_rounded[15*W-1 : 14*W]);
    LFSR2 LFSR_TK2_3 (TK2_perm[14*W-1 : 13*W], TK2_rounded[14*W-1 : 13*W]);
    LFSR2 LFSR_TK2_4 (TK2_perm[13*W-1 : 12*W], TK2_rounded[13*W-1 : 12*W]);
    LFSR2 LFSR_TK2_5 (TK2_perm[12*W-1 : 11*W], TK2_rounded[12*W-1 : 11*W]);
    LFSR2 LFSR_TK2_6 (TK2_perm[11*W-1 : 10*W], TK2_rounded[11*W-1 : 10*W]);
    LFSR2 LFSR_TK2_7 (TK2_perm[10*W-1 : 9*W], TK2_rounded[10*W-1 : 9*W]);
    LFSR2 LFSR_TK2_8 (TK2_perm[9*W-1 : 8*W], TK2_rounded[9*W-1 : 8*W]);

assign TK2_rounded[8*W-1:0] = TK2_perm[8*W-1:0];

    u_LFSR3 LFSR_TK3_1 (TK3_perm[16*W-1 : 15*W], TK3_rounded[16*W-1 : 15*W]);
    u_LFSR3 LFSR_TK3_2 (TK3_perm[15*W-1 : 14*W], TK3_rounded[15*W-1 : 14*W]);
    u_LFSR3 LFSR_TK3_3 (TK3_perm[14*W-1 : 13*W], TK3_rounded[14*W-1 : 13*W]);
    u_LFSR3 LFSR_TK3_4 (TK3_perm[13*W-1 : 12*W], TK3_rounded[13*W-1 : 12*W]);
    u_LFSR3 LFSR_TK3_5 (TK3_perm[12*W-1 : 11*W], TK3_rounded[12*W-1 : 11*W]);
    u_LFSR3 LFSR_TK3_6 (TK3_perm[11*W-1 : 10*W], TK3_rounded[11*W-1 : 10*W]);
    u_LFSR3 LFSR_TK3_7 (TK3_perm[10*W-1 : 9*W], TK3_rounded[10*W-1 : 9*W]);
    u_LFSR3 LFSR_TK3_8 (TK3_perm[9*W-1 : 8*W], TK3_rounded[9*W-1 : 8*W]);

assign TK3_rounded[8*W-1:0] = TK3_perm[8*W-1:0];

always @(posedge clk) begin
    TK1_rounded_F <= TK1_rounded;
    TK2_rounded_F <= TK2_rounded;
    TK3_rounded_F <= TK3_rounded;
end

// RoundConstant

assign rounding_cst = (start) ? {(6){1'b0}} : rounded_cst_F;
u_LFSR1 lfsr1_rndcst (rounding_cst, rounded_cst);
always @(posedge clk) begin
    rounded_cst_F <= rounded_cst;
end

// Round

assign PT_rounding = (start) ? PT : update_F;

// Perform Sbox

u_sbox sbox1 (PT_rounding[W-1 : 0], update[W-1 : 0]);
u_sbox sbox2 (PT_rounding[2*W-1 : W], update[2*W-1 : W]);
u_sbox sbox3 (PT_rounding[3*W-1 : 2*W], update[3*W-1 : 2*W]);
u_sbox sbox4 (PT_rounding[4*W-1 : 3*W], update[4*W-1 : 3*W]);

u_sbox sbox5 (PT_rounding[5*W-1 : 4*W], update[5*W-1 : 4*W]);
u_sbox sbox6 (PT_rounding[6*W-1 : 5*W], update[6*W-1 : 5*W]);
u_sbox sbox7 (PT_rounding[7*W-1 : 6*W], update[7*W-1 : 6*W]);
u_sbox sbox8 (PT_rounding[8*W-1 : 7*W], update[8*W-1 : 7*W]);

u_sbox sbox9 (PT_rounding[9*W-1 : 8*W], update[9*W-1 : 8*W]);
u_sbox sbox10 (PT_rounding[10*W-1 : 9*W], update[10*W-1 : 9*W]);
u_sbox sbox11 (PT_rounding[11*W-1 : 10*W], update[11*W-1 : 10*W]);
u_sbox sbox12 (PT_rounding[12*W-1 : 11*W], update[12*W-1 : 11*W]);

u_sbox sbox13 (PT_rounding[13*W-1 : 12*W], update[13*W-1 : 12*W]);
u_sbox sbox14 (PT_rounding[14*W-1 : 13*W], update[14*W-1 : 13*W]);
u_sbox sbox15 (PT_rounding[15*W-1 : 14*W], update[15*W-1 : 14*W]);
u_sbox sbox16 (PT_rounding[16*W-1 : 15*W], update[16*W-1 : 15*W]);

// Add constant

addConst addrndconst (update, rounded_cst, update_C);

// Add roundtweak

assign K1 = TK1_rounding[16*W-1 : 8*W];
assign K2 = TK2_rounding[16*W-1 : 8*W];
assign K3 = TK3_rounding[16*W-1 : 8*W]; 
assign tweak1 = K1 ^ K2;
assign K = tweak1 ^ K3;
assign update_CK[127:64] = update_C[127:64] ^ K;
assign update_CK[64-1 : 0] = update_C[64-1 : 0];

// ShiftRow

ShiftRows sr (update_CK, update_CKS);

// MixColumn

MixColumn mc (update_CKS, update_CKSM);

assign out = (done) ? update_F : {(128){1'b0}};

always @(posedge clk) begin
    update_F <= update_CKSM;
end
endmodule