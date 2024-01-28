module cv32e40p_mult_voter
(
    input logic [31:0]  result_o1,
    input logic [31:0]  result_o2,
    input logic [31:0]  result_o3,
  
    input logic multicycle_o1,
    input logic multicycle_o2,
    input logic multicycle_o3,
    
    input logic mulhactive_o1,
    input logic mulhactive_o2,
    input logic mulhactive_o3,
    
    input logic ready_o1,
    input logic ready_o2,
    input logic ready_o3,

    output logic [31:0] result_o,
    output logic multicycle_o,
    output logic mulhactive_o,
    output logic ready_o,

    output logic faulty_o

);

logic faulty_o1, faulty_o2, faulty_o3, faulty_o4;

cv32e40p_voter_generic #(32) voter_1 (
    .res1(result_o1),
    .res2(result_o2),
    .res3(result_o3),
    .result_o(result_o),
    .faulty_o(faulty_o1)
  );

cv32e40p_voter voter_2 (
    .res1(multicycle_o1),
    .res2(multicycle_o2),
    .res3(multicycle_o3),
    .result_o(multicycle_o),
    .faulty_o(faulty_o2)
  );

cv32e40p_voter voter_3 (
    .res1(mulhactive_o1),
    .res2(mulhactive_o2),
    .res3(mulhactive_o3),
    .result_o(mulhactive_o),
    .faulty_o(faulty_o3)
  );

cv32e40p_voter voter_4 (
    .res1(ready_o1),
    .res2(ready_o2),
    .res3(ready_o3),
    .result_o(ready_o),
    .faulty_o(faulty_o4)
  );

assign faulty_o = faulty_o1 || faulty_o2 || faulty_o3 || faulty_o4;

endmodule
