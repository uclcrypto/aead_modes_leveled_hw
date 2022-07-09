`timescale 1ns/1ps
module tb();
// PARAMETERS
parameter D = 2;
localparam and_pini_mul_nrnd = D*(D-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;
parameter KEY_SIZE = 128;
parameter NONCE_SIZE = 128;
parameter BLK_SIZE = 128;
parameter RND_SIZE = 16*2*and_pini_nrnd;

// REGS
reg clk, rst, start, plaintext_valid, ciphertext_ready, ciphertext_last;
reg [KEY_SIZE-1:0] tweak1, tweak2;
reg [KEY_SIZE-1:0] key;
reg [NONCE_SIZE-1:0] nonce;
reg [BLK_SIZE-1:0] plaintext, init_state;
wire [BLK_SIZE*D-1:0] msk_plaintext, msk_init_state;
reg [$ceil(BLK_SIZE/8):0] plaintext_nbytes;
// WIRES
wire plaintext_ready, ciphertext_valid, finish;
wire [$ceil(BLK_SIZE/8):0] ciphertext_nbytes;
wire [RND_SIZE-1:0] rnd;
wire [BLK_SIZE-1:0] ciphertext;
wire [BLK_SIZE-1:0] tag;
wire [KEY_SIZE*D-1:0] msk_key;

// CLK GENERATION
localparam Tclk = 10;
localparam Tclkd = (Tclk/2.0);
always @(*) #(Tclk/2.0) clk <= ~clk;

// RANDOMNESS GENERATION
assign rnd = {(16*2*and_pini_nrnd){1'b1}};

// INSTANTIATION
MSKcst #(.d(D), .count(128)) msk_k (key, msk_key);
MSKcst #(.d(D), .count(128)) msk_initstate (init_state, msk_init_state);

cipher  #(.D(D), .KEY_SIZE(KEY_SIZE), .NONCE_SIZE(NONCE_SIZE), .BLK_SIZE(BLK_SIZE), .RND_SIZE(RND_SIZE)) dut (clk, rst, start, msk_key, tweak1, tweak2, nonce, plaintext, msk_init_state, rnd, plaintext_nbytes, plaintext_valid, plaintext_ready, ciphertext, tag, ciphertext_last, ciphertext_nbytes, ciphertext_valid, ciphertext_ready, finish);

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
	tweak2 = 128'hea23fb1553a96a09f684ca58ffc33ea7;
	key = 128'h544480d81a2483237c795768a7444ec3;
	init_state = 128'ha42757d2ace7ce858ba9b1a3215a899d;
	#10
	//init_state = 128'hX;
	start = 0;
	#5000
	plaintext_valid = 0;
	#8000
	plaintext_valid = 1;
	#5000
	ciphertext_last = 1;
end


always @(posedge clk) begin
	if(finish) begin
      	$display("Hello, World");
		$finish();
	end
end

endmodule