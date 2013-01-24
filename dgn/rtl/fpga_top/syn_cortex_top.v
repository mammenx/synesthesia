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
 -- Module Name       : syn_cortex_top
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block integrates acortex, fgyrus & vcortex
                        blocks.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module syn_cortex_top
  (
    clk_50_ir,                //50MHz clock input
    sys_rst_il,               //Asynchronous system reset

    //MCLK vector from PLLs
    mclk_pll_ir,              //MCLKs from PLLs

    //NIOS Interrupt
    irq_oh,                   //1->Interrupt NIOS processor

    //Local Bus interface 0 [Avalon Streaming I/F]
    av_st_data_id,            //Data
    av_st_ready_oh,           //1->SRAM ready for data, 0->SRAM full
    av_st_valid_ih,           //1->Transaction valid
    av_st_sop_ih,             //1->Start of packet
    av_st_eop_ih,             //1->End of packet

    //Avalon MM Interface
    av_rst_il,                //Avalon Reset
    av_clk_ir,                //Avalon Clock
    av_read_ih,               //1->Read xtn
    av_write_ih,              //1->Write xtn
    av_wait_req_oh,           //1->Wait/stall xtn
    av_addr_id,               //Address
    av_write_data_id,         //Write Data
    av_read_data_valid_oh,    //1->av_read_data_od is valid
    av_read_data_od,          //Read Data

    //FFT Cache AV MM Interface
    av_fft_cache_read_ih,               //1->Read xtn
    av_fft_cache_addr_id,               //Address
    av_fft_cache_read_data_od,          //Read Data
    av_fft_cache_read_data_valid_oh,    //1->Read data is valid
    av_fft_cache_rst_il,                //Active low reset

    //SRAM Interface
    sram_dq,                  // SRAM Data bus 16 Bits
    sram_addr_od,		          // SRAM Address bus 18 Bits
    sram_lb_ol,	              // SRAM Low-byte Data Mask 
    sram_ub_ol,	              // SRAM High-byte Data Mask 
    sram_ce_ol,	              // SRAM Chip chipselect
    sram_oe_ol,	              // SRAM Output chipselect
    sram_we_ol,	              // SRAM Write chipselect

    //WM8731 I2C interface
    i2c_sda_io,               //SDA
    i2c_scl_od,               //SCL

    //WM8731  DAC Interface
    aud_mclk_od,              //Master Clock to DAC
    aud_blck_od,              //10MHz Bit clock
    aud_adc_dat_id,           //ADC data line
    aud_adc_lrc_od,           //ADC sample rate clk
    aud_dac_dat_od,           //DAC data line
    aud_dac_lrc_od,           //DAC sample rate clk

    //PWM Output
    pwm_data_od               //PWM Channel data


  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_SRAM_ADDR_W     = 18;

  parameter P_LB_ADDR_W       = 16;
  parameter P_LB_DATA_W       = P_32B_W;

  parameter P_BLK_ADDR_W      = 12;
  parameter P_BLK_DATA_W      = P_32B_W;

  parameter P_FGYRUS_ADDR_W   = 7;

  parameter P_NO_PWM_CHANNELS = 16;

  parameter P_FFT_CACHE_ADDR_W  = 10;
  parameter P_FFT_CACHE_DATA_W  = P_32B_W;

//----------------------- Input Declarations ------------------------------
  input                       clk_50_ir;
  input                       sys_rst_il;

  input   [3:0]               mclk_pll_ir;

  input   [P_16B_W-1:0]       av_st_data_id;
  input                       av_st_valid_ih;
  input                       av_st_sop_ih;
  input                       av_st_eop_ih;

  input                       av_rst_il;
  input                       av_clk_ir;
  input                       av_read_ih;
  input                       av_write_ih;
  input   [P_LB_ADDR_W+1:0]   av_addr_id;
  input   [P_LB_DATA_W-1:0]   av_write_data_id;

  input                             av_fft_cache_read_ih;
  input   [P_FFT_CACHE_ADDR_W-1:0]  av_fft_cache_addr_id;
  input                             av_fft_cache_rst_il;

  input                       aud_adc_dat_id;

//----------------------- Inout Declarations ------------------------------
  inout   [P_16B_W-1:0]       sram_dq;

  inout                       i2c_sda_io;

//----------------------- Output Declarations -----------------------------
  output                      irq_oh;

  output                      av_st_ready_oh;

  output                      av_wait_req_oh;
  output                      av_read_data_valid_oh;
  output  [P_LB_DATA_W-1:0]   av_read_data_od;

  output  [P_FFT_CACHE_DATA_W-1:0]  av_fft_cache_read_data_od;
  output                            av_fft_cache_read_data_valid_oh;

  output  [P_SRAM_ADDR_W-1:0] sram_addr_od;
  output                      sram_lb_ol;
  output                      sram_ub_ol;
  output                      sram_ce_ol;
  output                      sram_oe_ol;
  output                      sram_we_ol;

  output                      i2c_scl_od;

  output                      aud_mclk_od;
  output                      aud_blck_od;
  output                      aud_adc_lrc_od;
  output                      aud_dac_dat_od;
  output                      aud_dac_lrc_od;

  output  [P_NO_PWM_CHANNELS-1:0] pwm_data_od;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire                        lb_rd_valid_w;
  wire    [P_LB_DATA_W-1:0]   lb_rd_data_w;
  wire                        lb_wr_valid_w;
  wire                        lb_rd_en_w;
  wire                        lb_wr_en_w;
  wire    [P_LB_ADDR_W-1:0]   lb_addr_w;
  wire    [P_LB_DATA_W-1:0]   lb_wr_data_w;

  wire                        blk_acortex_wr_valid_w;
  wire                        blk_acortex_rd_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_acortex_rd_data_w;
  wire                        blk_vcortex_wr_valid_w;
  wire                        blk_vcortex_rd_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_vcortex_rd_data_w;
  wire                        blk_fgyrus_lchnl_wr_valid_w;
  wire                        blk_fgyrus_lchnl_rd_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_fgyrus_lchnl_rd_data_w;
  wire                        blk_fgyrus_rchnl_wr_valid_w;
  wire                        blk_fgyrus_rchnl_rd_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_fgyrus_rchnl_rd_data_w;
  wire                        blk_acortex_wr_en_w;
  wire                        blk_acortex_rd_en_w;
  wire                        blk_vcortex_wr_en_w;
  wire                        blk_vcortex_rd_en_w;
  wire                        blk_fgyrus_lchnl_wr_en_w;
  wire                        blk_fgyrus_lchnl_rd_en_w;
  wire                        blk_fgyrus_rchnl_wr_en_w;
  wire                        blk_fgyrus_rchnl_rd_en_w;
  wire    [P_BLK_ADDR_W-1:0]  blk_addr_w;
  wire    [P_BLK_DATA_W-1:0]  blk_wr_data_w;

  wire    [P_FGYRUS_ADDR_W-1:0] fgyrus_rpcm_rd_addr_w;
  wire    [P_FGYRUS_ADDR_W-1:0] fgyrus_lpcm_rd_addr_w;
  wire                        fgyrus_rpcm_rdy_w;
  wire    [P_32B_W-1:0]       fgyrus_rpcm_data_w;
  wire                        fgyrus_lpcm_rdy_w;
  wire    [P_32B_W-1:0]       fgyrus_lpcm_data_w;

  wire                        irq_rst_w;
  wire                        fgyrus_lchnl_irq_w;
  wire                        fgyrus_rchnl_irq_w;

  wire    [P_FGYRUS_ADDR_W-1:0] fft_res_lchnnl_wr_addr_w;
  wire    [P_32B_W-1:0]         fft_res_lchnnl_wr_data_w;
  wire                          fft_res_lchnnl_wr_en_w;
  wire    [P_32B_W-1:0]         fft_res_lchnnl_rd_data_w;

  wire    [P_FGYRUS_ADDR_W-1:0] fft_res_rchnnl_wr_addr_w;
  wire    [P_32B_W-1:0]         fft_res_rchnnl_wr_data_w;
  wire                          fft_res_rchnnl_wr_en_w;
  wire    [P_32B_W-1:0]         fft_res_rchnnl_rd_data_w;

  wire    [P_FGYRUS_ADDR_W-1:0] fft_res_rd_addr_w;

//----------------------- Start of Code -----------------------------------

  /*
  * CDC bridge
  */
  syn_lb_cdc_bridge           syn_lb_cdc_bridge_inst
  (
    .av_rst_il                (av_rst_il),
    .av_clk_ir                (av_clk_ir),
    .av_read_ih               (av_read_ih),
    .av_write_ih              (av_write_ih),
    .av_wait_req_oh           (av_wait_req_oh),
    .av_addr_id               (av_addr_id),
    .av_write_data_id         (av_write_data_id),
    .av_read_data_valid_oh    (av_read_data_valid_oh),
    .av_read_data_od          (av_read_data_od),

    .lb_rst_il                (sys_rst_il),
    .lb_clk_ir                (clk_50_ir),
    .lb_rd_en_oh              (lb_rd_en_w),
    .lb_wr_en_oh              (lb_wr_en_w),
    .lb_addr_od               (lb_addr_w),
    .lb_wr_data_od            (lb_wr_data_w),
    .lb_rd_valid_id           (lb_rd_valid_w),
    .lb_rd_data_id            (lb_rd_data_w),
    .lb_wr_valid_id           (lb_wr_valid_w)

  );



  /*
  * Cortex LB
  */
  syn_cortex_lb               syn_cortex_lb_inst
  (
    .clk_ir                   (clk_50_ir),
    .rst_il                   (sys_rst_il),

    .lb_rd_en_ih              (lb_rd_en_w),
    .lb_wr_en_ih              (lb_wr_en_w),
    .lb_addr_id               (lb_addr_w),
    .lb_wr_data_id            (lb_wr_data_w),
    .lb_rd_valid_od           (lb_rd_valid_w),
    .lb_rd_data_od            (lb_rd_data_w),
    .lb_wr_valid_od           (lb_wr_valid_w),

    .irq_rst_oh               (irq_rst_w),

    .blk_acortex_wr_en_oh     (blk_acortex_wr_en_w),
    .blk_acortex_rd_en_oh     (blk_acortex_rd_en_w),
    .blk_vcortex_wr_en_oh     (blk_vcortex_wr_en_w),
    .blk_vcortex_rd_en_oh     (blk_vcortex_rd_en_w),
    .blk_fgyrus_lchnl_wr_en_oh(blk_fgyrus_lchnl_wr_en_w),
    .blk_fgyrus_lchnl_rd_en_oh(blk_fgyrus_lchnl_rd_en_w),
    .blk_fgyrus_rchnl_wr_en_oh(blk_fgyrus_rchnl_wr_en_w),
    .blk_fgyrus_rchnl_rd_en_oh(blk_fgyrus_rchnl_rd_en_w),
    .blk_addr_od              (blk_addr_w),
    .blk_wr_data_od           (blk_wr_data_w),
    .blk_acortex_wr_valid_ih  (blk_acortex_wr_valid_w),
    .blk_acortex_rd_valid_ih  (blk_acortex_rd_valid_w),
    .blk_acortex_rd_data_id   ({16'd0,blk_acortex_rd_data_w[P_16B_W-1:0]}),
    .blk_vcortex_wr_valid_ih  (blk_vcortex_wr_valid_w),
    .blk_vcortex_rd_valid_ih  (blk_vcortex_rd_valid_w),
    .blk_vcortex_rd_data_id   (blk_vcortex_rd_data_w),
    .blk_fgyrus_lchnl_wr_valid_ih (blk_fgyrus_lchnl_wr_valid_w),
    .blk_fgyrus_lchnl_rd_valid_ih (blk_fgyrus_lchnl_rd_valid_w),
    .blk_fgyrus_lchnl_rd_data_id  (blk_fgyrus_lchnl_rd_data_w),
    .blk_fgyrus_rchnl_wr_valid_ih (blk_fgyrus_rchnl_wr_valid_w),
    .blk_fgyrus_rchnl_rd_valid_ih (blk_fgyrus_rchnl_rd_valid_w),
    .blk_fgyrus_rchnl_rd_data_id  (blk_fgyrus_rchnl_rd_data_w)

  );


  /*
  * Audio Acortex
  */
  acortex_top                 acortex_top_inst
  (
    .acortex_clk_ir           (clk_50_ir),
    .acortex_rst_il           (sys_rst_il),
    .fgyrus_clk_ir            (clk_50_ir),
    .fgyrus_rst_il            (sys_rst_il),

    .mclk_pll_ir              (mclk_pll_ir),

    .av_st_data_id            (av_st_data_id),
    .av_st_ready_oh           (av_st_ready_oh),
    .av_st_valid_ih           (av_st_valid_ih),
    .av_st_sop_ih             (av_st_sop_ih),
    .av_st_eop_ih             (av_st_eop_ih),

    `ifdef  USE_ACORTEX_AVALON_DIRECT_MM
      .av_mm_read_ih          (),
      .av_mm_write_ih         (),
      .av_mm_begin_xfr_ih     (),
      .av_mm_wait_req_oh      (),
      .av_mm_addr_id          (),
      .av_mm_write_data_id    (),
      .av_mm_read_data_od     (),
    `else
      .lb_rd_en_ih            (blk_acortex_rd_en_w),
      .lb_wr_en_ih            (blk_acortex_wr_en_w),
      .lb_addr_id             (blk_addr_w),
      .lb_wr_data_id          (blk_wr_data_w[P_16B_W-1:0]),
      .lb_rd_valid_od         (blk_acortex_rd_valid_w),
      .lb_rd_data_od          (blk_acortex_rd_data_w[P_16B_W-1:0]),
      .lb_wr_valid_od         (blk_acortex_wr_valid_w),
    `endif

    .sram_dq                  (sram_dq),
    .sram_addr_od             (sram_addr_od),
    .sram_lb_ol               (sram_lb_ol),
    .sram_ub_ol               (sram_ub_ol),
    .sram_ce_ol               (sram_ce_ol),
    .sram_oe_ol               (sram_oe_ol),
    .sram_we_ol               (sram_we_ol),

    .i2c_sda_io               (i2c_sda_io),
    .i2c_scl_od               (i2c_scl_od),
                                                        
    .aud_mclk_od              (aud_mclk_od),
    .aud_blck_od              (aud_blck_od),
    .aud_adc_dat_id           (aud_adc_dat_id),
    .aud_adc_lrc_od           (aud_adc_lrc_od),
    .aud_dac_dat_od           (aud_dac_dat_od),
    .aud_dac_lrc_od           (aud_dac_lrc_od),

    .fgyrus_rpcm_rdy_oh       (fgyrus_rpcm_rdy_w),
    .fgyrus_rpcm_rd_addr_id   (fgyrus_rpcm_rd_addr_w),
    .fgyrus_rpcm_data_od      (fgyrus_rpcm_data_w),
                                                        
    .fgyrus_lpcm_rdy_oh       (fgyrus_lpcm_rdy_w),
    .fgyrus_lpcm_rd_addr_id   (fgyrus_lpcm_rd_addr_w),
    .fgyrus_lpcm_data_od      (fgyrus_lpcm_data_w)

  );

  /*
  * LChannel FGYRUS
  */
  fgyrus_top                  fgyrus_lchnl_inst
  (
    .clk_ir                   (clk_50_ir),
    .rst_il                   (sys_rst_il),

    .pcm_rdy_ih               (fgyrus_lpcm_rdy_w),

    .pcm_ram_rd_addr_od       (fgyrus_lpcm_rd_addr_w),
    .pcm_ram_rd_data_id       (fgyrus_lpcm_data_w),

    .irq_rst_ih               (irq_rst_w),
    .irq_oh                   (fgyrus_lchnl_irq_w),

    .fft_res_wr_addr_od       (fft_res_lchnnl_wr_addr_w),
    .fft_res_wr_data_od       (fft_res_lchnnl_wr_data_w),
    .fft_res_wr_en_oh         (fft_res_lchnnl_wr_en_w),

    .lb_rd_en_ih              (blk_fgyrus_lchnl_rd_en_w),
    .lb_wr_en_ih              (blk_fgyrus_lchnl_wr_en_w),
    .lb_addr_id               (blk_addr_w),
    .lb_wr_data_id            (blk_wr_data_w),
    .lb_rd_valid_od           (blk_fgyrus_lchnl_rd_valid_w),
    .lb_wr_valid_od           (blk_fgyrus_lchnl_wr_valid_w),
    .lb_rd_data_od            (blk_fgyrus_lchnl_rd_data_w)
  );

  /*
  * RChannel FGYRUS
  */
  fgyrus_top                  fgyrus_rchnl_inst
  (
    .clk_ir                   (clk_50_ir),
    .rst_il                   (sys_rst_il),

    .pcm_rdy_ih               (fgyrus_rpcm_rdy_w),

    .pcm_ram_rd_addr_od       (fgyrus_rpcm_rd_addr_w),
    .pcm_ram_rd_data_id       (fgyrus_rpcm_data_w),

    .irq_rst_ih               (irq_rst_w),
    .irq_oh                   (fgyrus_rchnl_irq_w),

    .fft_res_wr_addr_od       (fft_res_rchnnl_wr_addr_w),
    .fft_res_wr_data_od       (fft_res_rchnnl_wr_data_w),
    .fft_res_wr_en_oh         (fft_res_rchnnl_wr_en_w),

    .lb_rd_en_ih              (blk_fgyrus_rchnl_rd_en_w),
    .lb_wr_en_ih              (blk_fgyrus_rchnl_wr_en_w),
    .lb_addr_id               (blk_addr_w),
    .lb_wr_data_id            (blk_wr_data_w),
    .lb_rd_valid_od           (blk_fgyrus_rchnl_rd_valid_w),
    .lb_wr_valid_od           (blk_fgyrus_rchnl_wr_valid_w),
    .lb_rd_data_od            (blk_fgyrus_rchnl_rd_data_w)
  );


  dd_sync   acortex_irq_sync
  (
    .clk_ir     (av_clk_ir),
    .rst_il     (av_rst_il),

    .signal_id  (fgyrus_lchnl_irq_w  | fgyrus_rchnl_irq_w),

    .signal_od  (irq_oh)
  );


  /*
  * Visual Cortex
  */
  vcortex_top                 vcortex_top_inst
  (
    .clk_ir                   (clk_50_ir),
    .rst_il                   (sys_rst_il),

    .pwm_data_od              (pwm_data_od),

    .lb_rd_en_ih              (blk_vcortex_rd_en_w),
    .lb_wr_en_ih              (blk_vcortex_wr_en_w),
    .lb_addr_id               (blk_addr_w),
    .lb_wr_data_id            (blk_wr_data_w[P_16B_W-1:0]),
    .lb_rd_valid_od           (blk_vcortex_rd_valid_w),
    .lb_wr_valid_od           (blk_vcortex_wr_valid_w),
    .lb_rd_data_od            (blk_vcortex_rd_data_w[P_16B_W-1:0])

  );

  assign  blk_vcortex_rd_data_w[P_32B_W-1:P_16B_W]  = 16'd0;

  /*
  * FFT Cache Avalon Slave
  */
  fft_cache_mm_sl   fft_cache_mm_sl_inst
  (
    .av_clk_ir                  (av_clk_ir),
    .av_rst_il                  (av_fft_cache_rst_il),

    .av_read_ih                 (av_fft_cache_read_ih),
    .av_addr_id                 (av_fft_cache_addr_id),
    .av_read_data_od            (av_fft_cache_read_data_od),
    .av_read_data_valid_oh      (av_fft_cache_read_data_valid_oh),

    .fft_res_ram_rd_addr_od     (fft_res_rd_addr_w),
    .fft_res_ram_lchnl_data_id  (fft_res_lchnnl_rd_data_w),
    .fft_res_ram_rchnl_data_id  (fft_res_rchnnl_rd_data_w) 

  );



  /*
  * FFT Result RAMs
  */
  fft_res_ram   fft_res_ram_lchnl_inst
  (
	  .data       (fft_res_lchnnl_wr_data_w),
	  .rdaddress  (fft_res_rd_addr_w),
	  .rdclock    (av_clk_ir),
	  .wraddress  (fft_res_lchnnl_wr_addr_w),
	  .wrclock    (clk_50_ir),
	  .wren       (fft_res_lchnnl_wr_en_w),
	  .q          (fft_res_lchnnl_rd_data_w)
  );

  fft_res_ram   fft_res_ram_rchnl_inst
  (
	  .data       (fft_res_rchnnl_wr_data_w),
	  .rdaddress  (fft_res_rd_addr_w),
	  .rdclock    (av_clk_ir),
	  .wraddress  (fft_res_rchnnl_wr_addr_w),
	  .wrclock    (clk_50_ir),
	  .wren       (fft_res_rchnnl_wr_en_w),
	  .q          (fft_res_rchnnl_rd_data_w)
  );


endmodule // syn_cortex_top
