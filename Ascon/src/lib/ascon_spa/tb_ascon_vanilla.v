`timescale 1ns / 1ps
module tb_ascon_vanilla ();

reg [319:0] in;
wire [319:0] out;
reg clk;

reg reset, start_dut;
wire done;
localparam Tclk = 10;
localparam Tclkd = (Tclk/2.0);
always @(*) #(Tclk/2.0) clk <= ~clk;

Ascon_FSM #(d) dut (start_dut, clk, reset, in, done, out);

initial begin
	$dumpfile ("test.vcd");
    $dumpvars (0, tb_ascon_vanilla);
    clk = 0;
    reset = 1;
    #40
    reset = 0;
    start_dut = 1;
    in = 320'h80400c0600000000000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f;
    #10 
    start_dut = 0;
    in = 320'hX;

end

always@(done) begin
	if(done) begin
		#20
		$finish();
	end
end
endmodule