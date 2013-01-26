interface syn_fgyrus_fft_ram_if #(ADDR_W  = 7, DATA_W  = 32) (input  sys_clk_100,  input sys_rst);

  wire                fft_ram_wr_real_en_w;
  wire                fft_ram_wr_im_en_w;
  wire  [ADDR_W-1:0]  fft_ram_wr_addr_w;
  wire  [DATA_W-1:0]  fft_ram_wr_real_data_w;
  wire  [DATA_W-1:0]  fft_ram_wr_im_data_w;
  wire                fft_done;
  wire                pcm_done;

  /*  Clocking Blocks */

  /*  Modports  */
  modport TB  (input  sys_clk_100,sys_rst,fft_ram_wr_real_en_w,fft_ram_wr_im_en_w,fft_ram_wr_addr_w,fft_ram_wr_real_data_w,fft_ram_wr_im_data_w,fft_done,pcm_done);


endinterface  //syn_fgyrus_fft_ram_if
