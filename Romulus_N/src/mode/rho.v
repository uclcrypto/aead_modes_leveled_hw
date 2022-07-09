`timescale 1ns/1ps
module rho (state, message, new_state, ciphertext);

input [128-1:0] state, message;
output [128-1:0] new_state, ciphertext;

wire [128-1:0] permuted_state;

genvar j;
for (j = 0; j < 16; j = j + 1) begin
    assign permuted_state[8*j] = state[8*j + 1];
    assign permuted_state[8*j + 1] = state[8*j + 2];
    assign permuted_state[8*j + 2] = state[8*j + 3];
    assign permuted_state[8*j + 3] = state[8*j + 4];
    assign permuted_state[8*j + 4] = state[8*j + 5];
    assign permuted_state[8*j + 5] = state[8*j + 6];
    assign permuted_state[8*j + 6] = state[8*j + 7];
    assign permuted_state[8*j + 7] = state[8*j] ^ state[8*j + 7];
end

assign new_state = message ^ state;
assign ciphertext = permuted_state ^ message;

endmodule