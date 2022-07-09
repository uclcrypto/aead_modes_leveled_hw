`timescale 1ns / 1ps
module MSK_Sbox #(parameter d = 2) (clk, rnd, in, out);
localparam and_pini_mul_nrnd = d*(d-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;
// INPUT / OUTPUT
(* fv_type = "clock" *) input clk;
(* syn_keep = "true", keep = "true", fv_type = "random", fv_count = 5, 
fv_rnd_count_0 = and_pini_nrnd, fv_rnd_lat_0 = 0,
fv_rnd_count_1 = and_pini_nrnd, fv_rnd_lat_1 = 0,
fv_rnd_count_2 = and_pini_nrnd, fv_rnd_lat_2 = 0,
fv_rnd_count_3 = and_pini_nrnd, fv_rnd_lat_3 = 0,
fv_rnd_count_4 = and_pini_nrnd, fv_rnd_lat_4 = 0 *) input [5*and_pini_nrnd-1:0] rnd;
(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 0, fv_count = 5 *) input [5*d-1 : 0] in;
(* syn_keep = "true", keep = "true", fv_type = "sharing", fv_latency = 2, fv_count = 5 *) output [5*d-1 : 0] out;

// INTERMEDIATE VALUES
wire [d-1 : 0] s_0_x, s_0_xi, s_0_xia, s_0_xx;
wire [d-1 : 0] s_1_i, s_1_ia, s_1_x;
wire [d-1 : 0] s_2_x, s_2_xi, s_2_xx, s_2_xxi, s_2_xia;
wire [d-1 : 0] s_3_x, s_3_i, s_3_ix;
wire [d-1 : 0] s_4_x, s_4_xi, s_4_xia;
wire [d-1 : 0] in1_F, s_1_i_F, s_2_x_F, s_2_x_FF, s_2_xi_F, in3_F, s_0_x_F, s_0_x_FF, in1_FF, s_4_x_FF, s_4_x_F, in3_FF;
// PROCESSING

MSKxor #(d) xor1 (in[d-1 : 0], in[5*d-1 : 4*d], s_0_x);
MSKreg #(d) reg1 (clk, in[4*d-1: 3*d], in1_F);
MSKreg #(d) reg10 (clk, s_0_x, s_0_x_F);
MSKreg #(d) reg11 (clk, s_0_x_F, s_0_x_FF);
MSKinv #(d) inv1 (s_0_x, s_0_xi);
MSKand_HPC2 #(d) and1 (in1_F, s_0_xi, rnd[0 +: and_pini_nrnd], clk, s_0_xia);
MSKxor #(d) xor2 (s_0_x_FF, s_1_ia, s_0_xx);
MSKxor #(d) xor3 (s_0_xx, out[d-1 : 0], out[5*d-1 : 4*d]);

MSKinv #(d) inv2 (in[4*d-1 : 3*d], s_1_i);
MSKreg #(d) reg2 (clk, s_1_i, s_1_i_F);
MSKreg #(d) reg12 (clk, in1_F, in1_FF);
MSKand_HPC2 #(d) and2 (s_1_i_F, s_2_x, rnd[and_pini_nrnd +: and_pini_nrnd], clk, s_1_ia);
MSKxor #(d) xor4 (in1_FF, s_2_xia, s_1_x);
MSKxor #(d) xor5 (s_1_x, s_0_xx, out[4*d-1 : 3*d]);

MSKxor #(d) xor6 (in[4*d-1 : 3*d], in[3*d-1 : 2*d], s_2_x);
MSKinv #(d) inv3 (s_2_x_F, s_2_xi_F);
MSKxor #(d) xor7 (s_2_x_FF, s_3_ix, s_2_xx);
MSKinv #(d) inv4 (s_2_xx, out[3*d-1 : 2*d]);
MSKreg #(d) reg3 (clk, s_2_x, s_2_x_F);
MSKreg #(d) reg31 (clk, s_2_x_F, s_2_x_FF);
MSKand_HPC2 #(d) and3 (s_2_xi_F, in[2*d-1 : d], rnd[2*and_pini_nrnd +: and_pini_nrnd], clk, s_2_xia);

MSKxor #(d) xor8 (in3_FF, s_4_xia, s_3_x);
MSKxor #(d) xor9(s_3_x, s_2_xx, out[2*d-1 : d]);
MSKinv #(d) inv5(in3_F, s_3_i);
MSKreg #(d) reg4 (clk, in[2*d-1: d], in3_F);
MSKreg #(d) reg41 (clk, in3_F, in3_FF);
MSKand_HPC2 #(d) and4 (s_3_i, s_4_x, rnd[3*and_pini_nrnd +: and_pini_nrnd], clk, s_3_ix);

MSKxor #(d) xor10 (in[d-1 : 0], in[2*d-1 : d], s_4_x);
MSKreg #(d) reg42 (clk, s_4_x, s_4_x_F);
MSKreg #(d) reg43 (clk, s_4_x_F, s_4_x_FF);
MSKinv #(d) inv6 (s_4_x, s_4_xi);
MSKand_HPC2 #(d) and5 (s_0_x_F, s_4_xi, rnd[4*and_pini_nrnd +: and_pini_nrnd], clk, s_4_xia);
MSKxor #(d) xor11 (s_4_x_FF, s_0_xia, out[d-1 : 0]);


endmodule