interface syn_av_mm_if_2  #(ADDR_W  = 12, DATA_W  = 16)  (input  logic av_clk, input logic av_rst);

  //Avalon MM Interface
  logic               av_read;               //1->Read xtn
  logic               av_write;              //1->Write xtn
  logic [ADDR_W-1:0]  av_addr;               //Address
  logic [DATA_W-1:0]  av_write_data;         //Write Data
  logic [DATA_W-1:0]  av_read_data;          //Read Data
  logic               av_rd_data_valid;      //1->av_read_data valid


  /*  Clocking Blocks */
  clocking  cb@(posedge  av_clk);
    default input #2ns output #2ns;

    output  av_read;
    output  av_write;
    output  av_addr;
    output  av_write_data;
    input   av_read_data;
    input   av_rd_data_valid;
  endclocking : cb


  /*  Modports  */
  modport TB  (clocking cb, input av_clk,av_rst);

  modport DUT (input  av_clk,av_rst,av_read,av_write,av_addr,av_write_data,  output  av_read_data,av_rd_data_valid);

endinterface  //syn_av_mm_if_2
