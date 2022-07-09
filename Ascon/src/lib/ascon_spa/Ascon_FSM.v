`timescale 1ns/1ps
module Ascon_FSM (
    start,
    clk,
    reset,
    in,
    done,
    out
);

input start, reset;
input clk;
input [320-1:0] in;

output reg done;
output [320-1:0] out;

reg state, next_state;
reg start_round, reset_round_cnt;
reg sel1, sel2, sel_cst;
reg [5:0] cycle_cnt, round_cnt;
// STATE DEFINITION
`define IDLE 0
`define COMPUTE 1

encrypt_spa ascon_spa (clk, sel1, sel2, sel_cst, done, in, out);

always@(*) begin
    next_state = state;
    done = 0;
    sel1 = 0;
    sel2 = 0; 
    sel_cst = 0;
    start_round = 0;
    reset_round_cnt = 0;

    case(state)
        `IDLE: begin
            if(start) begin
                next_state = `COMPUTE;
                reset_round_cnt = 1;
                sel1 = 1;
                sel2 = 1;
            end
        end
        `COMPUTE: begin
            if(cycle_cnt == 0) begin
                sel_cst = 1;
            end
            if(cycle_cnt == 3) begin
                start_round = 1;
                sel2 = 1;
            end
            if (cycle_cnt == 3 & round_cnt == 11) begin
                done = 1;
                next_state = `IDLE;
                start_round = 1;

        end
        end
    endcase
end
// STATE EVOLUTION
always @(posedge clk) begin
    if (reset) begin
        state <=  `IDLE;
    end
    else begin
        state <= next_state;
    end
end 

// CYCLE COUNTER EVOLUTION
always @(posedge clk) begin
    if(state == `COMPUTE & ~start_round) begin
        cycle_cnt <= cycle_cnt + 1;
    end
    else begin
        cycle_cnt <= 0;
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

always@(done) begin
	if(done) begin
		#20
		$finish();
	end
end

endmodule