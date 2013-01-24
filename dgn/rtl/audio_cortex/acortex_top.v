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
 -- Module Name       : acortex_top
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Audio Cortex Top Module
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module acortex_top
  (
    acortex_clk_ir,           //Acortex clock input
    acortex_rst_il,           //Associated Acortex reset
    fgyrus_clk_ir,            //Fgyrus clock input
    fgyrus_rst_il,            //Associated Fgyrus reset

    //MCLK vector from PLLs
    mclk_pll_ir,              //MCLKs from PLLs

    //Local Bus interface 0 [Avalon Streaming I/F]
    av_st_data_id,            //Data
    av_st_ready_oh,           //1->SRAM ready for data, 0->SRAM full
    av_st_valid_ih,           //1->Transaction valid
    av_st_sop_ih,             //1->Start of packet
    av_st_eop_ih,             //1->End of packet

    `ifdef  USE_ACORTEX_AVALON_DIRECT_MM
      //Local Bus interface 1 [Avalon Memory Mapped I/F]
      av_mm_read_ih,          //1->Read xtn
      av_mm_write_ih,         //1->Write xtn
      av_mm_begin_xfr_ih,     //1->Begin xfr
      av_mm_wait_req_oh,      //1->Wait/stall xtn
      av_mm_addr_id,          //Address
      av_mm_write_data_id,    //Write Data
      av_mm_read_data_od,     //Read Data
    `else
      //Local Bus interface
      lb_rd_en_ih,            //1->Read enable
      lb_wr_en_ih,            //1->Write enable
      lb_addr_id,             //Address input
      lb_wr_data_id,          //Write Data input
      lb_rd_valid_od,         //1->lb_rd_data_od is valid
      lb_rd_data_od,          //Read Data output
      lb_wr_valid_od,         //1->write is valid
    `endif



    //SRAM Interface
    sram_dq,                  // SRAM Data bus 16 Bits
    sram_addr_od,		      // SRAM Address bus 18 Bits
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

    //FGYRUS Right Channel Interface
    fgyrus_rpcm_rdy_oh,        //1->PCM samples ready for FFT
    fgyrus_rpcm_rd_addr_id,    //Read address to PCM buffer
    fgyrus_rpcm_data_od,       //PCM data to Fgyrus

    //FGYRUS Left Channel Inrterface
    fgyrus_lpcm_rdy_oh,        //1->PCM samples ready for FFT
    fgyrus_lpcm_rd_addr_id,    //Read address to PCM buffer
    fgyrus_lpcm_data_od        //PCM data to Fgyrus

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_SRAM_ADDR_W     = 18;

  parameter P_LB_ADDR_W       = 12;
  parameter P_LB_DATA_W       = P_16B_W;

  parameter P_BLK_ADDR_W      = P_8B_W;
  parameter P_BLK_DATA_W      = P_16B_W;

  parameter P_FGYRUS_ADDR_W   = 7;

//----------------------- Input Declarations ------------------------------
  input                       acortex_clk_ir;
  input                       acortex_rst_il;
  input                       fgyrus_clk_ir;
  input                       fgyrus_rst_il;

  input   [3:0]               mclk_pll_ir;

  input   [P_16B_W-1:0]       av_st_data_id;
  input                       av_st_valid_ih;
  input                       av_st_sop_ih;
  input                       av_st_eop_ih;

  `ifdef  USE_ACORTEX_AVALON_DIRECT_MM
    input                     av_mm_read_ih;
    input                     av_mm_write_ih;
    input                     av_mm_begin_xfr_ih;
    input [11:0]              av_mm_addr_id;
    input [15:0]              av_mm_write_data_id;
  `else
    input                     lb_rd_en_ih;
    input                     lb_wr_en_ih;
    input [P_LB_ADDR_W-1:0]   lb_addr_id;
    input [P_LB_DATA_W-1:0]   lb_wr_data_id;
  `endif

  input                       aud_adc_dat_id;

  input   [P_FGYRUS_ADDR_W-1:0] fgyrus_rpcm_rd_addr_id;
  input   [P_FGYRUS_ADDR_W-1:0] fgyrus_lpcm_rd_addr_id;

//----------------------- Inout Declarations ------------------------------
  inout   [P_16B_W-1:0]       sram_dq;

  inout                       i2c_sda_io;

//----------------------- Output Declarations -----------------------------
  output                      av_st_ready_oh;

  `ifdef  USE_ACORTEX_AVALON_DIRECT_MM
    output                    av_mm_wait_req_oh;
    output  [15:0]            av_mm_read_data_od;
  `else
    output                    lb_rd_valid_od;
    output  [P_LB_DATA_W-1:0] lb_rd_data_od;
    output                    lb_wr_valid_od;
  `endif

  output                      aud_adc_lrc_od;

  output  [P_SRAM_ADDR_W-1:0] sram_addr_od;
  output                      sram_lb_ol;
  output                      sram_ub_ol;
  output                      sram_ce_ol;
  output                      sram_oe_ol;
  output                      sram_we_ol;

  output                      i2c_scl_od;

  output                      aud_mclk_od;
  output                      aud_blck_od;
  output                      aud_dac_dat_od;
  output                      aud_dac_lrc_od;

  output                      fgyrus_rpcm_rdy_oh;
  output  [P_32B_W-1:0]       fgyrus_rpcm_data_od;

  output                      fgyrus_lpcm_rdy_oh;
  output  [P_32B_W-1:0]       fgyrus_lpcm_data_od;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg                         acortex_rst_l_f;  //internal reset

  reg   [P_8B_W-1:0]          adc_cap_cntr_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                        sram_ff_rd_en_w;
  wire                        sram_ff_wr_en_w;
  wire    [P_SRAM_ADDR_W-1:0] sram_rd_addr_w;
  wire    [P_SRAM_ADDR_W-1:0] sram_wr_addr_w;

  wire                        acortex_host_rst_l_w;

  wire                        blk_i2c_rd_en_w;
  wire                        blk_i2c_wr_en_w;
  wire                        blk_sram_rd_en_w;
  wire                        blk_sram_wr_en_w;
  wire                        blk_prsr_rd_en_w;
  wire                        blk_prsr_wr_en_w;
  wire                        blk_dac_rd_en_w;
  wire                        blk_dac_wr_en_w;
  wire    [P_BLK_ADDR_W-1:0]  blk_addr_w;
  wire    [P_BLK_DATA_W-1:0]  blk_wr_data_w;
  wire                        blk_i2c_rd_valid_w;
  wire                        blk_i2c_wr_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_i2c_rd_data_w;
  wire                        blk_sram_rd_valid_w;
  wire                        blk_sram_wr_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_sram_rd_data_w;
  wire                        blk_prsr_rd_valid_w;
  wire                        blk_prsr_wr_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_prsr_rd_data_w;
  wire                        blk_dac_rd_valid_w;
  wire                        blk_dac_wr_valid_w;
  wire    [P_BLK_DATA_W-1:0]  blk_dac_rd_data_w;
 
  wire                        sram_ff_full_w;
  wire                        sram_ff_empty_w;
  wire                        sram_ff_aempty_w;
  wire                        sram_mm_rd_en_w;
  wire                        sram_mm_wr_en_w;
  wire    [P_SRAM_ADDR_W-1:0] sram_mm_addr_w;
  wire    [P_16B_W-1:0]       sram_mm_wr_data_w;
  wire                        sram_mm_rd_valid_w;
  wire    [P_16B_W-1:0]       sram_mm_rd_data_w;
  wire                        sram_arb_mm_grant_w;

  wire                        sram_drvr_wr_en_w;
  wire                        sram_drvr_rd_en_w;
  wire    [P_SRAM_ADDR_W-1:0] sram_drvr_addr_w;
  wire    [P_16B_W-1:0]       sram_drvr_rd_data_w;
  wire    [P_16B_W-1:0]       sram_drvr_wr_data_w;

  wire                        sram_rd_en_w;
  wire                        sram_rd_data_valid_w;
  wire    [P_16B_W-1:0]       sram_rd_data_w;


  wire                        pcm_ff_afull_c;
  wire                        pcm_ff_wr_en_w;
  wire    [P_32B_W-1:0]       pcm_ff_ldata_w;
  wire    [P_32B_W-1:0]       pcm_ff_rdata_w;
  wire    [P_8B_W-1:0]        pcm_rff_used_w;
  wire    [P_8B_W-1:0]        pcm_lff_used_w;
  wire                        pcm_rff_empty_w;
  wire                        pcm_lff_empty_w;

  wire                        wav_bps_w;

  wire                        pcm_ff_dac_data_valid_c;
  wire    [P_32B_W-1:0]       pcm_ff_dac_ldata_w;
  wire    [P_32B_W-1:0]       pcm_ff_dac_rdata_w;
  wire                        pcm_ff_dac_rd_ack_w;

  wire                        av2lb_rd_en_w;
  wire                        av2lb_wr_en_w;
  wire    [P_LB_ADDR_W-1:0]   av2lb_addr_w;
  wire    [P_LB_DATA_W-1:0]   av2lb_wr_data_w;
  wire                        av2lb_rd_valid_w;
  wire    [P_LB_DATA_W-1:0]   av2lb_rd_data_w;
  wire                        av2lb_wr_valid_w;

  wire                        adc2fgyrus_pcm_valid_w;
  wire    [P_32B_W-1:0]       adc2fgyrus_lpcm_w;
  wire    [P_32B_W-1:0]       adc2fgyrus_rpcm_w;

  wire    [P_8B_W-1:0]        adc_lcap_raddr_w;
  wire    [P_8B_W-1:0]        adc_rcap_raddr_w;
  wire                        adc_start_cap_w;
  wire    [P_16B_W-1:0]       adc_lcap_data_w;
  wire    [P_16B_W-1:0]       adc_rcap_data_w;
  wire                        adc_cap_busy_c;

  wire                        acortex_aud_src_sel_w;

  wire                        acortex2fgyrus_lpcm_wr_en_w;
  wire    [P_32B_W-1:0]       acortex2fgyrus_lpcm_data_w;
  wire                        acortex2fgyrus_rpcm_wr_en_w;
  wire    [P_32B_W-1:0]       acortex2fgyrus_rpcm_data_w;

//----------------------- Start of Code -----------------------------------

  `ifdef  USE_ACORTEX_AVALON_DIRECT_MM
    /*  Avalon Slave LB Bridge  */
    av_slave_stalled      av_mm_sl_inst
    (
      .av_clk_ir          (acortex_clk_ir),
      .av_rst_il          (acortex_rst_il),

      .av_read_ih         (av_mm_read_ih),
      .av_write_ih        (av_mm_write_ih),
      .av_begin_xfr_ih    (av_mm_begin_xfr_ih),
      .av_wait_req_oh     (av_mm_wait_req_oh),
      .av_addr_id         (av_mm_addr_id),
      .av_write_data_id   (av_mm_write_data_id),
      .av_read_data_od    (av_mm_read_data_od),

      .lb_rd_en_oh        (av2lb_rd_en_w),
      .lb_wr_en_oh        (av2lb_wr_en_w),
      .lb_addr_od         (av2lb_addr_w),
      .lb_wr_data_od      (av2lb_wr_data_w),
      .lb_rd_valid_id     (av2lb_rd_valid_w),
      .lb_rd_data_id      (av2lb_rd_data_w),
      .lb_wr_valid_id     (av2lb_wr_valid_w)

    );
  `endif


  /*  Local bus module  */
  acortex_lb              acortex_lb_inst
  (
    .clk_ir               (acortex_clk_ir),
    .rst_il               (acortex_rst_il),

  `ifdef  USE_ACORTEX_AVALON_DIRECT_MM
    .lb_rd_en_ih          (av2lb_rd_en_w),
    .lb_wr_en_ih          (av2lb_wr_en_w),
    .lb_addr_id           (av2lb_addr_w),
    .lb_wr_data_id        (av2lb_wr_data_w),
    .lb_rd_valid_od       (av2lb_rd_valid_w),
    .lb_rd_data_od        (av2lb_rd_data_w),
    .lb_wr_valid_od       (av2lb_wr_valid_w),
  `else
    .lb_rd_en_ih          (lb_rd_en_ih),
    .lb_wr_en_ih          (lb_wr_en_ih),
    .lb_addr_id           (lb_addr_id),
    .lb_wr_data_id        (lb_wr_data_id),
    .lb_rd_valid_od       (lb_rd_valid_od),
    .lb_rd_data_od        (lb_rd_data_od),
    .lb_wr_valid_od       (lb_wr_valid_od),
  `endif
 
    .acortex_host_rst_ol  (acortex_host_rst_l_w),

    .adc_lcap_raddr_od    (adc_lcap_raddr_w),
    .adc_lcap_data_id     (adc_lcap_data_w),
    .adc_rcap_raddr_od    (adc_rcap_raddr_w),
    .adc_rcap_data_id     (adc_rcap_data_w),
    .adc_start_cap_oh     (adc_start_cap_w),
    .adc_cap_busy_ih      (adc_cap_busy_c),

    .acortex_aud_src_sel_od (acortex_aud_src_sel_w),

    .blk_i2c_rd_en_oh     (blk_i2c_rd_en_w),
    .blk_i2c_wr_en_oh     (blk_i2c_wr_en_w),
    .blk_sram_rd_en_oh    (blk_sram_rd_en_w),
    .blk_sram_wr_en_oh    (blk_sram_wr_en_w),
    .blk_prsr_rd_en_oh    (blk_prsr_rd_en_w),
    .blk_prsr_wr_en_oh    (blk_prsr_wr_en_w),
    .blk_dac_rd_en_oh     (blk_dac_rd_en_w),
    .blk_dac_wr_en_oh     (blk_dac_wr_en_w),
    .blk_addr_od          (blk_addr_w),
    .blk_wr_data_od       (blk_wr_data_w),
    .blk_i2c_rd_valid_id  (blk_i2c_rd_valid_w),
    .blk_i2c_wr_valid_id  (blk_i2c_wr_valid_w),
    .blk_i2c_rd_data_id   (blk_i2c_rd_data_w),
    .blk_sram_rd_valid_id (blk_sram_rd_valid_w),
    .blk_sram_wr_valid_id (blk_sram_wr_valid_w),
    .blk_sram_rd_data_id  (blk_sram_rd_data_w),
    .blk_prsr_rd_valid_id (blk_prsr_rd_valid_w),
    .blk_prsr_wr_valid_id (blk_prsr_wr_valid_w),
    .blk_prsr_rd_data_id  (blk_prsr_rd_data_w),
    .blk_dac_rd_valid_id  (blk_dac_rd_valid_w),
    .blk_dac_wr_valid_id  (blk_dac_wr_valid_w),
    .blk_dac_rd_data_id   (blk_dac_rd_data_w)
 
  );

  /*
    * Generating internal reset
  */
  always@(posedge acortex_clk_ir, negedge acortex_rst_il)
  begin
    if(~acortex_rst_il)
    begin
      acortex_rst_l_f         <=  1'b0;
    end
    else
    begin
      acortex_rst_l_f         <=  acortex_host_rst_l_w;
    end
  end


//----------------------- SRAM --------------------------------------------

  /*  SRAM LB Module  */
  sram_lb               sram_lb_inst
  (
    .clk_ir               (acortex_clk_ir),
    .rst_il               (acortex_rst_l_f),

    .lb_rd_en_ih          (blk_sram_rd_en_w),
    .lb_wr_en_ih          (blk_sram_wr_en_w),
    .lb_addr_id           (blk_addr_w),
    .lb_wr_data_id        (blk_wr_data_w),
    .lb_rd_valid_od       (blk_sram_rd_valid_w),
    .lb_rd_data_od        (blk_sram_rd_data_w),
    .lb_wr_valid_od       (blk_sram_wr_valid_w),

    .sram_ff_rd_en_ih     (sram_ff_rd_en_w),
    .sram_ff_wr_en_ih     (sram_ff_wr_en_w),
    .sram_ff_full_ih      (sram_ff_full_w),
    .sram_ff_empty_ih     (sram_ff_empty_w),
    .sram_ff_aempty_ih    (sram_ff_aempty_w),
    .sram_mm_rd_en_oh     (sram_mm_rd_en_w),
    .sram_mm_wr_en_oh     (sram_mm_wr_en_w),
    .sram_mm_addr_od      (sram_mm_addr_w),
    .sram_mm_wr_data_od   (sram_mm_wr_data_w),
    .sram_mm_rd_valid_id  (sram_mm_rd_valid_w),
    .sram_mm_rd_data_id   (sram_mm_rd_data_w),
    .sram_arb_mm_grant_ih (sram_arb_mm_grant_w)

  );



  /*  SRAM Arbiter  */
  sram_arb              sram_arb_inst
  (
    .clk_ir             (acortex_clk_ir),
    .rst_il             (acortex_rst_l_f),

    .lb_st_data_id      (av_st_data_id),
    .lb_st_ready_oh     (av_st_ready_oh),
    .lb_st_valid_ih     (av_st_valid_ih),
    .lb_st_sop_ih       (av_st_sop_ih),
    .lb_st_eop_ih       (av_st_eop_ih),

    .lb_mm_rd_en_ih     (sram_mm_rd_en_w),
    .lb_mm_wr_en_ih     (sram_mm_wr_en_w),
    .lb_mm_addr_id      (sram_mm_addr_w),
    .lb_mm_wr_data_id   (sram_mm_wr_data_w),
    .lb_mm_rd_valid_od  (sram_mm_rd_valid_w),
    .lb_mm_rd_data_od   (sram_mm_rd_data_w),
    .lb_mm_arb_grant_oh (sram_arb_mm_grant_w),

    .im_rd_req_ih       (sram_rd_en_w),
    .im_rd_valid_oh     (sram_rd_data_valid_w),
    .im_rd_data_od      (sram_rd_data_w),

    .sram_ff_rd_en_oh   (sram_ff_rd_en_w),
    .sram_ff_wr_en_oh   (sram_ff_wr_en_w),
    .sram_ff_rd_addr_id (sram_rd_addr_w),
    .sram_ff_wr_addr_id (sram_wr_addr_w),
    .sram_ff_full_ih    (sram_ff_full_w),
    .sram_ff_empty_ih   (sram_ff_empty_w),

    .sram_wr_en_oh      (sram_drvr_wr_en_w),
    .sram_rd_en_oh      (sram_drvr_rd_en_w),
    .sram_addr_od       (sram_drvr_addr_w),
    .sram_rd_data_id    (sram_drvr_rd_data_w),
    .sram_wr_data_od    (sram_drvr_wr_data_w)

  );


  /*  SRAM FF Controller  */
  sram_ff_cntrlr        sram_ff_cntrlr_inst
  (
    .clk_ir             (acortex_clk_ir),
    .rst_il             (acortex_rst_l_f),

    .sram_ff_rd_en_ih   (sram_ff_rd_en_w),
    .sram_ff_wr_en_ih   (sram_ff_wr_en_w),

    .sram_empty_oh      (sram_ff_empty_w),
    .sram_full_oh       (sram_ff_full_w),
    .sram_aempty_oh     (sram_ff_aempty_w),

    .sram_rd_addr_od    (sram_rd_addr_w),
    .sram_wr_addr_od    (sram_wr_addr_w)

  );


  /*  SRAM Driver */
  sram_drvr             sram_drvr_inst
  (
    .clk                (acortex_clk_ir),
    .reset              (acortex_rst_l_f),

    .address            (sram_drvr_addr_w),
    .byteenable         (2'b11),
    .chipselect         (sram_drvr_wr_en_w  | sram_drvr_rd_en_w),
    .read               (sram_drvr_rd_en_w),
    .write              (sram_drvr_wr_en_w),
    .writedata          (sram_drvr_wr_data_w),

    .SRAM_DQ            (sram_dq),

    .SRAM_ADDR          (sram_addr_od),
    .SRAM_LB_N          (sram_lb_ol),
    .SRAM_UB_N          (sram_ub_ol),
    .SRAM_CE_N          (sram_ce_ol),
    .SRAM_OE_N          (sram_oe_ol),
    .SRAM_WE_N          (sram_we_ol),

    .readdata           (sram_drvr_rd_data_w)
);



//----------------------- WAV Parser --------------------------------------

  wav_prsr              wav_prsr_inst
  (  
      .clk_ir                 (acortex_clk_ir),
      .rst_il                 (acortex_rst_l_f),

      .sram_empty_ih          (sram_ff_empty_w),
      .sram_rd_en_oh          (sram_rd_en_w),
      .sram_rd_data_valid_ih  (sram_rd_data_valid_w),
      .sram_rd_data_id        (sram_rd_data_w),

      .lb_rd_en_ih            (blk_prsr_rd_en_w),
      .lb_wr_en_ih            (blk_prsr_wr_en_w),
      .lb_addr_id             (blk_addr_w),
      .lb_wr_data_id          (blk_wr_data_w),
      .lb_rd_valid_od         (blk_prsr_rd_valid_w),
      .lb_rd_data_od          (blk_prsr_rd_data_w),
      .lb_wr_valid_od         (blk_prsr_wr_valid_w),

      .wav_bps_od             (wav_bps_w),

      .pcm_ff_afull_ih        (pcm_ff_afull_c),
      .pcm_ff_wr_en_oh        (pcm_ff_wr_en_w),
      .pcm_ff_ldata_od        (pcm_ff_ldata_w),
      .pcm_ff_rdata_od        (pcm_ff_rdata_w)

  );

  //Generate FIFO almost full condition
  assign  pcm_ff_afull_c      = (&(pcm_rff_used_w[P_8B_W-1:P_8B_W-2]))  | (&(pcm_lff_used_w[P_8B_W-1:P_8B_W-2]));

  pcm_fifo              pcm_ff_rchnl
  (
      .aclr             (~acortex_rst_l_f),
      .clock            (acortex_clk_ir),
      .data             (pcm_ff_rdata_w),
      .rdreq            (pcm_ff_dac_rd_ack_w),
      .wrreq            (pcm_ff_wr_en_w),
      .empty            (pcm_rff_empty_w),
      .full             (),
      .q                (pcm_ff_dac_rdata_w),
      .usedw            (pcm_rff_used_w)
  );

  pcm_fifo              pcm_ff_lchnl
  (
      .aclr             (~acortex_rst_l_f),
      .clock            (acortex_clk_ir),
      .data             (pcm_ff_ldata_w),
      .rdreq            (pcm_ff_dac_rd_ack_w),
      .wrreq            (pcm_ff_wr_en_w),
      .empty            (pcm_lff_empty_w),
      .full             (),
      .q                (pcm_ff_dac_ldata_w),
      .usedw            (pcm_lff_used_w)
  );



//----------------------- WM8731 CODEC Drivers ----------------------------

  /*  Control Driver  */
  i2c_master            i2c_inst
  (
      .clk_ir           (acortex_clk_ir),
      .rst_il           (acortex_rst_l_f),

      .i2c_sda_io       (i2c_sda_io),
      .i2c_scl_od       (i2c_scl_od),

      .lb_rd_en_ih      (blk_i2c_rd_en_w),
      .lb_wr_en_ih      (blk_i2c_wr_en_w),
      .lb_addr_id       (blk_addr_w),
      .lb_wr_data_id    (blk_wr_data_w),
      .lb_rd_valid_od   (blk_i2c_rd_valid_w),
      .lb_rd_data_od    (blk_i2c_rd_data_w)

  );

  assign  blk_i2c_wr_valid_w  = blk_i2c_wr_en_w;

  /*  DAC Driver  */
  wm8731_drvr_dac       dac_drvr_inst
  (
      .clk_ir               (acortex_clk_ir),
      .rst_il               (acortex_rst_l_f),

      .mclk_pll_ir          (mclk_pll_ir),

      //.wav_bps_id           (wav_bps_w),

      .lb_rd_en_ih          (blk_dac_rd_en_w),
      .lb_wr_en_ih          (blk_dac_wr_en_w),
      .lb_addr_id           (blk_addr_w),
      .lb_wr_data_id        (blk_wr_data_w),
      .lb_rd_valid_od       (blk_dac_rd_valid_w),
      .lb_wr_valid_od       (blk_dac_wr_valid_w),
      .lb_rd_data_od        (blk_dac_rd_data_w),
 

      .pcm_ff_data_valid_ih (pcm_ff_dac_data_valid_c),
      .pcm_ff_ldata_id      (pcm_ff_dac_ldata_w),
      .pcm_ff_rdata_id      (pcm_ff_dac_rdata_w),
      .pcm_ff_rd_ack_oh     (pcm_ff_dac_rd_ack_w),

      .adc2fgyrus_pcm_valid_oh  (adc2fgyrus_pcm_valid_w),
      .adc2fgyrus_lpcm_od   (adc2fgyrus_lpcm_w),
      .adc2fgyrus_rpcm_od   (adc2fgyrus_rpcm_w),

      .aud_mclk_od          (aud_mclk_od),
      .aud_blck_od          (aud_blck_od),
      .aud_adc_dat_id       (aud_adc_dat_id),
      .aud_adc_lrc_od       (aud_adc_lrc_od),
      .aud_dac_dat_od       (aud_dac_dat_od),
      .aud_dac_lrc_od       (aud_dac_lrc_od)
  );

  assign  pcm_ff_dac_data_valid_c = ~(pcm_rff_empty_w | pcm_lff_empty_w);



//----------------------- FGYRUS Interface Blocks -------------------------

  //Select data to be fed to FGYRUS
  assign  acortex2fgyrus_lpcm_wr_en_w = acortex_aud_src_sel_w ? pcm_ff_wr_en_w  : adc2fgyrus_pcm_valid_w;
  assign  acortex2fgyrus_rpcm_wr_en_w = acortex_aud_src_sel_w ? pcm_ff_wr_en_w  : adc2fgyrus_pcm_valid_w;
  assign  acortex2fgyrus_lpcm_data_w  = acortex_aud_src_sel_w ? pcm_ff_ldata_w  : adc2fgyrus_lpcm_w;
  assign  acortex2fgyrus_rpcm_data_w  = acortex_aud_src_sel_w ? pcm_ff_rdata_w  : adc2fgyrus_rpcm_w;

  acortex2fgyrus_bffr     ac2fg_rbffr_inst
  (
    .acortex_clk_ir       (acortex_clk_ir),
    .acortex_rst_il       (acortex_rst_l_f),
    .fgyrus_clk_ir        (fgyrus_clk_ir),
    .fgyrus_rst_il        (fgyrus_rst_il),

    .acortex_pcm_wr_en_ih (acortex2fgyrus_rpcm_wr_en_w),
    .acortex_pcm_data_id  (acortex2fgyrus_rpcm_data_w),

    .fgyrus_pcm_rdy_oh    (fgyrus_rpcm_rdy_oh),
    .fgyrus_pcm_rd_addr_id(fgyrus_rpcm_rd_addr_id),
    .fgyrus_pcm_data_od   (fgyrus_rpcm_data_od)

  );

  acortex2fgyrus_bffr     ac2fg_lbffr_inst
  (
    .acortex_clk_ir       (acortex_clk_ir),
    .acortex_rst_il       (acortex_rst_l_f),
    .fgyrus_clk_ir        (fgyrus_clk_ir),
    .fgyrus_rst_il        (fgyrus_rst_il),

    .acortex_pcm_wr_en_ih (acortex2fgyrus_lpcm_wr_en_w),
    .acortex_pcm_data_id  (acortex2fgyrus_lpcm_data_w),

    .fgyrus_pcm_rdy_oh    (fgyrus_lpcm_rdy_oh),
    .fgyrus_pcm_rd_addr_id(fgyrus_lpcm_rd_addr_id),
    .fgyrus_pcm_data_od   (fgyrus_lpcm_data_od)

  );

//----------------------- Capture Logic -------------------------

  always@(posedge acortex_clk_ir, negedge acortex_rst_l_f)
  begin
    if(~acortex_rst_l_f)
    begin
      adc_cap_cntr_f          <=  {1'b1,{P_8B_W-1{1'b0}}};
    end
    else
    begin
      if(adc_cap_cntr_f[P_8B_W-1])  //wait for trigger
      begin
        adc_cap_cntr_f        <=  {~adc_start_cap_w,{P_8B_W-1{1'b0}}};
      end
      else  //increment capture address
      begin
        adc_cap_cntr_f        <=  adc_cap_cntr_f  + adc2fgyrus_pcm_valid_w;
      end
    end
  end

  assign  adc_cap_busy_c  = ~adc_cap_cntr_f[P_8B_W-1];

  adc_cap_ram   adc_lcap_ram_inst
  (
	  .clock      (acortex_clk_ir),
	  .data       (adc2fgyrus_lpcm_w),
	  .rdaddress  (adc_lcap_raddr_w),
	  .wraddress  (adc_cap_cntr_f[P_8B_W-2:0]),
	  .wren       (adc_cap_busy_c & adc2fgyrus_pcm_valid_w),
	  .q          (adc_lcap_data_w)
  );

  adc_cap_ram   adc_rcap_ram_inst
  (
	  .clock      (acortex_clk_ir),
	  .data       (adc2fgyrus_rpcm_w),
	  .rdaddress  (adc_rcap_raddr_w),
	  .wraddress  (adc_cap_cntr_f[P_8B_W-2:0]),
	  .wren       (adc_cap_busy_c & adc2fgyrus_pcm_valid_w),
	  .q          (adc_rcap_data_w)
  );


endmodule // acortex_top
