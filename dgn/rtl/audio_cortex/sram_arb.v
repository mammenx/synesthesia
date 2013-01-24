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
 -- Module Name       : sram_arb
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block arbitrates SRAM access between local bus
                        & internal modules.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sram_arb
  (
    clk_ir,                   //Clock input
    rst_il,                   //Active low reset

    //Local Bus interface 0 [Avalon Streaming I/F]
    lb_st_data_id,            //Data
    lb_st_ready_oh,           //1->SRAM ready for data, 0->SRAM full
    lb_st_valid_ih,           //1->Transaction valid
    lb_st_sop_ih,             //1->Start of packet
    lb_st_eop_ih,             //1->End of packet

    //Local Bus interface 1 [Avalon MM]
    lb_mm_rd_en_ih,           //1->Read enable
    lb_mm_wr_en_ih,           //1->Write enable
    lb_mm_addr_id,            //Address input
    lb_mm_wr_data_id,         //Write Data input
    lb_mm_rd_valid_od,        //1->lb_rd_data_od is valid
    lb_mm_rd_data_od,         //Read Data output
    lb_mm_arb_grant_oh,       //1->Access granted to MM

    //Internal Module interface
    im_rd_req_ih,             //1->Read request
    im_rd_valid_oh,           //1->Read data is valid
    im_rd_data_od,            //Read Data

    //SRAM FIFO Controller interface
    sram_ff_rd_en_oh,         //Read enable to SRAM FIFO
    sram_ff_wr_en_oh,         //Write enable to SRAM FIFO
    sram_ff_rd_addr_id,       //SRAM FIFO Read address
    sram_ff_wr_addr_id,       //SRAM FIFO Write address
    sram_ff_full_ih,          //1->SRAM is full
    sram_ff_empty_ih,         //1->SRAM is empty;

    //SRAM Driver interface
    sram_wr_en_oh,            //1->Write Enable to SRAM
    sram_rd_en_oh,            //1->Write Enable to SRAM
    sram_addr_od,             //SRAM Address
    sram_rd_data_id,          //SRAM Read data
    sram_wr_data_od           //SRAM Write data

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_ARB_LEN         = 16; //No of clocks to give for grants
  localparam  P_ARB_CNTR_W    = $clog2(P_ARB_LEN);

  parameter P_SRAM_ADDR_W     = 18;

  parameter P_AV_ST_SEL       = 2'd0;
  parameter P_AV_MM_SEL_1     = 2'd1;
  parameter P_IM_SEL          = 2'd2;
  parameter P_AV_MM_SEL_2     = 2'd3;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input   [15:0]              lb_st_data_id;
  input                       lb_st_valid_ih;
  input                       lb_st_sop_ih;
  input                       lb_st_eop_ih;

  input                       lb_mm_rd_en_ih;
  input                       lb_mm_wr_en_ih;
  input   [17:0]              lb_mm_addr_id;
  input   [15:0]              lb_mm_wr_data_id;

  input                       im_rd_req_ih;

  input   [17:0]              sram_ff_rd_addr_id;
  input   [17:0]              sram_ff_wr_addr_id;
  input                       sram_ff_full_ih;
  input                       sram_ff_empty_ih;

  input   [15:0]              sram_rd_data_id;

//----------------------- Output Declarations -----------------------------
  output                      lb_st_ready_oh;

  output                      im_rd_valid_oh;
  output  [15:0]              im_rd_data_od;

  output                      lb_mm_rd_valid_od;
  output  [15:0]              lb_mm_rd_data_od;
  output                      lb_mm_arb_grant_oh;

  output                      sram_ff_rd_en_oh;
  output                      sram_ff_wr_en_oh;

  output                      sram_wr_en_oh;
  output                      sram_rd_en_oh;
  output  [17:0]              sram_addr_od;
  output  [15:0]              sram_wr_data_od;

//----------------------- Output Register Declaration ---------------------
  reg                         im_rd_valid_oh;

  reg                         lb_mm_rd_valid_od;

  reg                         sram_wr_en_oh;
  reg                         sram_rd_en_oh;
  reg     [17:0]              sram_addr_od;
  reg     [15:0]              sram_wr_data_od;

//----------------------- Internal Register Declarations ------------------
  reg     [1:0]               arb_sel_f   /*synthesis preserve syn_encoding = "user"*/;
  reg     [P_ARB_CNTR_W-1:0]  arb_cntr_f;

  reg                         arb_av_mm_rd_req_1d;
  reg                         arb_im_rd_req_1d;
  reg                         arb_av_mm_rd_req_2d;
  reg                         arb_im_rd_req_2d;

//----------------------- Internal Wire Declarations ----------------------
  wire                        arb_cntr_wrap_c;
  wire                        arb_av_st_sel_c;
  wire                        arb_av_mm_sel_1_c;
  wire                        arb_av_mm_sel_2_c;
  wire                        arb_im_sel_c;



//----------------------- Start of Code -----------------------------------

  /*
    * Arbiter Counter Logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      arb_cntr_f              <=  {P_ARB_CNTR_W{1'b0}};
    end
    else
    begin
      if(arb_cntr_wrap_c)
      begin
        arb_cntr_f            <=  {P_ARB_CNTR_W{1'b0}};
      end
      else if(~(arb_av_mm_sel_1_c | arb_av_mm_sel_2_c)) //MM user gets only one slot!
      begin
        arb_cntr_f            <=  arb_cntr_f  + 1'b1;
      end
    end
  end

  //Check if arb_cntr_f has to rollover
  assign  arb_cntr_wrap_c     = (arb_cntr_f ==  (P_ARB_LEN-1))  ? 1'b1  : 1'b0;

  //Decode Arbitration selection
  assign  arb_av_st_sel_c     = (arb_sel_f  ==  P_AV_ST_SEL)  ? 1'b1  : 1'b0;
  assign  arb_av_mm_sel_1_c   = (arb_sel_f  ==  P_AV_MM_SEL_1)? 1'b1  : 1'b0;
  assign  arb_av_mm_sel_2_c   = (arb_sel_f  ==  P_AV_MM_SEL_2)? 1'b1  : 1'b0;
  assign  arb_im_sel_c        = (arb_sel_f  ==  P_IM_SEL)     ? 1'b1  : 1'b0;

  /*
    * Arbiter select logic
    * Simple TDM
    * AV ST [P_ARB_LEN clks] ->  AV MM [1 clk] ->  IM [P_ARB_LEN clks]  ->  AV MM [1 clk]
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      arb_sel_f               <=  P_AV_ST_SEL;
    end
    else
    begin
      case(arb_sel_f) //synthesis full_case

        P_AV_ST_SEL :
        begin
          arb_sel_f           <=  arb_cntr_wrap_c ? P_AV_MM_SEL_1 : arb_sel_f;
        end

        P_AV_MM_SEL_1 :
        begin
          arb_sel_f           <=  P_IM_SEL;
        end

        P_IM_SEL  :
        begin
          arb_sel_f           <=  arb_cntr_wrap_c ? P_AV_MM_SEL_2 : arb_sel_f;
        end

        P_AV_MM_SEL_2 :
        begin
          arb_sel_f           <=  P_AV_ST_SEL;
        end
      endcase
    end
  end


  //Avalon ST ready assertion logic
  assign  lb_st_ready_oh      = arb_av_st_sel_c;


  //Logic for issuing reads/writes to SRAM FIFO controller
  assign  sram_ff_rd_en_oh    = arb_im_sel_c    ? im_rd_req_ih    : 1'b0;
  assign  sram_ff_wr_en_oh    = arb_av_st_sel_c ? lb_st_valid_ih  : 1'b0;

  /*
    * SRAM  Muxing logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sram_wr_en_oh           <=  1'b0;
      sram_rd_en_oh           <=  1'b0;
      sram_addr_od            <=  18'd0;
      sram_wr_data_od         <=  16'd0;
    end
    else
    begin
      case(arb_sel_f) //synthesis full_case
        P_AV_ST_SEL :
        begin
          sram_wr_en_oh       <=  lb_st_valid_ih  & ~sram_ff_full_ih;
          sram_rd_en_oh       <=  1'b0;
          sram_addr_od        <=  sram_ff_wr_addr_id;
          sram_wr_data_od     <=  lb_st_data_id;
        end

        P_AV_MM_SEL_1 :
        begin
          sram_wr_en_oh       <=  lb_mm_wr_en_ih;
          sram_rd_en_oh       <=  lb_mm_rd_en_ih;
          sram_addr_od        <=  lb_mm_addr_id;
          sram_wr_data_od     <=  lb_mm_wr_data_id;
        end

        P_IM_SEL  :
        begin
          sram_wr_en_oh       <=  1'b0;
          sram_rd_en_oh       <=  im_rd_req_ih  & ~sram_ff_empty_ih;
          sram_addr_od        <=  sram_ff_rd_addr_id;
          sram_wr_data_od     <=  sram_wr_data_od;
        end

        P_AV_MM_SEL_2 :
        begin
          sram_wr_en_oh       <=  lb_mm_wr_en_ih;
          sram_rd_en_oh       <=  lb_mm_rd_en_ih;
          sram_addr_od        <=  lb_mm_addr_id;
          sram_wr_data_od     <=  lb_mm_wr_data_id;
        end

      endcase
    end
  end

  /*
    * Read valid logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      arb_av_mm_rd_req_1d     <=  1'b0;
      arb_im_rd_req_1d        <=  1'b0;
      arb_av_mm_rd_req_2d     <=  1'b0;
      arb_im_rd_req_2d        <=  1'b0;

      im_rd_valid_oh          <=  1'b0;
      lb_mm_rd_valid_od       <=  1'b0;
    end
    else
    begin
      arb_av_mm_rd_req_1d     <=  (arb_av_mm_sel_1_c  | arb_av_mm_sel_2_c)  & lb_mm_rd_en_ih;
      arb_im_rd_req_1d        <=  arb_im_sel_c  & im_rd_req_ih  & ~sram_ff_empty_ih;

      arb_av_mm_rd_req_2d     <=  arb_av_mm_rd_req_1d;
      arb_im_rd_req_2d        <=  arb_im_rd_req_1d;

      im_rd_valid_oh          <=  arb_im_rd_req_2d;
      lb_mm_rd_valid_od       <=  arb_av_mm_rd_req_2d;
    end
  end

  //Assign read data
  assign  im_rd_data_od       =   sram_rd_data_id;
  assign  lb_mm_rd_data_od    =   sram_rd_data_id;

  //Expose MM grant signal
  assign  lb_mm_arb_grant_oh  = arb_av_mm_sel_1_c | arb_av_mm_sel_2_c;

endmodule // sram_arb
