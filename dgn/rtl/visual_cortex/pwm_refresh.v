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
 -- Module Name       : pwm_refresh
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module reads from the PWM RAM and updates
                        OWM on values, based on the refresh trigger.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pwm_refresh
  (
    clk_ir,                   //Clock input
    rst_il,                   //Active low reset

    //PWM Ram I/F
    pwm_ram_rd_addr_od,       //Read address to PWM RAM
    pwm_ram_rd_data_id,       //Read data from PWM RAM

    //PWM Gen I/F
    pwm_refresh_ih,           //1->Start read out of PWM ram
    pwm_on_vec_od             //Vector with PWM on times

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_NO_CHANNELS     = 16;
  parameter P_PWM_RESOLUTION  = 16; //16b resolution
  //parameter P_PWM_RESOLUTION  = 32; //16b resolution
  localparam  P_PWM_RES_LOG   = $clog2(P_PWM_RESOLUTION);

  parameter P_ON_VEC_W        = P_NO_CHANNELS * P_PWM_RESOLUTION;

  parameter P_RAM_ADDR_W      = $clog2(P_NO_CHANNELS);
  parameter P_RAM_DATA_W      = P_16B_W;
  //parameter P_RAM_DATA_W      = P_32B_W;
  parameter P_RAM_RD_DELAY    = 2'd2;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input   [P_RAM_DATA_W-1:0]  pwm_ram_rd_data_id;

  input                       pwm_refresh_ih;

//----------------------- Output Declarations -----------------------------
  output  [P_RAM_ADDR_W-1:0]  pwm_ram_rd_addr_od;

  output  [P_ON_VEC_W-1:0]    pwm_on_vec_od;

//----------------------- Output Register Declaration ---------------------
  reg     [P_RAM_ADDR_W-1:0]  pwm_ram_rd_addr_od;

  reg     [P_ON_VEC_W-1:0]    pwm_on_vec_od;


//----------------------- Internal Register Declarations ------------------
  reg                         addr_cntr_en_f;
  reg     [P_RAM_RD_DELAY-1:0]  ram_rd_delay_f;

  reg     [P_RAM_ADDR_W-1:0]  pwm_line_no_f;

//----------------------- Internal Wire Declarations ----------------------

//----------------------- Start of Code -----------------------------------

  /*
    * RAM address counter logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      addr_cntr_en_f          <=  1'b0;
      pwm_ram_rd_addr_od      <=  {P_RAM_ADDR_W{1'b0}};
      ram_rd_delay_f          <=  {P_RAM_RD_DELAY{1'b0}};


      pwm_line_no_f           <=  {P_RAM_ADDR_W{1'b0}};
    end
    else
    begin
      addr_cntr_en_f          <=  addr_cntr_en_f  ? (pwm_ram_rd_addr_od !=  {P_RAM_ADDR_W{1'b1}}) : pwm_refresh_ih;

      ram_rd_delay_f          <=  {ram_rd_delay_f[P_RAM_RD_DELAY-2:0],  addr_cntr_en_f};

      if(addr_cntr_en_f)
      begin
        pwm_ram_rd_addr_od    <=  pwm_ram_rd_addr_od  + 1'b1;
      end
      else
      begin
        pwm_ram_rd_addr_od    <=  {P_RAM_ADDR_W{1'b0}};
      end

      pwm_line_no_f           <=  pwm_refresh_ih  ? {P_RAM_ADDR_W{1'b0}}  : pwm_line_no_f + ram_rd_delay_f[P_RAM_RD_DELAY-1];
    end
  end


  /*
    * On vector formatting logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pwm_on_vec_od           <=  {P_ON_VEC_W{1'b0}};
    end
    else
    begin
      if(ram_rd_delay_f[P_RAM_RD_DELAY-1])
      begin
        pwm_on_vec_od[{pwm_line_no_f,{P_PWM_RES_LOG{1'b0}}}  +:  P_PWM_RESOLUTION] <=  pwm_ram_rd_data_id;
      end
      else
      begin
        pwm_on_vec_od         <=  pwm_on_vec_od;
      end
    end
  end

endmodule // pwm_refresh
                                                                            
