module cv32e40p_register_file_ff_hamming #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 32, 
    parameter FPU        = 0,
    parameter ZFINX      = 0
) (
    // Clock and Reset
    input logic clk,
    input logic rst_n,

    input logic scan_cg_en_i_RFHAM,

    //Read port R1
    input  logic [ADDR_WIDTH-1:0] raddr_a_i_RFHAM,
    output logic [DATA_WIDTH-1:0] rdata_a_o_RFHAM,

    //Read port R2
    input  logic [ADDR_WIDTH-1:0] raddr_b_i_RFHAM,
    output logic [DATA_WIDTH-1:0] rdata_b_o_RFHAM,

    //Read port R3
    input  logic [ADDR_WIDTH-1:0] raddr_c_i_RFHAM,
    output logic [DATA_WIDTH-1:0] rdata_c_o_RFHAM,

    // Write port W1
    input logic [ADDR_WIDTH-1:0] waddr_a_i_RFHAM,
    input logic [DATA_WIDTH-1:0] wdata_a_i_RFHAM,
    input logic                  we_a_i_RFHAM,

    // Write port W2
    input logic [ADDR_WIDTH-1:0] waddr_b_i_RFHAM,
    input logic [DATA_WIDTH-1:0] wdata_b_i_RFHAM,
    input logic                  we_b_i_RFHAM,

    //my added primary outputs (indication about double data error detection from RF check)
    output logic RF_DED_1,
    output logic RF_DED_2,
    output logic RF_DED_3
);


//MY ADDITIONS INTERNAL SIGNALS FOR HAMMING
  logic [ 37:0]      hamming_code_signal_1 ;
  logic [ 37:0]      hamming_code_signal_2 ;

  logic [ 37:0]      recomputed_ham_code_signal_1 ;
  logic [ 37:0]      recomputed_ham_code_signal_2 ;
  logic [ 37:0]      recomputed_ham_code_signal_3 ;

  logic [ 37:0]      regfile_data_ra_id_preCheck ;
  logic [ 37:0]      regfile_data_rb_id_preCheck ;
  logic [ 37:0]      regfile_data_rc_id_preCheck ;

////////////////////////////////my ADDITION OF HAMMING CODE GENERATOR//////////////////////////////////////////////////////

//for first write port

cv32e40p_hammingGenerator hamming_generator_1 (
    .data_in(wdata_a_i_RFHAM),         
    .hamming_code(hamming_code_signal_1) // 
);

//for second write port

cv32e40p_hammingGenerator hamming_generator_2 (
    .data_in(wdata_b_i_RFHAM),         
    .hamming_code(hamming_code_signal_2) 
);


  cv32e40p_register_file_ff #(
      .ADDR_WIDTH(6),
      .DATA_WIDTH(38),
      .FPU       (FPU),
      .ZFINX     (ZFINX)
  ) register_file_ff_i (
      .clk  (clk),
      .rst_n(rst_n),

      .scan_cg_en_i(scan_cg_en_i_RFHAM),

      // Read port a
      .raddr_a_i(raddr_a_i_RFHAM),
      .rdata_a_o(regfile_data_ra_id_preCheck),

      // Read port b
      .raddr_b_i(raddr_b_i_RFHAM),
      .rdata_b_o(regfile_data_rb_id_preCheck),

      // Read port c
      .raddr_c_i(raddr_c_i_RFHAM),
      .rdata_c_o(regfile_data_rc_id_preCheck),

      // Write port a
      .waddr_a_i(waddr_a_i_RFHAM),
      .wdata_a_i(hamming_code_signal_1),
      .we_a_i   (we_a_i_RFHAM),

      // Write port b
      .waddr_b_i(waddr_b_i_RFHAM),
      .wdata_b_i(hamming_code_signal_2),
      .we_b_i   (we_b_i_RFHAM)
  );

//for first read port, for recomputation of parity bits

cv32e40p_hammingGenerator hamming_generator_3 (
    .data_in({regfile_data_ra_id_preCheck[37:32], regfile_data_ra_id_preCheck[30:16], regfile_data_ra_id_preCheck[14:8], regfile_data_ra_id_preCheck[6:4], regfile_data_ra_id_preCheck[2]} ),         
    .hamming_code(recomputed_ham_code_signal_1) 
);

//for second read port, for recomputation of parity bits

cv32e40p_hammingGenerator hamming_generator_4 (
    .data_in({regfile_data_rb_id_preCheck[37:32], regfile_data_rb_id_preCheck[30:16], regfile_data_rb_id_preCheck[14:8], regfile_data_rb_id_preCheck[6:4], regfile_data_rb_id_preCheck[2]} ),         
    .hamming_code(recomputed_ham_code_signal_2) 
);

//for third read port, for recomputation of parity bits

cv32e40p_hammingGenerator hamming_generator_5 (
    .data_in({regfile_data_rc_id_preCheck[37:32], regfile_data_rc_id_preCheck[30:16], regfile_data_rc_id_preCheck[14:8], regfile_data_rc_id_preCheck[6:4], regfile_data_rc_id_preCheck[2]}),         
    .hamming_code(recomputed_ham_code_signal_3) // Replace hamming_code_signal with the actual signal name
);

cv32e40p_errorChecking_ham errorChecking_ham_1 (
    .data_in_from_RF(regfile_data_ra_id_preCheck),
    .recomputed_input(recomputed_ham_code_signal_1),
    .data_Out(rdata_a_o_RFHAM),
    .RF_double_Error(RF_DED_1)
);

cv32e40p_errorChecking_ham errorChecking_ham_2 (
    .data_in_from_RF(regfile_data_rb_id_preCheck),
    .recomputed_input(recomputed_ham_code_signal_2),
    .data_Out(rdata_b_o_RFHAM),
    .RF_double_Error(RF_DED_2)
);

cv32e40p_errorChecking_ham errorChecking_ham_3 (
    .data_in_from_RF(regfile_data_rc_id_preCheck),
    .recomputed_input(recomputed_ham_code_signal_3),
    .data_Out(rdata_c_o_RFHAM),
    .RF_double_Error(RF_DED_3)
);


endmodule


