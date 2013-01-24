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
 -- Module Name       : sram_ff_cntrlr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module maintains the read/write pointers for
                        SRAM addressing in FIFO mode.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sram_ff_cntrlr
  (
    clk_ir,                   //Clock Input
    rst_il,                   //Active low reset

    //Control Interface
    sram_ff_rd_en_ih,         //1->Read data from SRAM
    sram_ff_wr_en_ih,         //1->Write data to SRAM

    //Status Interface
    sram_empty_oh,            //1->SRAM is empty
    sram_full_oh,             //1->SRAM is full
    sram_aempty_oh,           //1->SRAM is less that 25% occupied

    //Address Interface
    sram_rd_addr_od,          //Current SRAM Read address
    sram_wr_addr_od           //Current SRAM Write address
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_SRAM_ADDR_W     = 18;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       sram_ff_rd_en_ih;
  input                       sram_ff_wr_en_ih;

//----------------------- Output Declarations -----------------------------
  output                      sram_empty_oh;
  output                      sram_full_oh;
  output                      sram_aempty_oh;

  output  [P_SRAM_ADDR_W-1:0] sram_rd_addr_od;
  output  [P_SRAM_ADDR_W-1:0] sram_wr_addr_od;

//----------------------- Output Register Declaration ---------------------
  reg                         sram_empty_oh;
  reg                         sram_full_oh;
  reg                         sram_aempty_oh;

//----------------------- Internal Register Declarations ------------------
  reg     [P_SRAM_ADDR_W:0]   sram_rd_ptr_f;
  reg     [P_SRAM_ADDR_W:0]   sram_wr_ptr_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                        inc_rd_addr_c;
  wire                        inc_wr_addr_c;

  wire    [P_SRAM_ADDR_W:0]   sram_rd_ptr_n;
  wire    [P_SRAM_ADDR_W:0]   sram_wr_ptr_n;
  wire    [P_SRAM_ADDR_W:0]   sram_rd_ptr_gry_n;
  wire    [P_SRAM_ADDR_W:0]   sram_wr_ptr_gry_n;

//----------------------- Start of Code -----------------------------------

  //Read/Write address increment logic
  assign  inc_rd_addr_c       = sram_ff_rd_en_ih & ~sram_empty_oh;
  assign  inc_wr_addr_c       = sram_ff_wr_en_ih & ~sram_full_oh;

  //Calculate next values of pointers
  assign  sram_rd_ptr_n       = sram_rd_ptr_f + inc_rd_addr_c;
  assign  sram_wr_ptr_n       = sram_wr_ptr_f + inc_wr_addr_c;

  /*
    * SRAM Read/Write pointer logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sram_rd_ptr_f           <=  {P_SRAM_ADDR_W+1{1'b0}};
      sram_wr_ptr_f           <=  {P_SRAM_ADDR_W+1{1'b0}};
    end
    else
    begin
      sram_rd_ptr_f           <=  sram_rd_ptr_n;
      sram_wr_ptr_f           <=  sram_wr_ptr_n;
    end
  end

  //Tap addresses
  assign  sram_rd_addr_od     = sram_rd_ptr_f[P_SRAM_ADDR_W-1:0];
  assign  sram_wr_addr_od     = sram_wr_ptr_f[P_SRAM_ADDR_W-1:0];

  //Calculate the gray values
  assign  sram_rd_ptr_gry_n   = sram_rd_ptr_n ^ {1'b0,sram_rd_ptr_n[P_SRAM_ADDR_W:1]};
  assign  sram_wr_ptr_gry_n   = sram_wr_ptr_n ^ {1'b0,sram_wr_ptr_n[P_SRAM_ADDR_W:1]};

  /*
    * Full/Empty logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sram_full_oh            <=  1'b0;
      sram_empty_oh           <=  1'b1;
      sram_aempty_oh          <=  1'b1;
    end
    else
    begin
      sram_empty_oh           <=  (sram_rd_ptr_gry_n == sram_wr_ptr_gry_n)  ? 1'b1  : 1'b0;

      sram_full_oh            <=  sram_wr_ptr_gry_n ==  {~sram_rd_ptr_gry_n[P_SRAM_ADDR_W:P_SRAM_ADDR_W-1],sram_rd_ptr_gry_n[P_SRAM_ADDR_W-2:0]};

      sram_aempty_oh          <=  (sram_wr_ptr_gry_n[P_SRAM_ADDR_W:P_SRAM_ADDR_W-1] ==  sram_rd_ptr_gry_n[P_SRAM_ADDR_W:P_SRAM_ADDR_W-1]) ? 1'b1  : 1'b0;
    end
  end



endmodule // sram_ff_cntrlr
