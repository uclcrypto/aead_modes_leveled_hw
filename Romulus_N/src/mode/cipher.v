`timescale 1ns/1ps
module cipher #(parameter
                  D = 2,
                  KEY_SIZE = 128,
                  NONCE_SIZE = 128,
                  BLK_SIZE = 128,
                  RND_SIZE = 32
                 )
  (
    input clk,
    input rst,
    input start,
    input [KEY_SIZE*D-1:0] key,
    input [KEY_SIZE-1:0] tweak1,
    input [KEY_SIZE-1:0] tweak2,
    input [NONCE_SIZE-1:0] nonce,
    input [BLK_SIZE-1:0] plaintext,
    input [BLK_SIZE*D-1:0] init_state,
    input [RND_SIZE-1:0] rnd,
    // Number of valid bytes in the plaintext block,
    // MUST be equal to BLK_SIZE/8 for all blocks except the last block, for
    // which it must be at most BLK_SIZE/8-1 (it may be 0).
    input [$ceil(BLK_SIZE/8):0] plaintext_nbytes,
    input plaintext_valid,
    output plaintext_ready,

    output [BLK_SIZE-1:0] ciphertext,
    output [BLK_SIZE-1:0] tag,

    input ciphertext_last,
    // Number of valid bytes in the ciphertext blocks,
    output [$ceil(BLK_SIZE/8):0] ciphertext_nbytes,
    output reg ciphertext_valid,
    input ciphertext_ready,

    output reg finish
  );

// REGS AND WIRES
reg start_dpa, reset_dpa, last_dpa, en, sel, en_stall;
reg [2:0] state, next_state;
reg [BLK_SIZE-1:0] TK1_dpa, TK2_dpa, rho_state, rho_message;
reg [BLK_SIZE*D-1:0] K_in, state_in_dpa, TK3_dpa;

wire done_dpa;
wire [8-1:0] B;
wire [56-1:0] D_lfsr;
wire [BLK_SIZE-1:0] rhoed_ciphertext, rhoed_state, u_state_out_dpa, stalled_state;
wire [BLK_SIZE*D-1:0] state_out_dpa, msk_rho_state;

assign B = 8'b00010101;
lfsr_D lsfr (clk, sel, en, D_lfsr);
rho rho_abs (rho_state, rho_message, rhoed_state, rhoed_ciphertext);
assign ciphertext = rhoed_ciphertext;
MSK_FSM #(.d(D)) encrypt (clk, start_dpa, reset_dpa, last_dpa, rnd, TK1_dpa, TK2_dpa, TK3_dpa, state_in_dpa, state_out_dpa, done_dpa);
MSKcst #(.d(D), .count(128)) cst_state (rhoed_state, msk_rho_state);

// STATE STALLING
MSKregEn #(.d(1), .count(128)) stall_state (clk, en_stall, rhoed_state, stalled_state);

// UNMASKING
genvar i;
generate
  for(i=0; i<128; i=i+1)
  begin
    assign u_state_out_dpa[i] = ^(state_out_dpa[D*(i+1)-1:D*i]);
  end
endgenerate

  // STATE DEFINITION
`define IDLE 0
`define COMPUTE_INIT 1
`define COMPUTE_MESSAGE 2
`define COMPUTE_FINAL 3
`define STALL 4

always @ (posedge clk)
begin
    if(rst)
    begin
        state <= `IDLE;
    end
    else
    begin
        state <= next_state;
    end
end

always@(*)
begin

next_state = state;
start_dpa = 0;
last_dpa = 0;
reset_dpa = 1;
finish = 0; 
en = 0;
sel = 0;
en_stall = 0;

TK1_dpa = {(128){1'b0}};
TK2_dpa = {(128){1'b0}};
TK3_dpa = {(128*D){1'b0}};

rho_state = {(128){1'b0}};
rho_message = {(128){1'b0}};

state_in_dpa = {(128){1'b0}};

case(state)
 `IDLE: begin
    if(start) begin
      // Compute RHO
      rho_state = {(128){1'b0}};
      rho_message = {(128){1'b0}};
      // Compute DPA
      start_dpa = 1;
      reset_dpa = 0;
      next_state = `COMPUTE_INIT;
      state_in_dpa = msk_rho_state;
      TK1_dpa = nonce;
      TK2_dpa = {D_lfsr, B};
      TK3_dpa = key;
      en = 1;
      sel = 1;
    end
 end
 `COMPUTE_INIT: begin
    reset_dpa = 0;
    if (done_dpa) begin
      // Compute RHO
      rho_state = u_state_out_dpa;
      rho_message = plaintext;
      // Compute DPA
      reset_dpa = 0;
      state_in_dpa = msk_rho_state;
      TK1_dpa = nonce;
      TK2_dpa = {D_lfsr, B};
      TK3_dpa = key;
      next_state = `COMPUTE_MESSAGE;
      en = 1;
    end
 end
 `COMPUTE_MESSAGE: begin
    reset_dpa = 0;
    if (done_dpa & ciphertext_last) begin
      // Compute RHO
      rho_state = u_state_out_dpa;
      rho_message = plaintext;
      // Compute DPA
      reset_dpa = 0;
      state_in_dpa = msk_rho_state;
      TK1_dpa = nonce;
      TK2_dpa = {D_lfsr, B};
      TK3_dpa = key;
      next_state = `COMPUTE_FINAL;
      en = 1;
    end
    if (done_dpa & (~ciphertext_ready | ~plaintext_valid)) begin
      // Compute RHO
      rho_state = u_state_out_dpa;
      rho_message = plaintext;
      // Stall
      next_state = `STALL;
      en_stall = 1;
    end
    if (done_dpa) begin
      // Compute RHO
      rho_state = u_state_out_dpa;
      rho_message = plaintext;
      // Compute DPA
      reset_dpa = 0;
      state_in_dpa = msk_rho_state;
      TK1_dpa = nonce;
      TK2_dpa = {D_lfsr, B};
      TK3_dpa = key;
      en = 1;
    end
 end
 `COMPUTE_FINAL: begin
    reset_dpa = 0;
    if (done_dpa) begin
      // Compute RHO
      rho_state = u_state_out_dpa;
      rho_message = plaintext;
      // Compute DPA
      reset_dpa = 1;
      next_state = `IDLE;
      en = 1;
      finish = 1;
    end
 end
 `STALL: begin
    if (plaintext_valid & ciphertext_ready) begin
      // Compute RHO
      rho_state = stalled_state;
      rho_message = plaintext;
      // Compute DPA
      start_dpa = 1;
      reset_dpa = 0;
      next_state = `COMPUTE_MESSAGE;
      state_in_dpa = msk_rho_state;
      TK1_dpa = nonce;
      TK2_dpa = {D_lfsr, B};
      TK3_dpa = key;
      en = 1;
    end
 end
endcase
end

endmodule