interface syn_fgyrus_butter_if  #(SAMPLE_W  = 32, TWDL_W  = 10)  (input  logic clk, input logic rst);

  logic [SAMPLE_W-1:0]  sample_a_real;
  logic [SAMPLE_W-1:0]  sample_a_im;
  logic [SAMPLE_W-1:0]  sample_b_real;
  logic [SAMPLE_W-1:0]  sample_b_im;
  logic [TWDL_W-1:0]    twdl_real;
  logic [TWDL_W-1:0]    twdl_im;
  logic                 samples_rdy;

  logic [SAMPLE_W-1:0]  data_real;
  logic [SAMPLE_W-1:0]  data_im;
  logic                 data_rdy;

  /*  Clocking Blocks */
  clocking  cb@(posedge  clk);
    default input #2ns output #2ns;

    input sample_a_real;
    input sample_a_im;
    input sample_b_real;
    input sample_b_im;
    input twdl_real;
    input twdl_im;
    input samples_rdy;

    input data_real;
    input data_im;
    input data_rdy;

  endclocking : cb


  /*  Modports  */
  modport TB  (clocking cb, input clk,rst);


endinterface  //syn_fgyrus_butter_if
