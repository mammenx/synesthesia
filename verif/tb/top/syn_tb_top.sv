`ifndef __SYN_TB_TOP
`define __SYN_TB_TOP

  /////////////////////////////////////////////////////
  // Importing OVM Packages                          //
  /////////////////////////////////////////////////////

  `include "ovm.svh"
  import ovm_pkg::*;

  `timescale  1ns/100ps

  module syn_tb_top();

    `include  "include.list"

    //Clock Reset signals
    logic   sys_clk_100;
    logic   sys_clk_50;
    logic   sys_rst;

    logic [3:0] mclk_vec;



    //Interfaces
    syn_acortex2fgyrus_if acortex2fgyrus_if_lchnl(sys_clk_100);
    syn_acortex2fgyrus_if acortex2fgyrus_if_rchnl(sys_clk_100);
    syn_aud_codec_if      aud_codec_if(mclk_vec,sys_rst);
    syn_av_mm_if_0        av_mm_if_0(sys_clk_50,sys_rst);
    syn_av_mm_if_1        av_mm_if_1_lchnl(sys_clk_100,sys_rst);
    syn_av_mm_if_1        av_mm_if_1_rchnl(sys_clk_100,sys_rst);
    syn_av_mm_if_2        av_mm_if_2_vcortex(sys_clk_50,sys_rst);
    syn_av_st_if          av_st_if(sys_clk_50,sys_rst);
    syn_sram_if           sram_if();
    syn_cortex_lb_if      cortex_lb_if(sys_clk_100,sys_rst);
    syn_pwm_if            pwm_if(sys_rst);



    /////////////////////////////////////////////////////
    // Clock Declaration and Generation                //
    /////////////////////////////////////////////////////
    initial
    begin
      sys_clk_100  = 1;

      #100;
      forever #5ns  sys_clk_100 = ~sys_clk_100;
    end

    initial
    begin
      sys_clk_50    = 1;

      #111;

      forever #10ns sys_clk_50  = ~sys_clk_50;

    end

    initial
    begin
      mclk_vec[0] = 0;

      #10;

      forever #27ns mclk_vec[0] = ~mclk_vec[0];

    end

    initial
    begin
      mclk_vec[1] = 0;

      #11;

      forever #31ns mclk_vec[1] = ~mclk_vec[1];

    end

    initial
    begin
      mclk_vec[2] = 0;

      #12;

      forever #42ns mclk_vec[2] = ~mclk_vec[2];

    end

    initial
    begin
      mclk_vec[3] = 0;

      #13;

      forever #46ns mclk_vec[3] = ~mclk_vec[3];

    end


    initial
    begin
      sys_rst   = 1;

      #123;

      sys_rst   = 0;

      #321;

      sys_rst   = 1;

    end

    /*  DUT */

    syn_cortex_top            syn_cortex_top_inst
    (
      .clk_50_ir              (sys_clk_50),
      .sys_rst_il             (sys_rst),

      .mclk_pll_ir            (aud_codec_if.mclk_pll),

      .av_st_data_id          (av_st_if.av_st_data),
      .av_st_ready_oh         (av_st_if.av_st_ready),
      .av_st_valid_ih         (av_st_if.av_st_valid),
      .av_st_sop_ih           (av_st_if.av_st_sop),
      .av_st_eop_ih           (av_st_if.av_st_eop),

      .av_rst_il              (sys_rst),
      .av_clk_ir              (sys_clk_100),
      .av_read_ih             (cortex_lb_if.av_read),
      .av_write_ih            (cortex_lb_if.av_write),
      .av_wait_req_oh         (cortex_lb_if.av_wait_req),
      .av_addr_id             ({cortex_lb_if.av_addr,2'b00}),
      .av_write_data_id       (cortex_lb_if.av_write_data),
      .av_read_data_valid_oh  (cortex_lb_if.av_read_data_valid),
      .av_read_data_od        (cortex_lb_if.av_read_data),

      /*  Not Used in TB ..... yet !  */
      .av_fft_cache_read_ih             ('d0),
      .av_fft_cache_addr_id             ('d0),
      .av_fft_cache_read_data_od        (),
      .av_fft_cache_read_data_valid_oh  (),
      .av_fft_cache_rst_il              (sys_rst),

      .sram_dq                (sram_if.sram_dq),
      .sram_addr_od           (sram_if.sram_addr),
      .sram_lb_ol             (sram_if.sram_lb_n),
      .sram_ub_ol             (sram_if.sram_ub_n),
      .sram_ce_ol             (sram_if.sram_ce_n),
      .sram_oe_ol             (sram_if.sram_oe_n),
      .sram_we_ol             (sram_if.sram_we_n),

      .i2c_sda_io             (aud_codec_if.sda),
      .i2c_scl_od             (aud_codec_if.scl),

      .aud_mclk_od            (aud_codec_if.dac_mclk),
      .aud_blck_od            (aud_codec_if.dac_bclk),
      .aud_adc_dat_id         (aud_codec_if.adc_dat),
      .aud_adc_lrc_od         (aud_codec_if.adc_lrc),
      .aud_dac_dat_od         (aud_codec_if.dac_dat),
      .aud_dac_lrc_od         (aud_codec_if.dac_lrc),

      .pwm_data_od            (pwm_if.pwm_data)
    );


    initial
    begin
      $vcdpluson;
      #1;

      run_test();
    end

  endmodule

`endif
