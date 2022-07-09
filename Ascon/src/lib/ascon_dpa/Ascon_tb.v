`timescale 1ns / 1ps
module Ascon_tb ();
`include "MSKand_HPC2.vh"

parameter d = 2;
parameter W = 64;
parameter L = 16;
parameter B = 80;

// WIRE
wire [320*d-1:0] out;

// REGS
reg clk;
reg start_dut, reset, started;
reg [16*5*and_pini_nrnd-1:0] rnd;
reg [10:0] counter;
reg [320-1:0] in;

wire [319:0] out_umsk;
// Clock generation
localparam Tclk = 10;
localparam Tclkd = (Tclk/2.0);
always @(*) #(Tclk/2.0) clk <= ~clk;

// Module instantiation
Ascon_FSM #(d) dut (start_dut, clk, reset, rnd, in, done, out);

// Simulation
initial begin
`ifdef VCD_PATH
                $dumpfile(`VCD_PATH);
`else
               $dumpfile("a.vcd");
`endif
		$dumpvars(0, Ascon_tb);
    clk = 0;
    reset = 1;
    #40
    reset = 0;
    start_dut = 1;
    started = 1;
    counter = 0;
    in = 320'h80400c0600000000000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f;
    rnd = {(16*5*and_pini_nrnd){1'b1}};
    #10 
    start_dut = 0;
    in = 640'hX;
end

// Cycle counter for timing purpose
always @(posedge clk) begin
    if(started) begin
        counter = counter + 1;
    end

end

always@(done) begin
	if(done) begin
		#20
		$finish();
	end
end
// Debug
  genvar j;
    generate
        for(j=0; j<320; j=j+1) begin
            assign out_umsk[j] = ^(out[d*(j+1)-1:d*j]);
        end
    endgenerate

endmodule