`timescale 1ns/1ps
module cipher #(parameter
     D = 2,
     KEY_SIZE = 128,
     NONCE_SIZE = 128,
     BLK_SIZE = 64,
     RND_SIZE = 80
)
(
     input clk,
     input rst,
     input start,
     input [KEY_SIZE*D-1:0] key,
     input [NONCE_SIZE-1:0] nonce,
     input [BLK_SIZE-1:0] plaintext,
     input [320*D-1:0] init_state,
     input [RND_SIZE-1:0] rnd,
     input plaintext_valid,
     output plaintext_ready,
     output [BLK_SIZE-1:0] ciphertext,
     output [128-1:0] tag,
     input ciphertext_last,
     output reg ciphertext_valid,
     input ciphertext_ready,
     output reg busy
);

// REG & WIRE
    reg start_round, reset_round_cnt, done_f, done_dpa, done_spa, en_stall, sel_key, sel_key_f;
    reg sel1, sel2, sel_cst, sel1_spa, sel2_spa, sel_cst_spa;
    reg [2:0] state, next_state;
    reg [3:0] cycle_cnt;
    reg [5:0] round_cnt;
    reg [320*D-1:0] state_in_dpa;
    wire [320*D-1:0] state_out_dpa, state_out_dpa_keyed;
    reg [320-1:0] state_in_spa;
    wire [128*D-1:0] key_muxed;
    wire [320-1:0] state_out_spa, state_out_dpa_umsk, stalled_state;
// INSTANTIATION
encrypt #(.d(D)) dpa_ascon (clk, sel1, sel2, sel_cst, done_dpa, rnd, state_in_dpa, state_out_dpa);

    genvar i;
    generate
        for(i=0; i<320; i=i+1) begin
            assign state_out_dpa_umsk[i] = ^(state_out_dpa[D*(i+1)-1:D*i]);
        end
    endgenerate

encrypt_spa spa_ascon (clk, sel1_spa, sel2_spa, sel_cst_spa, done_spa, state_in_spa, state_out_spa);

// CIPHERTEXT

assign ciphertext = plaintext ^ state_out_spa[0+:64];
// REG EN FOR STALL

MSKregEn #(.d(1), .count(320)) reg_stall (clk, en_stall, {ciphertext, state_out_spa[319:64]}, stalled_state);

// KEY XORING

always @(posedge clk) begin
    sel_key_f <= sel_key;
end

MSKmux #(.d(D), .count(128)) mux_key (sel_key_f, key, {(256){1'b0}}, key_muxed);
assign state_out_dpa_keyed[0 +: 256] = state_out_dpa[0 +:256] ^ key_muxed;
assign state_out_dpa_keyed[639:256] = state_out_dpa[639:256];
    genvar l;
    generate
        for(l=0; l<128; l=l+1) begin
            assign tag[l] = ^(state_out_dpa_keyed[D*(l+1)-1:D*l]);
        end
    endgenerate

// FSM 
// STATE DEFINITION

`define IDLE 0
`define INIT 1
`define FIRST_PT 2
`define BULK 3
`define FINAL 4
`define STALL 5

always @(*) begin
    next_state = state;
    done_dpa = 0;
    sel1 = 0;
    sel2 = 0;
    sel_key = 0;
    sel1_spa = 0;
    sel2_spa = 0;
    sel_cst_spa = 0;
    start_round = 0;
    sel_cst = 0;
    reset_round_cnt = 0;
    busy = 1;
    done_spa = 0;
    en_stall = 0;
    state_in_dpa = {(640){1'b0}};
    state_in_spa  = {(320){1'b0}};
case(state) 
    `IDLE: begin
        if(start) begin
            next_state = `INIT;
            reset_round_cnt = 1;
            sel1 = 1;
            sel2 = 1;
            state_in_dpa = init_state;
        end
    end
    `INIT: begin
        if (cycle_cnt == 0) begin
            sel_cst = 1;
        end
        if (cycle_cnt == 5) begin
            sel2 = 1;
           start_round = 1;
        end
        if (round_cnt == 11 & cycle_cnt == 5) begin
            next_state = `FIRST_PT;
            done_dpa = 1;
            sel2 = 1;
            start_round = 1;
            reset_round_cnt = 1;
        end
    end
    `FIRST_PT: begin
        if(round_cnt == 0 & cycle_cnt == 0) begin
            sel1 = 1;
            sel2 = 1;
            state_in_spa = state_out_dpa_umsk;
            sel1_spa = 1;
            sel2_spa = 1;
            sel_cst_spa = 1;
        end
        if(cycle_cnt == 3) begin
            start_round = 1;
            sel2_spa = 1;
        end
        if(cycle_cnt == 3 & round_cnt == 11) begin
            done_spa = 1;
            start_round = 1;
            reset_round_cnt = 1;
            en_stall = 1;
        end
        if (cycle_cnt == 3 & round_cnt == 11 & ~(ciphertext_ready & plaintext_valid)) begin
            next_state = `STALL;
            en_stall = 1;
        end
        if (cycle_cnt == 3 & round_cnt == 11 & ciphertext_ready & plaintext_valid) begin
            next_state = `BULK;
            reset_round_cnt = 1;
        end
        if(cycle_cnt == 3 & round_cnt == 11 & ciphertext_last) begin
            next_state = `FINAL;
            state_in_dpa = {ciphertext, state_out_spa[319:64]};
            reset_round_cnt = 1;
            sel1 = 1;
            sel2 = 1;
        end
    end
    `BULK: begin
        if(round_cnt == 0 & cycle_cnt == 0) begin
            state_in_spa = {ciphertext, stalled_state[319:64]};
            sel1_spa = 1;
            sel2_spa = 1;
            sel_cst_spa = 1;
        end
        if(cycle_cnt == 3) begin
            start_round = 1;
            sel2_spa = 1;
        end
        if(cycle_cnt == 3 & round_cnt == 11) begin
            done_spa = 1;
            start_round = 1;
            reset_round_cnt = 1;
            en_stall = 1;
        end
        if (cycle_cnt == 3 & round_cnt == 11 & ~(ciphertext_ready & plaintext_valid)) begin
            next_state = `STALL;
            en_stall = 1;
        end
        if (cycle_cnt == 3 & round_cnt == 11 & ciphertext_ready & plaintext_valid) begin
            state_in_spa = {ciphertext, state_out_spa[319:64]};
        end
        if(cycle_cnt == 3 & round_cnt == 11 & ciphertext_last) begin
            next_state = `FINAL;
            state_in_dpa = {ciphertext, state_out_spa[319:64]};
            reset_round_cnt = 1;
            sel1 = 1;
            sel2 = 1;
        end
    end
    `FINAL: begin
        if (cycle_cnt == 0) begin
            sel_cst = 1;
        end
        if (cycle_cnt == 5) begin
            sel2 = 1;
           start_round = 1;
        end
        if (round_cnt == 11 & cycle_cnt == 5) begin
            next_state = `IDLE;
            done_dpa = 1;
            sel2 = 1;
            start_round = 1;
            reset_round_cnt = 1;
            sel_key = 1;
            busy = 0;
        end
    end
    `STALL: begin
        if (ciphertext_ready == 1 & plaintext_valid == 1) begin
            next_state = `BULK;
        end
    end
endcase
end
// STATE EVOLUTION
always @ (posedge clk) begin
	if(rst) begin
		state <= `IDLE; 
	end
	else begin
		state <= next_state;
	end
end

// ROUND COUNTER EVOLUTION
always @(posedge clk) begin
if(reset_round_cnt) begin
	round_cnt <= 0;
end else if (start_round) begin
	round_cnt <= round_cnt + 1;
end
end

// CYCLE COUNTER EVOLUTION
always @(posedge clk) begin
if((state == `INIT | state == `BULK | state == `FINAL | state == `FIRST_PT) & ~start_round) begin
	cycle_cnt <= cycle_cnt + 1;
end 
else begin
	cycle_cnt <= 0;
	end
end

endmodule