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
 -- Module Name       : syn_cortex_lb
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module routes LB transactions between acortex,
                        fgyrus & vcortex blocks.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module syn_cortex_lb
  (
    clk_ir,                   //Clock input
    rst_il,                   //Async active low reset

    //Local Bus interface
    lb_rd_en_ih,              //1->Read enable
    lb_wr_en_ih,              //1->Write enable
    lb_addr_id,               //Address input
    lb_wr_data_id,            //Write Data input
    lb_rd_valid_od,           //1->lb_rd_data_od is valid
    lb_rd_data_od,            //Read Data output
    lb_wr_valid_od,           //1->write is valid

    //NIOS Interrupt reset
    irq_rst_oh,               //1->Clear interrupts

    //Block interface
    blk_acortex_wr_en_oh,     //1->Write enable to acortex
    blk_acortex_rd_en_oh,     //1->Read  enable to acortex
    blk_vcortex_wr_en_oh,     //1->Write enable to vcortex
    blk_vcortex_rd_en_oh,     //1->Read  enable to vcortex
    blk_fgyrus_lchnl_wr_en_oh,//1->Write enable to fgyrus_lchnl
    blk_fgyrus_lchnl_rd_en_oh,//1->Read  enable to fgyrus_lchnl
    blk_fgyrus_rchnl_wr_en_oh,//1->Write enable to fgyrus_rchnl
    blk_fgyrus_rchnl_rd_en_oh,//1->Read  enable to fgyrus_rchnl
    blk_addr_od,              //Address to block
    blk_wr_data_od,           //Write data to block
    blk_acortex_wr_valid_ih,  //1->Write valid from acortex
    blk_acortex_rd_valid_ih,  //1->Read  valid from acortex
    blk_acortex_rd_data_id,   //Read data from acortex
    blk_vcortex_wr_valid_ih,  //1->Write valid from vcortex
    blk_vcortex_rd_valid_ih,  //1->Read  valid from vcortex
    blk_vcortex_rd_data_id,   //Read data from vcortex
    blk_fgyrus_lchnl_wr_valid_ih,  //1->Write valid from fgyrus_lchnl
    blk_fgyrus_lchnl_rd_valid_ih,  //1->Read  valid from fgyrus_lchnl
    blk_fgyrus_lchnl_rd_data_id,   //Read data from fgyrus_lchnl
    blk_fgyrus_rchnl_wr_valid_ih,  //1->Write valid from fgyrus_rchnl
    blk_fgyrus_rchnl_rd_valid_ih,  //1->Read  valid from fgyrus_rchnl
    blk_fgyrus_rchnl_rd_data_id    //Read data from fgyrus_rchnl


  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_LB_ADDR_W       = 16;
  parameter P_LB_DATA_W       = P_32B_W;

  parameter P_BLK_ADDR_W      = 12;
  parameter P_BLK_DATA_W      = P_32B_W;

  `include  "syn_cortex_reg_map.v"

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;

  input                       blk_acortex_wr_valid_ih;
  input                       blk_acortex_rd_valid_ih;
  input   [P_BLK_DATA_W-1:0]  blk_acortex_rd_data_id;
  input                       blk_vcortex_wr_valid_ih;
  input                       blk_vcortex_rd_valid_ih;
  input   [P_BLK_DATA_W-1:0]  blk_vcortex_rd_data_id;
  input                       blk_fgyrus_lchnl_wr_valid_ih;
  input                       blk_fgyrus_lchnl_rd_valid_ih;
  input   [P_BLK_DATA_W-1:0]  blk_fgyrus_lchnl_rd_data_id;
  input                       blk_fgyrus_rchnl_wr_valid_ih;
  input                       blk_fgyrus_rchnl_rd_valid_ih;
  input   [P_BLK_DATA_W-1:0]  blk_fgyrus_rchnl_rd_data_id;


//----------------------- Output Declarations -----------------------------
  output                      lb_rd_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;
  output                      lb_wr_valid_od;

  output                      blk_acortex_wr_en_oh;
  output                      blk_acortex_rd_en_oh;
  output                      blk_vcortex_wr_en_oh;
  output                      blk_vcortex_rd_en_oh;
  output                      blk_fgyrus_lchnl_wr_en_oh;
  output                      blk_fgyrus_lchnl_rd_en_oh;
  output                      blk_fgyrus_rchnl_wr_en_oh;
  output                      blk_fgyrus_rchnl_rd_en_oh;
  output  [P_BLK_ADDR_W-1:0]  blk_addr_od;
  output  [P_BLK_DATA_W-1:0]  blk_wr_data_od;

  output                      irq_rst_oh;
 
//----------------------- Output Register Declaration ---------------------
  reg                         lb_rd_valid_od;
  reg     [P_LB_DATA_W-1:0]   lb_rd_data_od;
  reg                         lb_wr_valid_od;



//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire    [3:0]               blk_code_w;

  wire                        acortex_sel_c;
  wire                        vcortex_sel_c;
  wire                        fgyrus_lchnl_sel_c;
  wire                        fgyrus_rchnl_sel_c;

//----------------------- Start of Code -----------------------------------

  //Tap block code from address space
  assign  blk_code_w          = lb_addr_id[P_LB_ADDR_W-1  -:  4]; //MS 4 bits

  //Generate select signals based on block decoding
  assign  acortex_sel_c       = (blk_code_w ==  ACORTEX_BLK)  ? 1'b1  : 1'b0;
  assign  vcortex_sel_c       = (blk_code_w ==  VCORTEX_BLK)  ? 1'b1  : 1'b0;
  assign  fgyrus_lchnl_sel_c  = (blk_code_w ==  FGYRUS_LCHNL_BLK) ? 1'b1  : 1'b0;
  assign  fgyrus_rchnl_sel_c  = (blk_code_w ==  FGYRUS_RCHNL_BLK) ? 1'b1  : 1'b0;

  //Generate interrupt clear pulse
  assign  irq_rst_oh          = (blk_code_w ==  IRQ_CLEAR_BLK)    ? 1'b0  : 1'b0;

  /*
  * Block routing logic
  */
  assign  blk_acortex_wr_en_oh        = acortex_sel_c & lb_wr_en_ih;
  assign  blk_acortex_rd_en_oh        = acortex_sel_c & lb_rd_en_ih;
  assign  blk_vcortex_wr_en_oh        = vcortex_sel_c & lb_wr_en_ih;
  assign  blk_vcortex_rd_en_oh        = vcortex_sel_c & lb_rd_en_ih;
  assign  blk_fgyrus_lchnl_wr_en_oh   = fgyrus_lchnl_sel_c  & lb_wr_en_ih;
  assign  blk_fgyrus_lchnl_rd_en_oh   = fgyrus_lchnl_sel_c  & lb_rd_en_ih;
  assign  blk_fgyrus_rchnl_wr_en_oh   = fgyrus_rchnl_sel_c  & lb_wr_en_ih;
  assign  blk_fgyrus_rchnl_rd_en_oh   = fgyrus_rchnl_sel_c  & lb_rd_en_ih;

  assign  blk_addr_od                 = lb_addr_id[P_BLK_ADDR_W-1:0];
  assign  blk_wr_data_od              = lb_wr_data_id;


  /*
  * Combining read responses
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb_rd_valid_od          <=  1'b0;
      lb_rd_data_od           <=  {P_LB_DATA_W{1'b0}};
      lb_wr_valid_od          <=  1'b0;
    end
    else
    begin
      lb_rd_valid_od          <=  blk_acortex_rd_valid_ih       |
                                  blk_vcortex_rd_valid_ih       |
                                  blk_fgyrus_lchnl_rd_valid_ih  |
                                  blk_fgyrus_rchnl_rd_valid_ih;

      case(1'b1)  //synthesis parallel_case full_case

        blk_acortex_rd_valid_ih :       lb_rd_data_od <=  blk_acortex_rd_data_id;

        blk_vcortex_rd_valid_ih :       lb_rd_data_od <=  blk_vcortex_rd_data_id;

        blk_fgyrus_lchnl_rd_valid_ih  : lb_rd_data_od <=  blk_fgyrus_lchnl_rd_data_id;

        blk_fgyrus_rchnl_rd_valid_ih  : lb_rd_data_od <=  blk_fgyrus_rchnl_rd_data_id;

        default :                       lb_rd_data_od <=  lb_rd_data_od;

      endcase

      lb_wr_valid_od          <=  blk_acortex_wr_valid_ih       |
                                  blk_vcortex_wr_valid_ih       |
                                  blk_fgyrus_lchnl_wr_valid_ih  |
                                  blk_fgyrus_rchnl_wr_valid_ih;
    end
  end


endmodule // syn_cortex_lb
