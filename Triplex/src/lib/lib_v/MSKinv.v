// Masked NOT gate
`timescale 1ns/1ps
module MSKinv #(parameter d=2, parameter count=1) (in, out);

(* syn_keep="true", keep="true", fv_type = "sharing", fv_latency = 0, fv_count=count *) input  [count*d-1:0] in;
(* syn_keep="true", keep="true", fv_type = "sharing", fv_latency = 0, fv_count=count *) output [count*d-1:0] out;

genvar i;
generate
for(i=0; i<count; i=i+1) begin: inv
    assign out[i*d] = ~in[i*d];
    if (d > 1) begin
        assign out[i*d+1 +: d-1] = in[i*d+1 +: d-1];
    end
end
endgenerate

endmodule
