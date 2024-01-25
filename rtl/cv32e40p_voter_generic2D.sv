module cv32e40p_voter_generic2D
import cv32e40p_pkg::*;
#(
    parameter N_PMP_ENTRIES = 16,
    parameter WIDTH = 32
)
(
    input logic [N_PMP_ENTRIES-1:0][WIDTH-1:0] res1,
    input logic [N_PMP_ENTRIES-1:0][WIDTH-1:0] res2,
    input logic [N_PMP_ENTRIES-1:0][WIDTH-1:0] res3,
    output logic [N_PMP_ENTRIES-1:0][WIDTH-1:0] result_o
);

function automatic logic compareArrays(logic [N_PMP_ENTRIES-1:0][WIDTH-1:0] a, logic [N_PMP_ENTRIES-1:0][WIDTH-1:0] b);
    for (int i = 0; i < N_PMP_ENTRIES-1; i++)
      for (int j = 0; j < WIDTH-1; j++)
        if (a[i][j] != b[i][j])
          return 0; // Arrays are not equal
    return 1; // Arrays are equal
endfunction

    // behavioral implementation
    always_comb begin
        if(compareArrays(res1, res2)) begin
            result_o <= res1;
        end
        else begin
            result_o <= res3;
        end
    end
endmodule


