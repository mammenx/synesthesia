interface syn_av_mm_if_0  #(ADDR_W  = 16, DATA_W  = 16)  (input  logic av_clk, input logic av_rst);

  //Avalon MM Interface
  logic               av_read;               //1->Read xtn
  logic               av_write;              //1->Write xtn
  logic               av_begin_xfr;          //1->Begin xfr
  logic               av_wait_req;           //1->Wait/stall xtn
  logic [ADDR_W-1:0]  av_addr;               //Address
  logic [DATA_W-1:0]  av_write_data;         //Write Data
  logic [DATA_W-1:0]  av_read_data;          //Read Data


  /*  Clocking Blocks */
  clocking  cb@(posedge  av_clk);
    default input #2ns output #2ns;

    output  av_read;
    output  av_write;
    output  av_begin_xfr;
    input   av_wait_req;
    output  av_addr;
    output  av_write_data;
    input   av_read_data;
  endclocking : cb


  /*  Modports  */
  modport TB  (clocking cb, input av_clk,av_rst);

  modport DUT (input  av_clk,av_rst,av_read,av_write,av_begin_xfr,av_addr,av_write_data,  output  av_wait_req,av_read_data);

endinterface  //syn_av_mm_if_0
