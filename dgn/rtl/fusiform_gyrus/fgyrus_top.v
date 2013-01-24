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
 -- Module Name       : fgyrus_top
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Top level module for Fgyrus block
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module fgyrus_top
  (
    clk_ir,                   //Clock
    rst_il,                   //Asynchronous active low reset

    //Aud Cortex interface
    pcm_rdy_ih,               //1->PCM samples are ready for FFT

    //PCM RAM interface
    pcm_ram_rd_addr_od,       //Read address to PCM RAM
    pcm_ram_rd_data_id,       //Read data from PCM RAM

    //NIOS Interrupt
    irq_rst_ih,               //1->Clear interrupt
    irq_oh,                   //1->Interrupt NIOS processor

    //FFT Result RAM - where the final ABS values are stored for direct access
    //by CPU
    fft_res_wr_addr_od,       //Write address to FFT Res RAM
    fft_res_wr_data_od,       //Write Data to FFT Res RAM
    fft_res_wr_en_oh,         //1->Write enable to FFT Res RAM

    //Local bus interface
    lb_rd_en_ih,              //1->Read enable
    lb_wr_en_ih,              //1->Write enable
    lb_addr_id,               //Address input
    lb_wr_data_id,            //Write Data input
    lb_rd_valid_od,           //1->lb_rd_data_od is valid
    lb_wr_valid_od,           //1->Write is valid
    lb_rd_data_od             //Read Data output
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;

  parameter P_LB_ADDR_W       = 12;
  parameter P_LB_DATA_W       = P_32B_W;

  parameter P_FFT_RES_RAM_ADDR_W  = 7;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       pcm_rdy_ih;

  input   [P_32B_W-1:0]       pcm_ram_rd_data_id;

  input                       irq_rst_ih;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;


//----------------------- Output Declarations -----------------------------
  output  [6:0]               pcm_ram_rd_addr_od;

  output                      irq_oh;

  output                      lb_rd_valid_od;
  output                      lb_wr_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;

  output  [P_FFT_RES_RAM_ADDR_W-1:0]  fft_res_wr_addr_od;
  output  [P_32B_W-1:0]         fft_res_wr_data_od;
  output                        fft_res_wr_en_oh;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------

//----------------------- Internal Wire Declarations ----------------------
  wire                        fgyrus_en_w;
  wire                        fgyrus_fft_done_w;
  wire                        fgyrus_pcm_done_w;
  wire    [3:0]               fgyrus_post_norm_w;

  wire    [7:0]               lb2ram_addr_w;
  wire                        lb2fft_real_ram_wr_en_w;
  wire                        lb2fft_im_ram_wr_en_w;
  wire                        lb2twiddle_ram_wr_en_w;
  wire                        lb2cordic_ram_wr_en_w;
  wire                        lb2fft_real_ram_rd_en_w;
  wire                        lb2fft_im_ram_rd_en_w;
  wire                        lb2twiddle_ram_rd_en_w;
  wire                        lb2cordic_ram_rd_en_w;
  wire    [P_32B_W-1:0]       lb2ram_wr_data_w;

  wire    [P_32B_W-1:0]       fft_real_ram_wr_data_c;
  wire    [6:0]               fft_real_ram_rd_addr_c;
  wire    [6:0]               fft_real_ram_wr_addr_c;
  wire                        fft_real_ram_wr_en_c;

  wire    [P_32B_W-1:0]       fft_im_ram_wr_data_c;
  wire    [6:0]               fft_im_ram_rd_addr_c;
  wire    [6:0]               fft_im_ram_wr_addr_c;
  wire                        fft_im_ram_wr_en_c;

  wire    [P_32B_W-1:0]       twiddle_ram_wr_data_c;
  wire    [6:0]               twiddle_ram_rd_addr_c;
  wire    [6:0]               twiddle_ram_wr_addr_c;
  wire                        twiddle_ram_wr_en_c;

  wire    [P_16B_W-1:0]       cordic_ram_wr_data_c;
  wire    [7:0]               cordic_ram_rd_addr_c;
  wire    [7:0]               cordic_ram_wr_addr_c;
  wire                        cordic_ram_wr_en_c;

  wire    [P_32B_W-1:0]       sample_a_real_w;
  wire    [P_32B_W-1:0]       sample_a_im_w;

  wire    [P_32B_W-1:0]       sample_b_real_w;
  wire    [P_32B_W-1:0]       sample_b_im_w;

  wire    [P_16B_W-1:0]       twdl_factor_real_w;
  wire    [P_16B_W-1:0]       twdl_factor_im_w;

  wire                        samples_rdy_w;

  wire    [P_32B_W-1:0]       data_real_w;
  wire    [P_32B_W-1:0]       data_im_w;

  wire                        data_rdy_w;


  wire    [6:0]               fft_ram_rd_addr_w;
  wire    [P_32B_W-1:0]       fft_ram_rd_real_data_w;
  wire    [P_32B_W-1:0]       fft_ram_rd_im_data_w;
  wire                        fft_ram_wr_real_en_w;
  wire                        fft_ram_wr_im_en_w;
  wire    [6:0]               fft_ram_wr_addr_w;
  wire    [P_32B_W-1:0]       fft_ram_wr_real_data_w;
  wire    [P_32B_W-1:0]       fft_ram_wr_im_data_w;

  wire    [6:0]               twiddle_ram_rd_addr_w;
  wire    [P_32B_W-1:0]       twiddle_ram_rd_data_w;

  wire    [7:0]               cordic_ram_rd_addr_w;
  wire    [P_16B_W-1:0]       cordic_ram_rd_data_w;

  wire    [2:0]               fgyrus_fsm_pstate_w;
  wire                        fgyrus_busy_w;

//----------------------- Start of Code -----------------------------------


  /*  Fgyrus FSM  */
  fgyrus_fsm  fgyrus_fsm_inst
  (
    .clk_ir                     (clk_ir),
    .rst_il                     (rst_il),

    .fgyrus_en_ih               (fgyrus_en_w),
    .fgyrus_fft_done_oh         (fgyrus_fft_done_w),
    .fgyrus_pcm_done_oh         (fgyrus_pcm_done_w),
    .fgyrus_busy_oh             (fgyrus_busy_w),
    .fgyrus_fsm_pstate_od       (fgyrus_fsm_pstate_w),
    .fgyrus_post_norm_id        (fgyrus_post_norm_w),

    .fgyrus_pcm_rdy_ih          (pcm_rdy_ih),

    .pcm_ram_rd_addr_od         (pcm_ram_rd_addr_od),
    .pcm_ram_rd_data_id         (pcm_ram_rd_data_id),

    .fft_ram_rd_addr_od         (fft_ram_rd_addr_w),
    .fft_ram_rd_real_data_id    (fft_ram_rd_real_data_w),
    .fft_ram_rd_im_data_id      (fft_ram_rd_im_data_w),
    .fft_ram_wr_real_en_oh      (fft_ram_wr_real_en_w),
    .fft_ram_wr_im_en_oh        (fft_ram_wr_im_en_w),
    .fft_ram_wr_addr_od         (fft_ram_wr_addr_w),
    .fft_ram_wr_real_data_od    (fft_ram_wr_real_data_w),
    .fft_ram_wr_im_data_od      (fft_ram_wr_im_data_w),

    .fft_res_wr_addr_od         (fft_res_wr_addr_od),
    .fft_res_wr_data_od         (fft_res_wr_data_od),
    .fft_res_wr_en_oh           (fft_res_wr_en_oh),

    .twiddle_ram_rd_addr_od     (twiddle_ram_rd_addr_w),
    .twiddle_ram_real_data_id   (twiddle_ram_rd_data_w[31:16]),
    .twiddle_ram_im_data_id     (twiddle_ram_rd_data_w[15:0]),
                                                          
    .cordic_ram_rd_addr_od      (cordic_ram_rd_addr_w),
    .cordic_ram_rd_data_id      (cordic_ram_rd_data_w),

    .sample_a_real_od           (sample_a_real_w),
    .sample_a_im_od             (sample_a_im_w),
                                                     
    .sample_b_real_od           (sample_b_real_w),
    .sample_b_im_od             (sample_b_im_w),
                                                     
    .twdl_factor_real_od        (twdl_factor_real_w),
    .twdl_factor_im_od          (twdl_factor_im_w),
                                                     
    .samples_rdy_oh             (samples_rdy_w),

    .fft_data_real_id           (data_real_w),
    .fft_data_im_id             (data_im_w),
    .fft_data_rdy_ih            (data_rdy_w)

  );


  /*  Butterfly Wing  */
  butterfly_wing  butterfly_wing_inst
    (
      .clk_ir                     (clk_ir),
      .rst_il                     (rst_il),

      .sample_a_real_id           (sample_a_real_w),
      .sample_a_im_id             (sample_a_im_w),

      .sample_b_real_id           (sample_b_real_w),
      .sample_b_im_id             (sample_b_im_w),

      .twdl_factor_real_id        (twdl_factor_real_w[9:0]),
      .twdl_factor_im_id          (twdl_factor_im_w[9:0]),

      .samples_rdy_ih             (samples_rdy_w),


      .data_real_od               (data_real_w),
      .data_im_od                 (data_im_w),
      .data_rdy_oh                (data_rdy_w)

    );


  /*  FFT RAM */
  assign  fft_real_ram_wr_data_c    = lb2fft_real_ram_wr_en_w ? lb2ram_wr_data_w  : fft_ram_wr_real_data_w;
  assign  fft_real_ram_wr_addr_c    = lb2fft_real_ram_wr_en_w ? lb2ram_addr_w[6:0]: fft_ram_wr_addr_w;
  assign  fft_real_ram_wr_en_c      = lb2fft_real_ram_wr_en_w | fft_ram_wr_real_en_w;
  assign  fft_real_ram_rd_addr_c    = lb2fft_real_ram_rd_en_w ? lb2ram_addr_w[6:0]: fft_ram_rd_addr_w;

  fft_cache_ram   fft_cache_real_ram_inst
  (
	  .clock                      (clk_ir),
	  .data                       (fft_real_ram_wr_data_c),
	  .rdaddress                  (fft_real_ram_rd_addr_c),
	  .wraddress                  (fft_real_ram_wr_addr_c),
	  .wren                       (fft_real_ram_wr_en_c),
	  .q                          (fft_ram_rd_real_data_w)
  );

  assign  fft_im_ram_wr_data_c    = lb2fft_im_ram_wr_en_w ? lb2ram_wr_data_w  : fft_ram_wr_im_data_w;
  assign  fft_im_ram_wr_addr_c    = lb2fft_im_ram_wr_en_w ? lb2ram_addr_w[6:0]: fft_ram_wr_addr_w;
  assign  fft_im_ram_wr_en_c      = lb2fft_im_ram_wr_en_w | fft_ram_wr_im_en_w;
  assign  fft_im_ram_rd_addr_c    = lb2fft_im_ram_rd_en_w ? lb2ram_addr_w[6:0]: fft_ram_rd_addr_w;

  fft_cache_ram   fft_cache_im_ram_inst
  (
	  .clock                      (clk_ir),
	  .data                       (fft_im_ram_wr_data_c),
	  .rdaddress                  (fft_im_ram_rd_addr_c),
	  .wraddress                  (fft_im_ram_wr_addr_c),
	  .wren                       (fft_im_ram_wr_en_c),
	  .q                          (fft_ram_rd_im_data_w)
  );



  /*  Twiddle RAM */
  assign  twiddle_ram_wr_data_c = lb2ram_wr_data_w;
  assign  twiddle_ram_rd_addr_c = lb2twiddle_ram_rd_en_w  ? lb2ram_addr_w[6:0]  : twiddle_ram_rd_addr_w; 
  assign  twiddle_ram_wr_addr_c = lb2ram_addr_w[6:0]; 
  assign  twiddle_ram_wr_en_c   = lb2twiddle_ram_wr_en_w;

  twiddle_ram   twiddle_ram_inst
  (
    .clock                      (clk_ir),
    .data                       (twiddle_ram_wr_data_c),
    .rdaddress                  (twiddle_ram_rd_addr_c),
    .wraddress                  (twiddle_ram_wr_addr_c),
    .wren                       (twiddle_ram_wr_en_c),
    .q                          (twiddle_ram_rd_data_w)
  );


  /*  Cordic RAM  */
  assign  cordic_ram_wr_data_c  = lb2ram_wr_data_w[15:0];
  assign  cordic_ram_rd_addr_c  = lb2cordic_ram_rd_en_w ? lb2ram_addr_w : cordic_ram_rd_addr_w;
  //assign  cordic_ram_rd_addr_c  = lb2ram_addr_w;
  assign  cordic_ram_wr_addr_c  = lb2ram_addr_w;
  assign  cordic_ram_wr_en_c    = lb2cordic_ram_wr_en_w;

  cordic_ram  cordic_ram_inst
  (
    .data                       (cordic_ram_wr_data_c),
    .rdaddress                  (cordic_ram_rd_addr_c),
    .rdclock                    (clk_ir),
    .wraddress                  (cordic_ram_wr_addr_c),
    .wrclock                    (clk_ir),
    .wren                       (cordic_ram_wr_en_c),
    .q                          (cordic_ram_rd_data_w)
  );



  /*  Local bus decoder */
  fgyrus_lb   fgyrus_lb_inst
  (
    .clk_ir                     (clk_ir),
    .rst_il                     (rst_il),

    .fgyrus_en_oh               (fgyrus_en_w),
    .fgyrus_busy_ih             (fgyrus_busy_w),
    .fgyrus_fsm_pstate_id       (fgyrus_fsm_pstate_w),
    .fgyrus_fft_done_ih         (fgyrus_fft_done_w),
    .fgyrus_post_norm_od        (fgyrus_post_norm_w),

    .lb2ram_addr_od             (lb2ram_addr_w),
    .lb2fft_real_ram_wr_en_oh   (lb2fft_real_ram_wr_en_w),
    .lb2fft_im_ram_wr_en_oh     (lb2fft_im_ram_wr_en_w),
    .lb2twiddle_ram_wr_en_oh    (lb2twiddle_ram_wr_en_w),
    .lb2cordic_ram_wr_en_oh     (lb2cordic_ram_wr_en_w),
    .lb2fft_real_ram_rd_en_oh   (lb2fft_real_ram_rd_en_w),
    .lb2fft_im_ram_rd_en_oh     (lb2fft_im_ram_rd_en_w),
    .lb2twiddle_ram_rd_en_oh    (lb2twiddle_ram_rd_en_w),
    .lb2cordic_ram_rd_en_oh     (lb2cordic_ram_rd_en_w),
    .lb2ram_wr_data_od          (lb2ram_wr_data_w),
    .fft_real_ram_rd_data_id    (fft_ram_rd_real_data_w),
    .fft_im_ram_rd_data_id      (fft_ram_rd_im_data_w),
    .twiddle_ram_rd_real_data_id(twiddle_ram_rd_data_w[31:16]),
    .twiddle_ram_rd_im_data_id  (twiddle_ram_rd_data_w[15:0]),
    .cordic_ram_rd_data_id      (cordic_ram_rd_data_w),

    .irq_rst_ih                 (irq_rst_ih),
    .irq_oh                     (irq_oh),

    .lb_rd_en_ih                (lb_rd_en_ih),
    .lb_wr_en_ih                (lb_wr_en_ih),
    .lb_addr_id                 (lb_addr_id),
    .lb_wr_data_id              (lb_wr_data_id),
    .lb_rd_valid_od             (lb_rd_valid_od),
    .lb_wr_valid_od             (lb_wr_valid_od),
    .lb_rd_data_od              (lb_rd_data_od)
 
  );


  //synthesis translate_off
  syn_fgyrus_butter_if  butter_intf(clk_ir,rst_il);

  always@(*)
  begin
    butter_intf.sample_a_real  = sample_a_real_w;
    butter_intf.sample_a_im    = sample_a_im_w;
    butter_intf.sample_b_real  = sample_b_real_w;
    butter_intf.sample_b_im    = sample_b_im_w;
    butter_intf.twdl_real      = twdl_factor_real_w[9:0];
    butter_intf.twdl_im        = twdl_factor_im_w[9:0];
    butter_intf.samples_rdy    = samples_rdy_w;

    butter_intf.data_real      = data_real_w;
    butter_intf.data_im        = data_im_w;
    butter_intf.data_rdy       = data_rdy_w;
  end


  syn_fgyrus_fft_ram_if       fft_ram_intf(clk_ir,  rst_il);

  assign  fft_ram_intf.fft_done                     = fgyrus_fft_done_w;
  assign  fft_ram_intf.fft_ram_wr_real_en_w         = fft_ram_wr_real_en_w;
  assign  fft_ram_intf.fft_ram_wr_im_en_w           = fft_ram_wr_im_en_w;
  assign  fft_ram_intf.fft_ram_wr_addr_w            = fft_ram_wr_addr_w;
  assign  fft_ram_intf.fft_ram_wr_real_data_w       = fft_ram_wr_real_data_w;
  assign  fft_ram_intf.fft_ram_wr_im_data_w         = fft_ram_wr_im_data_w;
  assign  fft_ram_intf.pcm_done                     = fgyrus_pcm_done_w;

  //synthesis translate_on


endmodule // fgyrus_top
