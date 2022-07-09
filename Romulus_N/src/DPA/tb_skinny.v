`timescale 1ns / 1ps
module tb_skinny();
localparam and_pini_mul_nrnd = d*(d-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;
parameter d = 2;

reg clk, start_dut, reset, last;
reg [10:0] cnt;
reg started;
wire [16*2*and_pini_nrnd-1:0] rnd;
reg [127:0] TK1, TK2, K;
reg [384*d-1 : 0] TK;
wire [128*d-1 : 0] msk_K, msk_PT;
reg [128-1 : 0] PT;
wire[128*d-1 : 0] msk_CT;
wire[127 : 0] CT;
wire done;

localparam Tclk = 10;
localparam Tclkd = (Tclk/2.0);

always @(*) #(Tclk/2.0) clk <= ~clk;

//MSK_Tweak #(d) Tweak1 (sel, en, clk, TK, TK1, TK2, TK3);
assign rnd = {(16*2*and_pini_nrnd){1'b1}};

MSKcst #(.d(d), .count(128)) cstPT (PT, msk_PT);
MSKcst #(.d(d), .count(128)) cstTK2 (K, msk_K);
MSK_FSM #(d) dut (clk, start_dut, reset, last, rnd, TK1, TK2, msk_K, msk_PT, msk_CT, done);
 
initial begin
`ifdef VCD_PATH
                $dumpfile(`VCD_PATH);
`else
               $dumpfile("waveform.vcd");
`endif
		$dumpvars(0, tb_skinny);

	//#5
	reset = 1;
	clk = 0;
	cnt = 0;
	start_dut = 0;
	started = 0;
	last = 0;
	#20 
	reset = 0;
	#20
	start_dut = 1;
	started = 1;
	TK1 = 128'hea135685849431216bee303e087f8a46;
	TK2 = 128'hea23fb1553a96a09f684ca58ffc33ea7;
	K = 128'h544480d81a2483237c795768a7444ec3;
	PT = 128'ha42757d2ace7ce858ba9b1a3215a899d;
	#10
	PT = 128'hX;
	start_dut = 0;
end

always@(done) begin
	if(done) begin
		#20
		$finish();
	end
end

always@(posedge clk) begin
	if(started) begin
		cnt = cnt + 1;
	end
end



genvar o;
generate
	for(o=0; o<128; o=o+1) begin
		assign CT[o] = ^(msk_CT[d*(o+1)-1:d*o]);
	end
endgenerate


endmodule