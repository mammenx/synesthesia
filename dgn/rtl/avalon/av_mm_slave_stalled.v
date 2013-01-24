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
 -- Module Name       : av_slave_stalled
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This modules decodes Avalon MM transactions &
                        stalls each one by means of wait_req.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module av_slave_stalled
  (
    av_clk_ir,                //Avalon clock
    av_rst_il,                //Active low reset

    //Avalon MM Interface
    av_read_ih,               //1->Read xtn
    av_write_ih,              //1->Write xtn
    av_begin_xfr_ih,          //1->Begin xfr
    av_wait_req_oh,           //1->Wait/stall xtn
    av_addr_id,               //Address
    av_write_data_id,         //Write Data
    av_read_data_od,          //Read Data

    //Local Bus interface
    lb_rd_en_oh,              //1->Read enable
    lb_wr_en_oh,              //1->Write enable
    lb_addr_od,               //Address input
    lb_wr_data_od,            //Write Data input
    lb_rd_valid_id,           //1->lb_rd_data_od is valid
    lb_rd_data_id,            //Read Data output
    lb_wr_valid_id            //1->write is valid


  );

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------
  input                       av_clk_ir;
  input                       av_rst_il;

  input                       av_read_ih;
  input                       av_write_ih;
  input                       av_begin_xfr_ih;
  input   [11:0]              av_addr_id;
  input   [15:0]              av_write_data_id;

  input                       lb_rd_valid_id;
  input   [15:0]              lb_rd_data_id;
  input                       lb_wr_valid_id;

//----------------------- Output Declarations -----------------------------
  output                      av_wait_req_oh;
  output  [15:0]              av_read_data_od;

  output                      lb_rd_en_oh;
  output                      lb_wr_en_oh;
  output  [11:0]              lb_addr_od;
  output  [15:0]              lb_wr_data_od;

//----------------------- Output Register Declaration ---------------------
  reg     [15:0]              av_read_data_od;


//----------------------- Internal Register Declarations ------------------
  reg                         xtn_valid_f;

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Start of Code -----------------------------------

  assign  av_wait_req_oh      = (av_read_ih | av_write_ih)  & ~xtn_valid_f;

  always@(posedge av_clk_ir,  negedge av_rst_il)
  begin
    if(~av_rst_il)
    begin
      xtn_valid_f             <=  1'b0;
      av_read_data_od         <=  16'd0;
    end
    else
    begin
      xtn_valid_f             <=  lb_wr_valid_id  | lb_rd_valid_id;

      av_read_data_od         <=  lb_rd_valid_id  ? lb_rd_data_id : av_read_data_od;
    end
  end

  assign  lb_rd_en_oh         = av_begin_xfr_ih & av_read_ih;
  assign  lb_wr_en_oh         = av_begin_xfr_ih & av_write_ih;
  assign  lb_addr_od          = av_addr_id;
  assign  lb_wr_data_od       = av_write_data_id;

endmodule // av_slave_stalled
