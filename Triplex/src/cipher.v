`timescale 1ns/1ps
module cipher #(parameter
                  D = 2,
                  KEY_SIZE = 128,
                  NONCE_SIZE = 128,
                  BLK_SIZE = 128,
                  RND_SIZE = 32
                 )
  (
    input clk,  // CLOCK
    input rst,  // RESET
    input start,  // START
    input [KEY_SIZE*D-1:0] key, // MASKED KEY
    input [KEY_SIZE-1:0] pubkey,  // PUB KEY 
    input [NONCE_SIZE-1:0] nonce, // NONCE
    input [BLK_SIZE-1:0] plaintext,
    input [RND_SIZE-1:0] rnd,
    input plaintext_valid,

    output [BLK_SIZE-1:0] ciphertext,
    output reg [BLK_SIZE-1:0] tag,
    input ciphertext_last,
    output reg ciphertext_valid,
    input ciphertext_ready,
    output reg busy
  );

 // REGS AND WIRES
  reg start_dpa, reset_dpa, start_spa, reset_spa, last_spa;
  reg [KEY_SIZE*D-1:0] K_in_dpa; 
  reg [NONCE_SIZE-1:0] TK1_dpa, TK2_dpa;
  wire [BLK_SIZE-1:0] hi_xor, ki_xor;

  wire done_dpa, done_spa;
  // REGS
  reg[3:0] cycle_cnt;
  reg[5:0] round_cnt;
  reg [3:0] state, next_state;
  reg sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, sel_cipher, sel_theta1, sel_theta2;
  reg en2, en3, en4, en5, en_hi, en_ki, keep_cipher1, keep_cipher2;
  reg reset_round_cnt, start_round, sel_dpa, en_ci;
  wire en, flag_end;
  reg en_glitch, sel_1, sel_2, sel_init;
  reg [BLK_SIZE-1:0] spa_state_in, TK1, TK2, TK3, TK1_spa, TK2_spa, TK3_spa, state_in_spa;
  reg [BLK_SIZE*D-1:0] state_in_dpa, TK3_dpa;

  wire [1:0] theta2, theta1, theta_mux, theta_muxed, theta_xor;
  wire [6*D-1 : 0] init;
  wire [BLK_SIZE-1:0] ki_ok, c1i, state_cipher, state_in_spa_x, state_out_spa, u_state_out_dpa, spa_state_in_xored, spa_state_out, hi, ki, hi_init, ki_init, hi_mux, ci, ki_mux, hi_theta, ciphertext1_F, ciphertext2_F, ciphertext1, ciphertext2;
  wire [BLK_SIZE*D-1:0] state_out_dpa;


  assign theta2 = 2'b10;
  assign theta1 = 2'b01;
  assign flag_end = ciphertext_last & done_spa;
  // INITIALIZE hi ki
  assign theta_xor = sel_1 ? (sel_2 ? 2'b10 : 2'b01) : {2'b00};
  assign state_in_spa_x[1:0] = theta_xor ^ state_in_spa[1:0];
  assign state_in_spa_x[127:2] = state_in_spa[127:2];

  assign hi_mux = sel_init ? {(128){1'b0}} : hi;
  // COMPUTE hi AND ki
  assign hi_xor = hi_mux ^ state_out_spa;
  assign ki_xor = ki ^ state_out_spa;

  // REGEN BANK hi ki ci
  MSKregEn #(.d(1), .count(128)) reg_hi (clk, en_hi, hi_xor, hi);
  MSKregEn #(.d(1), .count(128)) reg_ki (clk, en_ki, TK3_spa, ki);
  MSKregEn #(.d(1), .count(128)) reg_ci (clk, en_ci, ciphertext, ci);
  MSKregEn #(.d(1), .count(128)) reg_c1i (clk, sel_2, ciphertext, c1i);


  MSKmux #(.d(1), .count(128)) mux_cipher (en_ki, hi, state_out_spa, state_cipher);
  assign ciphertext = plaintext ^ state_cipher;
  // FSM DPA INSTANTIATION 
  MSK_FSM #(D) dpa_skinny (clk, start_dpa, reset_dpa, rnd, TK1_dpa, TK2_dpa, K_in_dpa, state_in_dpa, state_out_dpa, done_dpa);
  // SPA INSTANTIATION
  FSM_skinny spa_skinny (clk, reset_spa, start_spa, last_spa, TK1_spa, TK2_spa, TK3_spa, state_in_spa_x, state_out_spa, done_spa);

  genvar i;
  generate
    for(i=0; i<128; i=i+1)
    begin
      assign u_state_out_dpa[i] = ^(state_out_dpa[D*(i+1)-1:D*i]);
    end
  endgenerate


  // FSM
  // STATE DEFINITION
`define IDLE 0
`define INIT_DPA 1
`define INIT_SPA1 2
`define INIT_SPA2 3
`define BULK_E1 4
`define BULK_E2 5
`define BULK_E3 6
`define STALL 7
`define FINAL 8

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

  assign en = start_round;

  always@(*)
  begin
    next_state = state;
    reset_round_cnt = 0;
    start_round = 0;
    en_glitch = 0;

    reset_dpa = 1;
    reset_spa = 1;
    start_dpa = 0;
    start_spa = 0;

    en_hi = 0;
    en_ki = 0;
    en_ci = 0;
    sel_dpa = 0;
    sel_1 = 0;
    sel_2 = 0;
    sel_init = 0;

    ciphertext_valid = 0;

    keep_cipher1 = 0;
    keep_cipher2 = 0;

    state_in_dpa = {(128*D){1'b0}};
    state_in_spa = {(128){1'b0}};

    TK1 = {(128){1'b0}};
    TK2 = {(128){1'b0}};
    TK3 = {(128){1'b0}};

    TK1_dpa = {(128){1'bX}};
    TK2_dpa = {(128){1'bX}};
    TK3_dpa = {(128){1'bX}};

    TK1_spa = {(128){1'bX}};
    TK2_spa = {(128){1'bX}};
    TK3_spa = {(128){1'bX}};

    busy = 1;
    case(state)

      `IDLE:
      begin
        if(start) // DPA start
        begin
          // GENERAL SIGNALS
          next_state = `INIT_DPA;
          // DPA SIGNALSu_state_out_dpa_F
          reset_dpa = 0;
          start_dpa = 1;
          state_in_dpa = nonce;
          K_in_dpa = key;
          TK1_dpa = {(128){1'b0}};
          TK2_dpa = pubkey;
          TK3_dpa = key;
        end
      end
      `INIT_DPA:
      begin
      reset_dpa = 0;
        if(done_dpa) begin
            start_spa = 1;
            reset_spa = 0;
            state_in_spa = {(128){1'b0}};
            TK1_spa = nonce;
            TK2_spa = pubkey;
            TK3_spa = u_state_out_dpa;
            next_state = `INIT_SPA1;
            // Mode
            en_ki = 1;
        end
      end
      `INIT_SPA1:
      begin
      reset_spa = 0;
      if(done_spa) 
        begin
          reset_spa = 0;
          state_in_spa = {(128){1'b0}};
          TK1_spa = nonce;
          TK2_spa = pubkey;
          TK3_spa = ki;
          next_state = `INIT_SPA2;
          // MODE
          en_hi = 1;
          sel_init = 1;
          sel_1 = 1;
        end
      end
      `INIT_SPA2:
      begin
        reset_spa = 0;
      if(done_spa) 
        begin
          reset_spa = 0;
          state_in_spa = hi;
          TK1_spa = nonce;
          TK2_spa = pubkey;
          TK3_spa = state_out_spa ^ {{(126){1'b0}}, theta2};
          next_state = `BULK_E1;
          // MODE
          en_ki = 1;
          sel_1 = 1;
          sel_2 = 1;
        end
      end
      `BULK_E1:
      begin
        reset_spa = 0;
      if(done_spa) 
        begin
          reset_spa = 0;
          state_in_spa = hi;
          TK1_spa = c1i;
          TK2_spa = ciphertext;
          TK3_spa = ki;
          next_state = `BULK_E2;
          // MODE
          en_ci = 1;
          ciphertext_valid = 1;
        end
      end
      `BULK_E2:
      begin
        reset_spa = 0;
      if(done_spa) 
        begin
          reset_spa = 0;
          state_in_spa = hi;
          TK1_spa = c1i;
          TK2_spa = ci;
          TK3_spa = ki;
          next_state = `BULK_E3;
          // MODE
          en_hi = 1;
          sel_1 = 1;
        end
      end
      `BULK_E3:
      begin
        reset_spa = 0;
      if(flag_end) 
        begin
          // GENERAL SIGNALS
          next_state = `FINAL;
          ciphertext_valid = 1;
          // DPA SIGNAL
          reset_dpa = 0;
          start_dpa = 1;
          state_in_dpa = {(128){1'b0}};
          K_in_dpa = key;
          TK1_dpa = hi;
          TK2_dpa = state_out_spa ^ ki;
          TK3_dpa = key;
        end
      else begin
      if(done_spa & (~ciphertext_ready | ~plaintext_valid)) 
        begin
          // GENERAL SIGNALS
          next_state = `STALL;
          // Save state
          TK3_spa = state_out_spa ^ ki;
          en_ki = 1;
          sel_1 = 1;
          sel_2 = 1;
        end
      else begin
      if(done_spa) 
        begin
          reset_spa = 0;
          state_in_spa = hi;
          TK1_spa = nonce;
          TK2_spa = pubkey;
          TK3_spa = state_out_spa ^ ki;
          next_state = `BULK_E1;
          // MODE
          en_ki = 1;
          sel_1 = 1;
          sel_2 = 1;
        end
      end
      end
      end
      `FINAL:
      begin
        reset_dpa = 0;
        if (done_dpa) 
        begin
          busy = 0;
          tag = u_state_out_dpa;
        end
      end
      `STALL:
      begin
        if (ciphertext_ready & plaintext_valid)
        begin
          start_spa = 1;
          reset_spa = 0;
          state_in_spa = hi;
          TK1_spa = nonce;
          TK2_spa = pubkey;
          TK3_spa = ki;
          next_state = `BULK_E1;
          // MODE
          sel_1 = 1;
          sel_2 = 1;
        end
      end
      default:
      begin
      end
    endcase
  end


  always @(posedge clk)
  begin
    if((state == `INIT_DPA | state == `FINAL) & ~start_round)
    begin
      cycle_cnt <= cycle_cnt + 1;
    end
    else
    begin
      cycle_cnt <= 0;
    end
  end

  always @(posedge clk)
  begin
    if(reset_round_cnt)
    begin
      round_cnt <= 0;
    end
    else if (start_round)
    begin
      round_cnt <= round_cnt + 1;
    end


  end

  //
  // primitive SPA
  // primitive DPA
  // routing datapath

endmodule
