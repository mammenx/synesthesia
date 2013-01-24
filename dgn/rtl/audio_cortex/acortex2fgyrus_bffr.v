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
 -- Project Code      : syneshtesia
 -- Module Name       : acortex2fgyrus_bffr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block takes care of managing pcm data buffers
                        for FFT processing. It also notifies fgyrus each
                        tim a complete buffer is filled.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module acortex2fgyrus_bffr
  (
    acortex_clk_ir,           //Acortex clock input
    acortex_rst_il,           //Associated Acortex reset
    fgyrus_clk_ir,            //Fgyrus clock input
    fgyrus_rst_il,            //Associated Fgyrus reset

    //Acortex Interface
    acortex_pcm_wr_en_ih,     //1->Write PCM data to buffer
    acortex_pcm_data_id,      //PCM data from Acortex

    //Fgyrus Interface
    fgyrus_pcm_rdy_oh,        //1->PCM samples ready for FFT
    fgyrus_pcm_rd_addr_id,    //Read address to PCM buffer
    fgyrus_pcm_data_od        //PCM data to Fgyrus

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_RAM_ADDR_W      = 7;


//----------------------- Input Declarations ------------------------------
  input                       acortex_clk_ir;
  input                       acortex_rst_il;
  input                       fgyrus_clk_ir;
  input                       fgyrus_rst_il;

  input                       acortex_pcm_wr_en_ih;
  input   [P_32B_W-1:0]       acortex_pcm_data_id;

  input   [P_RAM_ADDR_W-1:0]  fgyrus_pcm_rd_addr_id;


//----------------------- Output Declarations -----------------------------
  output                      fgyrus_pcm_rdy_oh;
  output  [P_32B_W-1:0]       fgyrus_pcm_data_od;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [P_RAM_ADDR_W:0]      ram_wptr_f;
  reg                         bffr_sel_1d;


//----------------------- Internal Wire Declarations ----------------------
  wire  [P_32B_W-1:0]         pcm_bffr_0_rd_data;
  wire  [P_32B_W-1:0]         pcm_bffr_1_rd_data;

//----------------------- Start of Code -----------------------------------

  /*
    * Write pointer logic
  */
  always@(posedge acortex_clk_ir, negedge acortex_rst_il)
  begin
    if(~acortex_rst_il)
    begin
      ram_wptr_f              <=  {P_RAM_ADDR_W+1{1'b0}};
      bffr_sel_1d             <=  1'b0;
    end
    else
    begin
      ram_wptr_f              <=  ram_wptr_f  + acortex_pcm_wr_en_ih;
      bffr_sel_1d             <=  ram_wptr_f[P_RAM_ADDR_W];
    end
  end

  /*
    * Instantiating dual PCM buffers
  */
  pcm_sample_ram    pcm_ram_0
  (
    .data           (acortex_pcm_data_id),
    .rdaddress      (fgyrus_pcm_rd_addr_id),
    .rdclock        (fgyrus_clk_ir),
    .wraddress      (ram_wptr_f[P_RAM_ADDR_W-1:0]),
    .wrclock        (acortex_clk_ir),
    .wren           (acortex_pcm_wr_en_ih & ~ram_wptr_f[P_RAM_ADDR_W]),
    .q              (pcm_bffr_0_rd_data)
  );

  pcm_sample_ram    pcm_ram_1
  (
    .data           (acortex_pcm_data_id),
    .rdaddress      (fgyrus_pcm_rd_addr_id),
    .rdclock        (fgyrus_clk_ir),
    .wraddress      (ram_wptr_f[P_RAM_ADDR_W-1:0]),
    .wrclock        (acortex_clk_ir),
    .wren           (acortex_pcm_wr_en_ih & ram_wptr_f[P_RAM_ADDR_W]),
    .q              (pcm_bffr_1_rd_data)
  );

  //Muxing read data output
  assign  fgyrus_pcm_data_od  = ram_wptr_f[P_RAM_ADDR_W]  ? pcm_bffr_0_rd_data  : pcm_bffr_1_rd_data;


  /*
    * Instantiating pulse synchronizer
  */
  pulse_sync_tggl   psync_inst
  (
    .clk_a_ir       (acortex_clk_ir),
    .rst_a_il       (acortex_rst_il),
    //.pulse_a_ih     (ram_wptr_f[P_RAM_ADDR_W] ^ bffr_sel_1d), //any edge
    .pulse_a_ih     (&(ram_wptr_f[P_RAM_ADDR_W-1:0]) &  acortex_pcm_wr_en_ih), //when the 128th sample is written

    .clk_b_ir       (fgyrus_clk_ir),
    .rst_b_il       (fgyrus_rst_il),
    .pulse_b_oh     (fgyrus_pcm_rdy_oh)
  );

  defparam  psync_inst.P_NO_OF_PULSES = 1;



endmodule // acortex2fgyrus_bffr
