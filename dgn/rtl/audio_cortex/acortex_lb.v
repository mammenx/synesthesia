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
 -- Module Name       : acortex_lb.v
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block routes LB transactions to correct
                        ACORTEX blocks.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module acortex_lb
  (
    clk_ir,                   //Acortex System Clock
    rst_il,                   //Active Low Reset

    //Local Bus interface
    lb_rd_en_ih,              //1->Read enable
    lb_wr_en_ih,              //1->Write enable
    lb_addr_id,               //Address input
    lb_wr_data_id,            //Write Data input
    lb_rd_valid_od,           //1->lb_rd_data_od is valid
    lb_rd_data_od,            //Read Data output
    lb_wr_valid_od,           //1->write is valid

    //Host controlled reset trigger
    acortex_host_rst_ol,      //0->Reset the Acortex core

    //ADC Capture interface
    adc_lcap_raddr_od,        //Read address to ADC LCHANNEL Capture RAM
    adc_lcap_data_id,         //ADC LCHANNEL Capture data
    adc_rcap_raddr_od,        //Read address to ADC RCHANNEL Capture RAM
    adc_rcap_data_id,         //ADC LCHANNEL Capture data
    adc_start_cap_oh,         //1->Start ADC Capture
    adc_cap_busy_ih,          //1->ADC Capture in progress

    //Acortex Audio Source select
    acortex_aud_src_sel_od,   //1->Give data from Wav parser to Fgyrus
                              //0->Give data from ADC to fgyrus
 
    //Block Interface
    blk_i2c_rd_en_oh,         //1->Read enable to I2C
    blk_i2c_wr_en_oh,         //1->Write enable to I2C
    blk_sram_rd_en_oh,        //1->Read enable to SRAM 
    blk_sram_wr_en_oh,        //1->Write enable to SRAM
    blk_prsr_rd_en_oh,        //1->Read enable to parser
    blk_prsr_wr_en_oh,        //1->Write enable to parser
    blk_dac_rd_en_oh,         //1->Read enable to dac 
    blk_dac_wr_en_oh,         //1->Write enable to dac
    blk_addr_od,              //Address input
    blk_wr_data_od,           //Write Data input
    blk_i2c_rd_valid_id,      //1->Read valid from I2c
    blk_i2c_wr_valid_id,      //1->Write valid from I2c
    blk_i2c_rd_data_id,       //Read Data from I2C
    blk_sram_rd_valid_id,     //1->Read valid from SRAM
    blk_sram_wr_valid_id,     //1->Write valid from SRAM
    blk_sram_rd_data_id,      //Read Data from SRAM
    blk_prsr_rd_valid_id,     //1->Read valid from PRSR
    blk_prsr_wr_valid_id,     //1->Write valid from PRSR
    blk_prsr_rd_data_id,      //Read Data from PRSR
    blk_dac_rd_valid_id,      //1->Read valid from DAC
    blk_dac_wr_valid_id,      //1->Write valid from DAC
    blk_dac_rd_data_id        //Read Data from DAC
 
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_LB_ADDR_W       = 12;
  parameter P_LB_DATA_W       = P_16B_W;

  parameter P_BLK_ADDR_W      = P_8B_W;
  parameter P_BLK_DATA_W      = P_16B_W;

  `include  "acortex_reg_map.v"

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;

  input   [P_16B_W-1:0]       adc_lcap_data_id;
  input   [P_16B_W-1:0]       adc_rcap_data_id;
  input                       adc_cap_busy_ih;

  input                       blk_i2c_rd_valid_id;
  input                       blk_i2c_wr_valid_id;
  input   [P_LB_DATA_W-1:0]   blk_i2c_rd_data_id;
  input                       blk_sram_rd_valid_id;
  input                       blk_sram_wr_valid_id;
  input   [P_LB_DATA_W-1:0]   blk_sram_rd_data_id;
  input                       blk_prsr_rd_valid_id;
  input                       blk_prsr_wr_valid_id;
  input   [P_LB_DATA_W-1:0]   blk_prsr_rd_data_id;
  input                       blk_dac_rd_valid_id;
  input                       blk_dac_wr_valid_id;
  input   [P_LB_DATA_W-1:0]   blk_dac_rd_data_id;

//----------------------- Output Declarations -----------------------------
  output                      lb_rd_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;
  output                      lb_wr_valid_od;

  output                      acortex_host_rst_ol;

  output  [P_8B_W-1:0]        adc_lcap_raddr_od;
  output  [P_8B_W-1:0]        adc_rcap_raddr_od;
  output                      adc_start_cap_oh;

  output                      acortex_aud_src_sel_od;

  output                      blk_i2c_rd_en_oh;
  output                      blk_i2c_wr_en_oh;
  output                      blk_sram_rd_en_oh;
  output                      blk_sram_wr_en_oh;
  output                      blk_prsr_rd_en_oh;
  output                      blk_prsr_wr_en_oh;
  output                      blk_dac_rd_en_oh;
  output                      blk_dac_wr_en_oh;
  output  [P_BLK_ADDR_W-1:0]  blk_addr_od;
  output  [P_BLK_DATA_W-1:0]  blk_wr_data_od;

//----------------------- Output Register Declaration ---------------------
  reg                        lb_rd_valid_od;
  reg    [P_LB_DATA_W-1:0]   lb_rd_data_od;
  reg                        lb_wr_valid_od;

  reg    [P_8B_W-1:0]        adc_lcap_raddr_od;
  reg    [P_8B_W-1:0]        adc_rcap_raddr_od;
  reg                        adc_start_cap_oh;

  reg                        acortex_aud_src_sel_od;


//----------------------- Internal Register Declarations ------------------
  reg   [2:0]                pst_vec_f;


//----------------------- Internal Wire Declarations ----------------------
  wire                        blk_i2c_sel_c;
  wire                        blk_sram_sel_c;
  wire                        blk_prsr_sel_c;
  wire                        blk_dac_sel_c;
  wire                        blk_adc_lcap_sel_c;
  wire                        blk_adc_rcap_sel_c;
  wire                        blk_adc_start_cap_sel_c;
  wire                        blk_acortex_aud_src_sel_c;

  wire                        blk_adc_lcap_wren_c;
  wire                        blk_adc_rcap_wren_c;
  wire                        blk_adc_start_cap_wren_c;
  wire                        blk_acortex_aud_src_wren_c;

  wire                        blk_adc_lcap_rden_c;
  wire                        blk_adc_rcap_rden_c;
  wire                        blk_adc_start_cap_rden_c;
  wire                        blk_acortex_aud_src_rden_c;

//----------------------- Start of Code -----------------------------------

  //Decode Block
  assign  blk_i2c_sel_c       = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  I2C_DRIVER) ? 1'b1  : 1'b0;
  assign  blk_sram_sel_c      = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  SRAM) ? 1'b1  : 1'b0;
  assign  blk_prsr_sel_c      = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  WAV_PRSR) ? 1'b1  : 1'b0;
  assign  blk_dac_sel_c       = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  DAC_DRVR) ? 1'b1  : 1'b0;
  assign  blk_adc_lcap_sel_c  = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  ADC_LCAPTURE_RAM) ? 1'b1  : 1'b0;
  assign  blk_adc_rcap_sel_c  = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  ADC_RCAPTURE_RAM) ? 1'b1  : 1'b0;
  assign  blk_adc_start_cap_sel_c   = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  ADC_START_CAPTURE) ? 1'b1  : 1'b0;
  assign  blk_acortex_aud_src_sel_c = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  ACORTEX_AUDIO_SRC_SEL_REG) ? 1'b1  : 1'b0;

  //Host reset decoding
  assign  acortex_host_rst_ol = (lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W] ==  RESET)  ? ~lb_wr_en_ih  : 1'b1;

  //Assign Outputs
  assign  blk_i2c_rd_en_oh    = blk_i2c_sel_c & lb_rd_en_ih;
  assign  blk_i2c_wr_en_oh    = blk_i2c_sel_c & lb_wr_en_ih;
  assign  blk_sram_rd_en_oh   = blk_sram_sel_c & lb_rd_en_ih;
  assign  blk_sram_wr_en_oh   = blk_sram_sel_c & lb_wr_en_ih;
  assign  blk_prsr_rd_en_oh   = blk_prsr_sel_c & lb_rd_en_ih;
  assign  blk_prsr_wr_en_oh   = blk_prsr_sel_c & lb_wr_en_ih;
  assign  blk_dac_rd_en_oh    = blk_dac_sel_c & lb_rd_en_ih;
  assign  blk_dac_wr_en_oh    = blk_dac_sel_c & lb_wr_en_ih;
  assign  blk_addr_od         = lb_addr_id[P_BLK_ADDR_W-1:0];
  assign  blk_wr_data_od      = lb_wr_data_id;

  //Generating internal R/W xtns
  assign  blk_adc_lcap_wren_c         = lb_wr_en_ih & blk_adc_lcap_sel_c;
  assign  blk_adc_rcap_wren_c         = lb_wr_en_ih & blk_adc_rcap_sel_c;
  assign  blk_adc_start_cap_wren_c    = lb_wr_en_ih & blk_adc_start_cap_sel_c;
  assign  blk_acortex_aud_src_wren_c  = lb_wr_en_ih & blk_acortex_aud_src_sel_c;

  assign  blk_adc_lcap_rden_c         = lb_rd_en_ih & blk_adc_lcap_sel_c;
  assign  blk_adc_rcap_rden_c         = lb_rd_en_ih & blk_adc_rcap_sel_c;
  assign  blk_adc_start_cap_rden_c    = lb_rd_en_ih & blk_adc_start_cap_sel_c;
  assign  blk_acortex_aud_src_rden_c  = lb_rd_en_ih & blk_acortex_aud_src_sel_c;

  /*
    * Combining read/write valids
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb_rd_valid_od          <=  1'b0;
      lb_wr_valid_od          <=  1'b0;
      lb_rd_data_od           <=  {P_LB_DATA_W{1'b0}};

      adc_lcap_raddr_od       <=  {P_8B_W{1'b0}};
      adc_rcap_raddr_od       <=  {P_8B_W{1'b0}};
      adc_start_cap_oh        <=  1'b0;

      `ifdef  SIMULATION
        acortex_aud_src_sel_od<=  1'b1; //default is wav prsr
      `else
        acortex_aud_src_sel_od<=  1'b0; //default is adc
      `endif

      pst_vec_f               <=  3'd0; //for generating correct rd_valids
    end
    else
    begin
      adc_lcap_raddr_od       <=  blk_adc_lcap_wren_c ? lb_wr_data_id[P_8B_W-1:0] : adc_lcap_raddr_od;
      adc_rcap_raddr_od       <=  blk_adc_rcap_wren_c ? lb_wr_data_id[P_8B_W-1:0] : adc_rcap_raddr_od;
      adc_start_cap_oh        <=  blk_adc_start_cap_wren_c  & ~adc_start_cap_oh;

      acortex_aud_src_sel_od  <=  blk_acortex_aud_src_wren_c  ? lb_wr_data_id[0]  : acortex_aud_src_sel_od;

      pst_vec_f[0]            <=  blk_adc_lcap_rden_c | blk_adc_rcap_rden_c   | blk_adc_start_cap_rden_c  | blk_acortex_aud_src_rden_c;
      pst_vec_f[2:1]          <=  pst_vec_f[1:0];

      lb_rd_valid_od          <=  blk_i2c_rd_valid_id | blk_sram_rd_valid_id  | blk_prsr_rd_valid_id  | blk_dac_rd_valid_id | ~acortex_host_rst_ol  |
                                  pst_vec_f[2];

      lb_wr_valid_od          <=  blk_i2c_wr_valid_id | blk_sram_wr_valid_id  | blk_prsr_wr_valid_id  | blk_dac_wr_valid_id | ~acortex_host_rst_ol  |
                                  blk_adc_lcap_wren_c | blk_adc_rcap_wren_c   | blk_adc_start_cap_wren_c  | blk_acortex_aud_src_wren_c;

      case(lb_addr_id[P_LB_ADDR_W-1:P_BLK_ADDR_W])

        I2C_DRIVER  :   lb_rd_data_od <=  blk_i2c_rd_data_id;

        SRAM  :         lb_rd_data_od <=  blk_sram_rd_data_id;

        WAV_PRSR  :     lb_rd_data_od <=  blk_prsr_rd_data_id;

        DAC_DRVR  :     lb_rd_data_od <=  blk_dac_rd_data_id;

        RESET :         lb_rd_data_od <=  16'hcafe;

        ADC_LCAPTURE_RAM  : lb_rd_data_od <=  adc_lcap_data_id;

        ADC_RCAPTURE_RAM  : lb_rd_data_od <=  adc_rcap_data_id;

        ADC_START_CAPTURE : lb_rd_data_od <=  {{P_LB_DATA_W-1{1'b0}},adc_cap_busy_ih};

        ACORTEX_AUDIO_SRC_SEL_REG : lb_rd_data_od <=  {{P_LB_DATA_W-1{1'b0}},acortex_aud_src_sel_od};

        default :       lb_rd_data_od <=  16'hdead;

      endcase
    end
  end

endmodule // acortex_lb
