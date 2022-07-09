module FSM_skinny(
    clk,
    reset,
    start,
    last,
    TK1,
    TK2,
    TK3,
    PT,
    CT,
    done
);

input clk, start, last, reset;
input [127:0] TK1, TK2, TK3, PT;
output done;
output [127:0] CT;

reg state, next_state, sel;
reg reset_round_cnt, done, start_round;
reg [6:0] round_cnt;

`define IDLE 0
`define COMPUTE 1

u_encrypt enc (clk, done, sel, TK1, TK2, TK3, PT, CT);


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
reset_round_cnt = 0;
start_round = 0;
sel = 0;
case(state)

	`IDLE: begin
		if(start) begin
			next_state = `COMPUTE;
            reset_round_cnt = 1;
            sel = 1;
		end
		
	end
	`COMPUTE: begin
        if (round_cnt == 38) begin
            done = 1;
            start_round = 1;
            sel = 1;
        end
        if (round_cnt == 38 & last) begin
            done = 1;
            next_state = `IDLE;
            start_round = 1;

        end
        else begin
            start_round = 1;
        end
	end
	default: begin

	end
endcase

end

always @(posedge clk) begin
if(reset_round_cnt | done) begin
	round_cnt <= 0;
end else if (start_round) begin
	round_cnt <= round_cnt + 1;
end
end

endmodule