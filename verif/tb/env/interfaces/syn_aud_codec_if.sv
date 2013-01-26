interface syn_aud_codec_if  #(NO_OF_MCLKS = 4)  (input  logic [NO_OF_MCLKS-1:0] mclk_pll, sys_rst);

  //WM8731 I2C  Interface
  wire      sda;
  logic     scl;

  logic     tb_i2c_drive;
  logic     tb_i2c_data;

  assign    sda = tb_i2c_drive  ? tb_i2c_data : 1'bz;

  //WM8731  DAC Interface
  logic     dac_mclk;
  logic     dac_bclk;
  logic     dac_dat;
  logic     dac_lrc;
  logic     adc_dat;
  logic     adc_lrc;

  /*  Clocking Blocks */

  /*  Modports  */
  modport TB_DAC  (input  dac_mclk,dac_bclk,dac_dat,dac_lrc);

  modport DUT_DAC (input  mclk_pll, output  dac_mclk,dac_bclk,dac_dat,dac_lrc);

  modport TB_ADC  (input  dac_mclk,dac_bclk,adc_lrc,sys_rst, output adc_dat);

  modport TB_I2C  (inout  sda,  input scl,  output  tb_i2c_drive,tb_i2c_data);

  modport DUT_I2C (inout  sda,  output  scl);

endinterface  //syn_aud_codec_if
