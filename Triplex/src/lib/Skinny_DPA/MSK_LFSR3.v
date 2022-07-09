`timescale 1ns / 1ps
module MSK_LFSR3 #(parameter d=2)(state, update);

(* syn_keep="true", keep="true", fv_type = "sharing", fv_latency = 0, fv_count=8 *) input [8*d - 1 : 0] state;
(* syn_keep="true", keep="true", fv_type = "sharing", fv_latency = 0, fv_count=8 *) output [8*d - 1 : 0] update;

MSKxor #(d) xor1 (state[d - 1 : 0], state [7*d - 1 : 6*d], update[8*d - 1 : 7*d]);
assign update[7*d - 1 : 0] = state[8*d - 1 : d];

endmodule
