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
 -- Module Name       : syn_lb_cdc_bridge
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block will carry LB transactions across clock
                        domains.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module syn_lb_cdc_bridge
  (
    //Host Side
    av_rst_il,                //Avalon Reset
    av_clk_ir,                //Avalon Clock
    av_read_ih,               //1->Read xtn
    av_write_ih,              //1->Write xtn
    av_wait_req_oh,           //1->Wait/stall xtn
    av_addr_id,               //Address
    av_write_data_id,         //Write Data
    av_read_data_valid_oh,    //1->av_read_data_od is valid
    av_read_data_od,          //Read Data

    //Internal Module Side
    lb_rst_il,                //Host Side reset
    lb_clk_ir,                //Host side clock
    lb_rd_en_oh,              //1->Read enable
    lb_wr_en_oh,              //1->Write enable
    lb_addr_od,               //Address input
    lb_wr_data_od,            //Write Data input
    lb_rd_valid_id,           //1->lb_rd_data_id is valid
    lb_rd_data_id,            //Read Data output
    lb_wr_valid_id            //1->write is valid

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_HST_ADDR_W      = 18;
  parameter P_HST_DATA_W      = 32;

  parameter P_LB_ADDR_W       = 16;
  parameter P_LB_DATA_W       = P_32B_W;

  parameter P_XTN_FF_DATA_W   = 96;
  parameter P_XTN_FF_USED_W   = 7;

  parameter P_XTN_FF_ADDR_RESERVE_W = P_32B_W - P_HST_ADDR_W;
  parameter P_XTN_FF_DATA_RESERVE_W = P_XTN_FF_DATA_W - (2*P_32B_W  + 1); //addr + data + r/w
  parameter P_XTN_FF_RDWR_SAMPLE    = 2*P_32B_W;  //bit to be sampled in XTN FF DATA

  parameter P_RSP_FF_DATA_W   = 32;
  parameter P_RSP_FF_USED_W   = 7;

//----------------------- Input Declarations ------------------------------
  input                       av_rst_il;
  input                       av_clk_ir;
  input                       av_read_ih;
  input                       av_write_ih;
  input   [P_HST_ADDR_W-1:0]  av_addr_id;
  input   [P_HST_DATA_W-1:0]  av_write_data_id;

  input                       lb_rst_il;
  input                       lb_clk_ir;
  input                       lb_rd_valid_id;
  input   [P_LB_DATA_W-1:0]   lb_rd_data_id;
  input                       lb_wr_valid_id;


//----------------------- Output Declarations -----------------------------
  output                      av_wait_req_oh;
  output                      av_read_data_valid_oh;
  output  [P_HST_DATA_W-1:0]  av_read_data_od;

  output                      lb_rd_en_oh;
  output                      lb_wr_en_oh;
  output  [P_LB_ADDR_W-1:0]   lb_addr_od;
  output  [P_LB_DATA_W-1:0]   lb_wr_data_od;

//----------------------- Output Register Declaration ---------------------
  reg                         av_read_data_valid_oh;
  reg     [P_HST_DATA_W-1:0]  av_read_data_od;

  reg                         lb_rd_en_oh;
  reg                         lb_wr_en_oh;
  reg     [P_LB_ADDR_W-1:0]   lb_addr_od;
  reg     [P_LB_DATA_W-1:0]   lb_wr_data_od;

//----------------------- Internal Register Declarations ------------------
  reg                         wait_for_rsp_f;

//----------------------- Internal Wire Declarations ----------------------
  wire    [P_XTN_FF_DATA_W-1:0] xtn_ff_wr_data_w;
  wire                          xtn_ff_wr_en_c;
  wire                          xtn_ff_full_w;
  wire                          xtn_ff_empty_w;
  wire    [P_XTN_FF_USED_W-1:0] xtn_ff_wr_used_w;
  wire    [P_XTN_FF_USED_W-1:0] xtn_ff_rd_used_w;
  wire    [P_XTN_FF_DATA_W-1:0] xtn_ff_rd_data_w;

  wire                          rsp_ff_full_w;
  wire                          rsp_ff_empty_w;
  wire    [P_RSP_FF_USED_W-1:0] rsp_ff_wr_used_w;
  wire    [P_RSP_FF_USED_W-1:0] rsp_ff_rd_used_w;
  wire    [P_RSP_FF_DATA_W-1:0] rsp_ff_rd_data_w;



//----------------------- Start of Code -----------------------------------

  //Combine data to be written into xtn_ff
  assign  xtn_ff_wr_data_w    = { {P_XTN_FF_DATA_RESERVE_W{1'b0}},
                                  av_read_ih,
                                  av_write_data_id,
                                  {P_XTN_FF_ADDR_RESERVE_W{1'b0}},
                                  av_addr_id
                                };

  //Write into xtn_ff only if FF has space & xtn is valid
  assign  xtn_ff_wr_en_c      = (av_read_ih | av_write_ih)  & ~xtn_ff_full_w;

  //xtn_ff full is used as wait request
  assign  av_wait_req_oh      = xtn_ff_full_w;

  /*
  * Driving xtn to LB
  */
  always@(posedge  lb_clk_ir,  negedge lb_rst_il)
  begin
    if(~lb_rst_il)
    begin
      lb_rd_en_oh             <=  1'b0;
      lb_wr_en_oh             <=  1'b0;
      lb_addr_od              <=  {P_LB_ADDR_W{1'b0}};
      lb_wr_data_od           <=  {P_LB_DATA_W{1'b0}};

      wait_for_rsp_f          <=  1'b0;
    end
    else
    begin
      //Use this flag to run each lb transaction
      wait_for_rsp_f          <=  wait_for_rsp_f  ? ~(lb_rd_valid_id  | lb_wr_valid_id)
                                                  : ~xtn_ff_empty_w;

      lb_rd_en_oh             <=  ~xtn_ff_empty_w & ~wait_for_rsp_f & xtn_ff_rd_data_w[P_XTN_FF_RDWR_SAMPLE];
      lb_wr_en_oh             <=  ~xtn_ff_empty_w & ~wait_for_rsp_f & ~xtn_ff_rd_data_w[P_XTN_FF_RDWR_SAMPLE];

      //lb_addr_od              <=  xtn_ff_rd_data_w[P_LB_ADDR_W-1:0];
      lb_addr_od              <=  xtn_ff_rd_data_w[P_LB_ADDR_W+1:2];  //discarding LS 2b

      lb_wr_data_od           <=  xtn_ff_rd_data_w[P_32B_W  +:  P_LB_DATA_W];
    end
  end

  /*
  * Driving rsp back to Host
  */
  always@(posedge  av_clk_ir,  negedge av_rst_il)
  begin
    if(~av_rst_il)
    begin
      av_read_data_valid_oh   <=  1'b0;
      av_read_data_od         <=  {P_HST_DATA_W{1'b0}};
    end
    else
    begin
      av_read_data_valid_oh   <=  ~rsp_ff_empty_w;
      av_read_data_od         <=  rsp_ff_empty_w  ? av_read_data_od : rsp_ff_rd_data_w;
    end
  end

  /*
  * xtn_ff
  * For sending transactions from Host->Lb
  */
  ff_96w_128d                 xtn_ff_inst
  (
    .aclr                     (~lb_rst_il),
    .data                     (xtn_ff_wr_data_w),
    .rdclk                    (lb_clk_ir),
    .rdreq                    (lb_rd_valid_id | lb_wr_valid_id),
    .wrclk                    (av_clk_ir),
    .wrreq                    (xtn_ff_wr_en_c),
    .q                        (xtn_ff_rd_data_w),
    .rdempty                  (xtn_ff_empty_w),
    .rdusedw                  (xtn_ff_rd_used_w),
    .wrfull                   (xtn_ff_full_w),
    .wrusedw                  (xtn_ff_wr_used_w)
  );

  /*
  * rsp_ff
  * Read data will be sent back to host via this fifo
  */
  ff_32w_128d                 rsp_ff_inst
  (
    .aclr                     (~av_rst_il),
    .data                     ({{P_16B_W{1'b0}},lb_rd_data_id}),
    .rdclk                    (av_clk_ir),
    .rdreq                    (~rsp_ff_empty_w),  //hmmm....
    .wrclk                    (lb_clk_ir),
    .wrreq                    (lb_rd_valid_id), //only read xtns need to be sent back as responses
    .q                        (rsp_ff_rd_data_w),
    .rdempty                  (rsp_ff_empty_w),
    .rdusedw                  (rsp_ff_rd_used_w),
    .wrfull                   (rsp_ff_full_w),
    .wrusedw                  (rsp_ff_wr_used_w)
  );



endmodule // syn_lb_cdc_bridge
