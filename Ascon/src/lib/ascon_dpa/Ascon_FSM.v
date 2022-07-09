            module Ascon_FSM #(parameter d = 2) (
    start,
    clk,
    reset,
    rnd,
    in_K,
    done,
    out
);
localparam and_pini_mul_nrnd = D*(D-1)/2;
localparam and_pini_nrnd = and_pini_mul_nrnd;
    // INPUT
    (* fv_type="clock" *) input clk;
    (* fv_type="control" *) input start, reset;
    (* syn_keep = "true", keep = "true", fv_type = "random", fv_latency=0, fv_count = 1, fv_rnd_count_0 = 16*5*and_pini_nrnd, fv_rnd_lat_0 = 0 *) input [16*5*and_pini_nrnd-1:0] rnd;
    (* fv_type="control" *) input [320-1 : 0] in_K;

    // OUTPUT
    (* fv_type="control" *) output reg done;
    (* fv_type="sharing", fv_latency=72, fv_count=320 *) output [320*d-1:0] out;
    // REGS
    reg start_round, reset_round_cnt, done_f;
    reg sel1, sel2, sel_cst;
    reg [1:0] state, next_state;
    reg [3:0] cycle_cnt;
    reg [5:0] round_cnt;

    // WIRE 
    wire [320*d-1:0] out, in;

    // STATE DEFINITION
    `define IDLE 0
    `define PT 1
    `define COMPUTE 2

    // INSTANTIATION
    MSKcst #(.d(d), .count(320)) cstK (in_K, in);
    encrypt #(d) encrypt_ascon (clk, start, sel2, sel_cst, done, rnd, in, out);

always @(posedge clk) begin
    if (reset) begin
        state <=  `IDLE;
    end
    else begin
        state <= next_state;
    end
end 

always @(*) begin
    next_state = state;
    done = 0;
    sel1 = 0;
    sel2 = 0;
    start_round = 0;
    sel_cst = 0;
    reset_round_cnt = 0;
    case (state)
        `IDLE : begin
            if (start) begin
                next_state = `COMPUTE;
                reset_round_cnt = 1;
                sel1 = 1;
                sel2 = 1;
            end
        end
        `COMPUTE : begin
            if (cycle_cnt == 0) begin
                sel_cst = 1;
            end
            if (cycle_cnt == 5) begin
               sel1 = 0; 
               sel2 = 1;
               start_round = 1;
            end
            if (round_cnt == 11 & cycle_cnt == 5) begin
                next_state = `IDLE;
                done = 1;
                sel1 = 1;
                sel2 = 1;
                start_round = 1;
            end
        end
    endcase
end

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

endmodule