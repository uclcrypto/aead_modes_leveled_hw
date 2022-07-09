module MSKinitState #(parameter d = 2) (
    K,
    N,
    cst,
    S
);
input [64*d-1 : 0] cst;
input [128*d-1 : 0] K, N;
output [320*d-1 : 0] S;

assign S = {cst, K, N};

endmodule