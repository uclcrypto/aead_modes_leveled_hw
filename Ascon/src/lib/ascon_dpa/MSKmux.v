// Masked 2-input MUX (non-sensitive control signal).
`timescale 1ns / 1ps
module MSKmux #(parameter d=1, parameter count=1) (sel, in_true, in_false, out);

(* fv_type = "control" *) input sel;
(* syn_keep="true", keep="true", fv_type = "sharing", fv_latency = 0, fv_count=count *) input  [count*d-1:0] in_true;
(* syn_keep="true", keep="true", fv_type = "sharing", fv_latency = 0, fv_count=count *) input  [count*d-1:0] in_false;
(* syn_keep="true", keep="true", fv_type = "sharing", fv_latency = 0, fv_count=count *) output [count*d-1:0] out;

assign out = sel ? in_true : in_false;

endmodule
