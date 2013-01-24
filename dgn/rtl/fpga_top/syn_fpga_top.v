/*
 --------------------------------------------------------------------------
   Synesthesia - Copyright (C) 2012 Gregory Matthew James.

   This file is part of Synesthesia.

   Synesthesia is free; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   Synesthesia is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <http://www.gnu.org/licenses/>.
 --------------------------------------------------------------------------
*/



/*
 --------------------------------------------------------------------------
 -- Project Code      : synesthesia
 -- Module Name       : syn_fpga_top
 -- Author            : mammenx
 -- Associated modules:
 -- Function          : FPGA Top file.
 --------------------------------------------------------------------------
*/


`timescale 1ns / 10ps


module syn_fpga_top
   (
     /*  Clocks  */
     CLOCK_50,               //50MHz clock
     CLOCK_24,               //24MHz clock
     CLOCK_27,               //27MHz clock

     /*  SDRAM            */
     DRAM_DQ,                //SDRAM Data bus 16 Bits
     DRAM_ADDR,              //SDRAM Address bus 12 Bits
     DRAM_LDQM,              //SDRAM Low-byte Data Mask 
     DRAM_UDQM,              //SDRAM High-byte Data Mask
     DRAM_WE_N,              //SDRAM Write Enable
     DRAM_CAS_N,             //SDRAM Column Address Strobe
     DRAM_RAS_N,             //SDRAM Row Address Strobe
     DRAM_CS_N,              //SDRAM Chip Select
     DRAM_BA_0,              //SDRAM Bank Address 0
     DRAM_BA_1,              //SDRAM Bank Address 0
     DRAM_CLK,               //SDRAM Clock
     DRAM_CKE,               //SDRAM Clock Enable

     /*  PUSH BUTTON SWITCH*/
     KEY,                    // Pushbutton[3:0]

     /*      LEDs    */
     LEDR,                   // LED Red[9:0]
     LEDG,                   // LED Green[7:0]

     /*      RS232   */
     UART_TXD,               // RS232 UART Transmitter
     UART_RXD,               // RS232 UART Receiver

     /*      SRAM    */
     SRAM_DQ,                // SRAM Data bus 16 Bits
     SRAM_ADDR,              // SRAM Address bus 18 Bits
     SRAM_UB_N,              // SRAM High-byte Data Mask 
     SRAM_LB_N,              // SRAM Low-byte Data Mask 
     SRAM_WE_N,              // SRAM Write Enable
     SRAM_CE_N,              // SRAM Chip Enable
     SRAM_OE_N,              // SRAM Output Enable

          /*  7 SEGMENT DISPLAY */
     HEX0,                   // Seven Segment Digit 0
     HEX1,                   // Seven Segment Digit 1
     HEX2,                   // Seven Segment Digit 2
     HEX3,                   // Seven Segment Digit 3


     /*  AUDIO CODEC */
     I2C_SCLK,               // I2C Clock
     I2C_SDAT,               // I2C Data
     AUD_ADCLRCK,            // Audio CODEC ADC LR Clock
     AUD_ADCDAT,             // Audio CODEC ADC Data
     AUD_DACLRCK,            // Audio CODEC DAC LR Clock
     AUD_DACDAT,             // Audio CODEC DAC Data
     AUD_BCLK,               // Audio CODEC Bit-Stream Clock
     AUD_XCK,                // Audio CODEC Chip Clock

     /*   SDCARD     */
     SD_DAT,                 // SD Card Data
     SD_DAT3,                // SD Card Data 3
     SD_CMD,                 // SD Card Command Signal
     SD_CLK                  // SD Card Clock

   );

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------
   input                       CLOCK_50;
   input   [1:0]               CLOCK_24;
   input   [1:0]               CLOCK_27;

   input   [3:0]               KEY;

   input                       UART_RXD;

   input                       AUD_ADCDAT;

   input                       SD_DAT;

//----------------------- Inout Declarations ------------------------------
   inout   [15:0]              DRAM_DQ;

   inout   [15:0]              SRAM_DQ;

   inout                       I2C_SDAT;

//----------------------- Output Declarations -----------------------------
   output  [11:0]              DRAM_ADDR;
   output                      DRAM_LDQM;
   output                      DRAM_UDQM;
   output                      DRAM_WE_N;
   output                      DRAM_CAS_N;
   output                      DRAM_RAS_N;
   output                      DRAM_CS_N;
   output                      DRAM_BA_0;
   output                      DRAM_BA_1;
   output                      DRAM_CLK;
   output                      DRAM_CKE;

   output  [9:0]               LEDR;

   output  [7:0]               LEDG;

   output                      UART_TXD;

   output  [17:0]              SRAM_ADDR;
   output                      SRAM_UB_N;
   output                      SRAM_LB_N;
   output                      SRAM_WE_N;
   output                      SRAM_CE_N;
   output                      SRAM_OE_N;

   output  [6:0]               HEX0;
   output  [6:0]               HEX1;
   output  [6:0]               HEX2;
   output  [6:0]               HEX3;

   output                      I2C_SCLK;
   output                      AUD_ADCLRCK;
   output                      AUD_DACLRCK;
   output                      AUD_DACDAT;
   output                      AUD_XCK;
   output                      AUD_BCLK;

   output                      SD_DAT3;
   output                      SD_CMD;
   output                      SD_CLK;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------

//----------------------- Internal Wire Declarations ----------------------
  wire                        sys_clk_50MHz_w;
  wire                        sys_clk_100MHz_w;

  wire                        sys_rst_lw;
  wire                        acortex_st_rst_lw;

  wire                        aud_mclk_16MHz_w;
  wire                        aud_mclk_11MHz_w;
  wire                        aud_mclk_12MHz_w;
  wire                        aud_mclk_18MHz_w;

  wire    [15:0]              acortex_av_st_data_w;
  wire                        acortex_av_st_ready_w;
  wire                        acortex_av_st_valid_w;
  wire                        acortex_av_st_sop_w;
  wire                        acortex_av_st_eop_w;

  wire                        cortex_av_mm_rst_hw;
  wire                        cortex_av_mm_rd_en_w;
  wire                        cortex_av_mm_wr_en_w;
  wire    [17:0]              cortex_av_mm_addr_w;
  wire    [31:0]              cortex_av_mm_wr_data_w;
  wire                        cortex_av_mm_rd_valid_w;
  wire                        cortex_av_mm_wait_req_w;
  wire    [31:0]              cortex_av_mm_rd_data_w;
  wire                        cortex_irq_w;

  wire    [15:0]              vcortex_pwm_data_w;

  wire                        av_fft_cache_read_w;
  wire    [9:0]               av_fft_cache_addr_w;
  wire    [31:0]              av_fft_cache_read_data_w;
  wire                        av_fft_cache_read_data_valid_w;

//----------------------- Start of Code -----------------------------------

  /*  PLLs  */
  syn_sys_pll     syn_sys_pll_inst
  (
    .areset       (~KEY[0]),  //key[0] is active low reset
    .inclk0       (CLOCK_50),
    .c0           (sys_clk_50MHz_w),
    .c1           (sys_clk_100MHz_w),
    .c2           (DRAM_CLK),  //SDRAM clock delayed by -3ns
    .locked       (sys_rst_lw)    //System reset
  );

  mclk_pll        mclk_pll_inst
  (
    .areset       (~KEY[0]),
    .inclk0       (CLOCK_24[0]),
    .c0           (aud_mclk_11MHz_w),
    .c1           (aud_mclk_12MHz_w),
    .c2           (aud_mclk_18MHz_w)
  );

  /*
  mclk_pll2       mclk_pll2_inst
  (
    .areset       (~KEY[0]),
    .inclk0       (CLOCK_27[0]),
    .c0           (aud_mclk_16MHz_w)
  );
  */
  assign  aud_mclk_16MHz_w  = 1'b0;



  /*  NIOS System  */
  limbus_sys    limbus_sys_inst
  (
    //Clocks + Resets
    .clk_100_clk                                (sys_clk_100MHz_w),
    .clk_50_clk                                 (sys_clk_50MHz_w),
    .reset_100_reset_n                          (sys_rst_lw),
    .reset_50_reset_n                           (sys_rst_lw),

    //SDRAM
    .sdram_export_addr                          (DRAM_ADDR),
    .sdram_export_ba                            ({DRAM_BA_1,DRAM_BA_0}),
    .sdram_export_cas_n                         (DRAM_CAS_N),
    .sdram_export_cke                           (DRAM_CKE),
    .sdram_export_cs_n                          (DRAM_CS_N),
    .sdram_export_dq                            (DRAM_DQ),
    .sdram_export_dqm                           ({DRAM_UDQM,DRAM_LDQM}),
    .sdram_export_ras_n                         (DRAM_RAS_N),
    .sdram_export_we_n                          (DRAM_WE_N),

    //UART
    .uart_export_rxd                            (UART_RXD),
    .uart_export_txd                            (UART_TXD),

    //SDCARD SPI
    .sdcard_spi_export_MISO                     (SD_DAT),
    .sdcard_spi_export_MOSI                     (SD_CMD),
    .sdcard_spi_export_SCLK                     (SD_CLK),
    .sdcard_spi_export_SS_n                     (SD_DAT3),

    //Cortex MM Slave
    .cortex_mm_sl_reset_export_reset            (cortex_av_mm_rst_hw),
    .cortex_mm_sl_export_address                (cortex_av_mm_addr_w),
    .cortex_mm_sl_export_read                   (cortex_av_mm_rd_en_w),
    .cortex_mm_sl_export_readdata               (cortex_av_mm_rd_data_w),
    .cortex_mm_sl_export_write                  (cortex_av_mm_wr_en_w),
    .cortex_mm_sl_export_writedata              (cortex_av_mm_wr_data_w),
    .cortex_mm_sl_export_readdatavalid          (cortex_av_mm_rd_valid_w),
    .cortex_mm_sl_export_waitrequest            (cortex_av_mm_wait_req_w),
    .cortex_mm_sl_irq0_export_irq               (cortex_irq_w),

    //FFT Cache MM Slave
		.fft_cache_mm_sl_export_address             (av_fft_cache_addr_w),
		.fft_cache_mm_sl_export_read                (av_fft_cache_read_w),
		.fft_cache_mm_sl_export_readdata            (av_fft_cache_read_data_w),
		.fft_cache_mm_sl_export_readdatavalid       (av_fft_cache_read_data_valid_w),
		.fft_cache_mm_sl_reset_reset                (),

    //Acortex ST
    .acortex_dc_fifo_reset_export_reset_n       (acortex_st_rst_lw),
    .acortex_st_adaptor_export_valid            (acortex_av_st_valid_w),
    .acortex_st_adaptor_export_data             (acortex_av_st_data_w),
    .acortex_st_adaptor_export_ready            (acortex_av_st_ready_w)
  );


  /*  Cortex  */
  syn_cortex_top              syn_cortex_top_inst
  (
    .clk_50_ir                (sys_clk_50MHz_w),
    .sys_rst_il               (~cortex_av_mm_rst_hw),

    .mclk_pll_ir              ({aud_mclk_11MHz_w,aud_mclk_12MHz_w,aud_mclk_16MHz_w,aud_mclk_18MHz_w}),

    .irq_oh                   (cortex_irq_w),

    .av_st_data_id            (acortex_av_st_data_w),
    .av_st_ready_oh           (acortex_av_st_ready_w),
    .av_st_valid_ih           (acortex_av_st_valid_w),
    .av_st_sop_ih             (1'b0),
    .av_st_eop_ih             (1'b0),

    .av_rst_il                (~cortex_av_mm_rst_hw),
    .av_clk_ir                (sys_clk_100MHz_w),
    .av_read_ih               (cortex_av_mm_rd_en_w),
    .av_write_ih              (cortex_av_mm_wr_en_w),
    .av_wait_req_oh           (cortex_av_mm_wait_req_w),
    .av_addr_id               (cortex_av_mm_addr_w),
    .av_write_data_id         (cortex_av_mm_wr_data_w),
    .av_read_data_valid_oh    (cortex_av_mm_rd_valid_w),
    .av_read_data_od          (cortex_av_mm_rd_data_w),

    .av_fft_cache_read_ih             (av_fft_cache_read_w),
    .av_fft_cache_addr_id             (av_fft_cache_addr_w),
    .av_fft_cache_read_data_od        (av_fft_cache_read_data_w),
    .av_fft_cache_read_data_valid_oh  (av_fft_cache_read_data_valid_w),
    .av_fft_cache_rst_il              (~cortex_av_mm_rst_hw),

    .sram_dq                  (SRAM_DQ),
    .sram_addr_od             (SRAM_ADDR),
    .sram_lb_ol               (SRAM_LB_N),
    .sram_ub_ol               (SRAM_UB_N),
    .sram_ce_ol               (SRAM_CE_N),
    .sram_oe_ol               (SRAM_OE_N),
    .sram_we_ol               (SRAM_WE_N),

    .i2c_sda_io               (I2C_SDAT),
    .i2c_scl_od               (I2C_SCLK),

    .aud_mclk_od              (AUD_XCK),
    .aud_blck_od              (AUD_BCLK),
    .aud_adc_dat_id           (AUD_ADCDAT),
    .aud_adc_lrc_od           (AUD_ADCLRCK),
    .aud_dac_dat_od           (AUD_DACDAT),
    .aud_dac_lrc_od           (AUD_DACLRCK),

    .pwm_data_od              (vcortex_pwm_data_w) 


  );



  assign  LEDR[9] = ~sys_rst_lw;
  assign  LEDR[8] = cortex_av_mm_rst_hw;

  assign  LEDR[7:0] = vcortex_pwm_data_w[15:8];
  assign  LEDG[7:0] = vcortex_pwm_data_w[7:0];


  //turn off the 7seg display
  assign  HEX0  = 7'h7f;
  assign  HEX1  = 7'h7f;
  assign  HEX2  = 7'h7f;
  assign  HEX3  = 7'h7f;

endmodule // syn_fpga_top
