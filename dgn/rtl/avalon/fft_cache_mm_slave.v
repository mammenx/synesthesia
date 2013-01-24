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
 -- Module Name       : fft_cache_mm_sl
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module decodes Avalon transaction to read data
                        from FFT Result RAMs. Only Read xtns are supported
                        on Avalon bus.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module fft_cache_mm_sl
  (
    av_clk_ir,                //Avalon clock
    av_rst_il,                //Active low reset

    //Avalon MM Interface
    av_read_ih,               //1->Read xtn
    av_addr_id,               //Address
    av_read_data_od,          //Read Data
    av_read_data_valid_oh,    //1->Read data is valid

    //FFT Result RAM interface
    fft_res_ram_rd_addr_od,   //Read address to FFT Result RAM
    fft_res_ram_lchnl_data_id,//Read data from Lchannel FFT Result RAM
    fft_res_ram_rchnl_data_id //Read data from Lchannel FFT Result RAM

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_LB_ADDR_W       = 10;
  parameter P_LB_DATA_W       = P_32B_W;

  parameter P_FFT_RAM_ADDR_W  = 7;
  parameter P_FFT_RAM_DATA_W  = P_32B_W;

  parameter  P_RD_DELAY       = 2;  //No of cycles to access MRAM


//----------------------- Input Declarations ------------------------------
  input                       av_clk_ir;
  input                       av_rst_il;

  input                       av_read_ih;
  input   [P_LB_ADDR_W-1:0]   av_addr_id;

  input   [P_FFT_RAM_DATA_W-1:0]  fft_res_ram_lchnl_data_id;
  input   [P_FFT_RAM_DATA_W-1:0]  fft_res_ram_rchnl_data_id;


//----------------------- Output Declarations -----------------------------
  output  [P_LB_DATA_W-1:0]   av_read_data_od;
  output                      av_read_data_valid_oh;

  output  [P_FFT_RAM_ADDR_W-1:0]  fft_res_ram_rd_addr_od;


//----------------------- Output Register Declaration ---------------------
  reg     [P_LB_DATA_W-1:0]   av_read_data_od;
  reg                         av_read_data_valid_oh;

//----------------------- Internal Register Declarations ------------------
  reg     [P_RD_DELAY-1:0]    pst_vec_f;
  reg     [P_RD_DELAY-1:0]    fft_res_l_n_r_sel_f;  //1->LChannel data, 0->RChannel data

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Start of Code -----------------------------------

  //Assign FFT Res RAM Read address
  assign  fft_res_ram_rd_addr_od  = av_addr_id[2  +:  P_FFT_RAM_ADDR_W];  //Discard LS 2 bts

  always@(posedge av_clk_ir,  negedge av_rst_il)
  begin
    if(~av_rst_il)
    begin
      av_read_data_od         <=  {P_LB_ADDR_W{1'b0}};
      av_read_data_valid_oh   <=  1'b0;

      pst_vec_f               <=  {P_RD_DELAY{1'b0}};
      fft_res_l_n_r_sel_f     <=  {P_RD_DELAY{1'b0}};
    end
    else
    begin
      pst_vec_f               <=  {pst_vec_f[P_RD_DELAY-2:0],av_read_ih};
      fft_res_l_n_r_sel_f     <=  {fft_res_l_n_r_sel_f[P_RD_DELAY-2:0],av_addr_id[P_LB_ADDR_W-1]};  //MSB of av addr decides which channel to read

      av_read_data_valid_oh   <=  pst_vec_f[P_RD_DELAY-1];

      if(pst_vec_f[P_RD_DELAY-1:0])
      begin
        av_read_data_od       <=  fft_res_l_n_r_sel_f ? fft_res_ram_lchnl_data_id : fft_res_ram_rchnl_data_id;
      end
      else
      begin
        av_read_data_od       <=  av_read_data_od;
      end
    end
  end


endmodule // fft_cache_mm_sl
