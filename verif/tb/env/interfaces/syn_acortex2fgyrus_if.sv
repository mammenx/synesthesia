interface syn_acortex2fgyrus_if #(ADDR_W  = 7, DATA_W  = 32)  (input  logic clk);

  logic               pcm_rdy;
  logic [ADDR_W-1:0]  pcm_rd_addr;
  logic [DATA_W-1:0]  pcm_data;

  /*  Clocking Blocks */
  clocking  cb@(posedge  clk);
    default input #2ns output #2ns;

    input pcm_rdy;
    input pcm_rd_addr;
    input pcm_data;

  endclocking : cb


  /*  Modports  */
  modport TB  (clocking cb, input clk);


endinterface  //syn_acortex2fgyrus_if
