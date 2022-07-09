module MSK_PermC #(parameter d = 2) (
    state,
    roundcst,
    update
);
    parameter W = 64;

    input [5*W*d-1 : 0] state;
    input [8*d-1 : 0] roundcst;
    output [5*W*d-1 : 0] update;

    MSKxor #(.d(d), .count(8)) xor1 (state[136*d-1 : 128*d], roundcst, update[136*d-1 : 128*d]);

    assign update[5*W*d-1 : 136*d] = state[5*W*d-1 : 136*d];
    assign update[2*W*d-1 : 0] = state[2*W*d-1 : 0];

endmodule