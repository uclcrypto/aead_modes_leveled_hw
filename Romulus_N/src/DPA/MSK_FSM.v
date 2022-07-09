`timescale 1ns / 1ps
module MSK_FSM #(parameter d = 2) (clk, start, reset, last, rnd, TK1, TK2, K_in, PT_in, CT, done);

localparam and_pini_mul_nrnd = d*(d-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;
(* fv_type="clock" *) input clk;
(* fv_type="control" *) input start;
(* fv_type="control" *) input reset, last;
(* syn_keep = "true", keep = "true", fv_type = "random", fv_latency=0, fv_count = 1, fv_rnd_count_0 = 16*8*and_pini_nrnd, fv_rnd_lat_0 = 0 *) input [16*2*and_pini_nrnd-1:0] rnd;
(* fv_type="control" *) input [127:0] TK1, TK2;
(* fv_type="sharing" *) input [128*d-1 : 0] K_in;
(* fv_type="control" *) input [128*d-1 : 0] PT_in;
(* fv_type="control" *) output reg done;
(* fv_type="sharing", fv_latency=240, fv_count=128 *) output [128*d-1 : 0] CT;

reg[3:0] cycle_cnt;
reg[5:0] round_cnt;
reg state, next_state;
reg sel, reset_round_cnt, start_round;
wire en;
reg en_glitch;
wire [6*d-1 : 0] init;
reg [56*d-1 : 0] D;
wire [128*d-1:0] K;

reg sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2;
reg en2, en3, en4, en5;


`define IDLE 0
`define COMPUTE 1

assign en = start_round;

//STATE ATTRIBUTES (define)
// IDLE 00
// SBOX 01
// CL  10

//MSK_TweakGen #(d) tweakgen(B, D, T, K, TK);

MSKskinny_encrypt #(d) skinnyfsm (clk, en2, en3, en4, en5, sel1a1, sel2a1, sel1b1, sel2b1, sel1x1, sel2x1, sel1a2, sel1b2, sel1x2, sel2a2, sel2b2, sel2x2, sel, en, en_glitch, done, rnd, init, TK1, TK2, K_in, PT_in, CT);

MSKcst #(.d(d), .count(6)) cstinit ({(6){1'b0}}, init);

always @ (posedge clk) begin
	if(reset) begin
		state <= `IDLE; 
	end
	else begin
		state <= next_state;
	end
end

always@(*)begin
next_state = state;
done = 0;
sel = 0; 
reset_round_cnt = 0;
start_round = 0;
en_glitch = 0;

sel1a1 = 0;
sel2a1 = 0;
sel1b1 = 0;
sel2b1 = 0;
sel1x1 = 0;
sel2x1 = 0;
sel1a2 = 0;
sel2a2 = 0;
sel1b2 = 0;
sel2b2 = 0;
sel1x2 = 0;
sel2x2 = 0;

en2 = 0;
en3 = 0;
en4 = 0;
en5 = 0;

case(state)

	`IDLE: begin
		if(start) begin
			next_state = `COMPUTE;
			start_round = 1;
			reset_round_cnt = 1;
			sel = 1;

		end
		
	end
	`COMPUTE: begin
		if(round_cnt == 39 & cycle_cnt == 5 & last) begin
			next_state = `IDLE;
			done = 1; 
			sel = 1;
			start_round = 1;
            sel1x2 = 1;
            sel2x2 = 1;
            start_round = 1;

		end
		else begin
		if(round_cnt == 39 & cycle_cnt == 5) begin
			done = 1;
			sel = 1;
			start_round = 1;
            sel1x2 = 1;
            sel2x2 = 1;
            start_round = 1;
			reset_round_cnt = 1;

		end
		else begin
		if(round_cnt == 39 & cycle_cnt == 5) begin
			next_state = `IDLE;
			done = 1; 
			sel = 1;
			start_round = 1;
            sel1x2 = 1;
            sel2x2 = 1;
            start_round = 1;
    

		end
		if(cycle_cnt == 0) begin


            sel1b1 = 1;

        end
		else begin
		if (cycle_cnt == 1) begin
            sel2b1 = 1;
            sel1a1 = 1;
		    sel1b2 = 1;

            en2 = 1;
		end
		else begin
		if (cycle_cnt == 2) begin
            sel2b2 = 1;

            sel1b1 = 1;
            sel2b1 = 1;
            sel2a1 = 1;
            sel1x1 = 1;
            sel1a2 = 1;
            en3 = 1;

		end
        else begin
        if(cycle_cnt == 3) begin

            sel1a1 = 1;
            sel2a1 = 1;
            sel2x1 = 1;
            sel1b2 = 1;
            sel2b2 = 1;
            sel2a2 = 1;
            sel1x2 = 1;
            en4 = 1;

		end
		else begin
		if(cycle_cnt == 4) begin


           sel1x1 = 1;
            sel2x1 = 1;
        sel1a2 = 1;
            sel2a2 = 1;
            sel2x2 = 1;
            en5 = 1;

			en_glitch = 1;

		end
		else begin
		if(cycle_cnt == 5) begin
            sel1x2 = 1;
            sel2x2 = 1;
            start_round = 1;
    


		end
		end
		end
		end
		end
		end
		end
		end
	end
	default: begin

	end
endcase

end

always @(posedge clk) begin
if((state == `COMPUTE) & ~start_round) begin
	cycle_cnt <= cycle_cnt + 1;
end 
else begin
	cycle_cnt <= 0;
	end
end

always @(posedge clk) begin
if(reset_round_cnt) begin
	round_cnt <= 0;
end else if (start_round) begin
	round_cnt <= round_cnt + 1;
end


end




/*

	if (start) begin
		state <= 2'b01;
		sel <= 1;
		sel_t <= 1;
		done <= 0;
		en <= 1;
	end
	else begin
	if (round_cnt == 6'b100111) begin
		state <= 2'b11;
	end
	else begin 
	if (cycle_cnt == 4'b0100) begin
		state <= 2'b01;
		cycle_cnt <= 4'b0;
	end
	else begin
	if (state == 2'b01) begin
		state <= 2'b10;
		round_cnt <= round_cnt + 1;
	end
	else begin
	if (state == 2'b10) begin
		cycle_cnt <= cycle_cnt + 1;
	end
	else begin
	if (state == 2'b00) begin
		state <= 2'b10;
	end
	else begin
	if (start) begin
		cycle_cnt <= 4'b0;
		round_cnt <= 6'b0;
		state <= 2'b00;
	end
	end
	end
	end
	end
	end
	end
end







always @ (posedge clk) begin
case(state)
	2'b00: // START
	begin
		sel <= 1;
		sel_t <= 1;
		done <= 0;
		en <= 1;
	end
	2'b01: // AC ART
	begin
		en <= 1;
	end
	2'b10: // SBOX
	begin
		en <= 0;
		sel <= 0;
		sel_t <= 0;
	end
	2'b11: // STOP
	begin
		done <= 1;
	end
endcase
end
//STATE EVOLUTION
always@(posedge clk)begin
	if (start) begin
		state <= 2'b01;
		sel <= 1;
		sel_t <= 1;
		done <= 0;
		en <= 1;
	end
	else begin
	if (round_cnt == 6'b100111) begin
		state <= 2'b11;
	end
	else begin 
	if (cycle_cnt == 4'b0100) begin
		state <= 2'b01;
		cycle_cnt <= 4'b0;
	end
	else begin
	if (state == 2'b01) begin
		state <= 2'b10;
		round_cnt <= round_cnt + 1;
	end
	else begin
	if (state == 2'b10) begin
		cycle_cnt <= cycle_cnt + 1;
	end
	else begin
	if (state == 2'b00) begin
		state <= 2'b10;
	end
	else begin
	if (start) begin
		cycle_cnt <= 4'b0;
		round_cnt <= 6'b0;
		state <= 2'b00;
	end
	end
	end
	end
	end
	end
	end
end

*/

endmodule