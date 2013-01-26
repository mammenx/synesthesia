interface syn_av_st_if  #(DATA_W  = 16)  (input  logic av_clk, input logic av_rst);

  //Local Bus interface [Avalon Streaming I/F]
  logic [DATA_W-1:0]  av_st_data;            //Data
  logic               av_st_ready;           //1->SRAM ready for data; 0->SRAM full
  logic               av_st_valid;           //1->Transaction valid
  logic               av_st_sop;             //1->Start of packet
  logic               av_st_eop;             //1->End of packet


  /*  Clocking Blocks */
  clocking  cb@(posedge  av_clk);
    default input #2ns output #2ns;

    output  av_st_data;
    input   av_st_ready;
    output  av_st_valid;
    output  av_st_sop;
    output  av_st_eop;

  endclocking : cb


  /*  Modports  */
  modport TB  (clocking cb, input av_clk, input av_rst);

  modport DUT (input  av_clk,av_rst,av_st_data,av_st_valid,av_st_sop,av_st_eop, output  av_st_ready);

endinterface  //syn_av_st_if
