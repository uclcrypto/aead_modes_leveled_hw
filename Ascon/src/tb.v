`timescale 1ns/1ps
module tb();
// PARAMETERS
parameter D = 2;
localparam and_pini_mul_nrnd = D*(D-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;
parameter KEY_SIZE = 128;
parameter NONCE_SIZE = 128;
parameter BLK_SIZE = 64;
parameter RND_SIZE = 16*5*and_pini_nrnd;

// REGS
reg clk, rst, start, ciphertext_ready, ciphertext_last, plaintext_valid;
reg [KEY_SIZE-1:0] pubkey;
reg [KEY_SIZE-1:0] key;
reg [NONCE_SIZE-1:0] nonce;
reg [320-1:0] init_state;
reg [BLK_SIZE-1:0] plaintext;
wire [BLK_SIZE*D-1:0] msk_plaintext;
reg [$ceil(BLK_SIZE/8):0] plaintext_nbytes;
// WIRES
wire plaintext_ready, ciphertext_valid, busy;
wire [$ceil(BLK_SIZE/8):0] ciphertext_nbytes;
wire [128-1:0] tag;
wire [RND_SIZE-1:0] rnd;
wire [BLK_SIZE-1:0] ciphertext;
wire [KEY_SIZE*D-1:0] msk_key;
wire [320*D-1:0] msk_init_state;
// CLK GENERATION
localparam Tclk = 10;
localparam Tclkd = (Tclk/2.0);
always @(*) #(Tclk/2.0) clk <= ~clk;
// RANDOMNESS GENERATION
assign rnd = {(16*5*and_pini_nrnd){1'b1}};
// INSTANTIATION
MSKcst #(.d(D), .count(128)) msk_k (key, msk_key);
MSKcst #(.d(D), .count(320)) msk_initstate (init_state, msk_init_state);
cipher  #(.D(D), .KEY_SIZE(KEY_SIZE), .NONCE_SIZE(NONCE_SIZE), .BLK_SIZE(BLK_SIZE), .RND_SIZE(RND_SIZE)) dut (clk, rst, start, msk_key, nonce, plaintext, msk_init_state, rnd, plaintext_valid, plaintext_ready, ciphertext, tag, ciphertext_last, ciphertext_valid, ciphertext_ready, busy);
// SIGNAL INPUT
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb);
	rst = 1;
	clk = 0;
	ciphertext_last = 0;
	start = 0;
	#20 
	rst = 0;
	#20
	start = 1;
	plaintext_valid = 1;
	ciphertext_ready = 1;
	plaintext = {(128){1'b0}};
	nonce = 128'hea135685849431216bee303e087f8a46;
	pubkey = 128'hea23fb1553a96a09f684ca58ffc33ea7;
	key = 128'h544480d81a2483237c795768a7444ec3;
	init_state = 320'h80800c0800000000000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f;
	#10
	init_state = 128'hX;
	start = 0;
	#5000
	ciphertext_ready = 0;
	#1000
	ciphertext_ready = 1;
	#1000
	ciphertext_last = 1;
end

always @(negedge busy) begin
	if(~busy) begin
		#20
		$finish();
	end
end

endmodule

