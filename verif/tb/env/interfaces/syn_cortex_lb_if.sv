interface syn_cortex_lb_if  #(ADDR_W  = 16, DATA_W  = 32)  (input  logic av_clk, input logic av_rst);

  //Avalon MM Interface
  logic               av_read;               //1->Read xtn
  logic               av_write;              //1->Write xtn
  logic               av_read_data_valid;    //1->av_read_data is valid
  logic               av_wait_req;           //1->Wait/stall xtn
  logic [ADDR_W-1:0]  av_addr;               //Address
  logic [DATA_W-1:0]  av_write_data;         //Write Data
  logic [DATA_W-1:0]  av_read_data;          //Read Data


  /*  Clocking Blocks */
  clocking  cb@(posedge  av_clk);
    default input #2ns output #2ns;

    output  av_read;
    inout   av_write; //syn_vcortex_lb_mon needs as input
    input   av_read_data_valid;
    input   av_wait_req;
    inout   av_addr;  //syn_vcortex_lb_mon needs as input
    inout   av_write_data;  //syn_vcortex_lb_mon needs as input
    input   av_read_data;
  endclocking : cb


  /*  Modports  */
  modport TB  (clocking cb, input av_clk,av_rst);

  modport DUT (input  av_clk,av_rst,av_read,av_write,av_addr,av_write_data,  output  av_wait_req,av_read_data,av_read_data_valid);

endinterface  //syn_cortex_lb_if
