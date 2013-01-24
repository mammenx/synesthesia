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
 -- Module Name       : pwm_gen
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module generates PWM signals for each LED
                        channel.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pwm_gen
  (
    clk_ir,                   //Clock input
    rst_il,                   //Active low reset

    //Inputs
    pwm_en_ih,                //1->PWM logic is enabled
                              //0->PWM logic is disabled, counters reset
    pwm_on_vec_id,            //Vector, with no of clocks for on time for all channels

    //Outputs
    pwm_refresh_oh,           //1->Refresh PWM samples
    pwm_data_od               //PWM Channel data

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_NO_CHANNELS     = 16;
  parameter P_PWM_RESOLUTION  = 16; //16b resolution
  //parameter P_PWM_RESOLUTION  = 32; //32b resolution

  parameter P_LED_ON_VAL      = 1'b1; //Active high/low LEDs ...
  parameter P_LED_OFF_VAL     = ~P_LED_ON_VAL; //Active high/low LEDs ...

  parameter P_ON_VEC_W        = P_NO_CHANNELS * P_PWM_RESOLUTION;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       pwm_en_ih;
  input   [P_ON_VEC_W-1:0]    pwm_on_vec_id;


//----------------------- Output Declarations -----------------------------
  output                      pwm_refresh_oh;
  output  [P_NO_CHANNELS-1:0] pwm_data_od;


//----------------------- Output Register Declaration ---------------------
  reg                         pwm_refresh_oh;
  reg     [P_NO_CHANNELS-1:0] pwm_data_od;


//----------------------- Internal Register Declarations ------------------
  genvar  i;

  reg     [P_PWM_RESOLUTION-1:0]  pwm_cntr_f;

//----------------------- Internal Wire Declarations ----------------------
  wire    [P_NO_CHANNELS-1:0] pwm_data_n;

//----------------------- Start of Code -----------------------------------


  /*
    * PWM Counter Logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pwm_cntr_f              <=  {P_PWM_RESOLUTION{1'b0}};
    end
    else
    begin
      if(pwm_en_ih)
      begin
        pwm_cntr_f            <=  pwm_cntr_f  + 1'b1;
      end
      else  //PWM disabled
      begin
        pwm_cntr_f            <=  {P_PWM_RESOLUTION{1'b0}};
      end
    end
  end

  /*
    * Generating PWM values based on comparism with pwm counter
  */
  generate
    for(i=0;  i<P_NO_CHANNELS;  i=i+1)
    begin : pwm_compare
      assign  pwm_data_n[i]   = (pwm_on_vec_id[(i*P_PWM_RESOLUTION) +:  P_PWM_RESOLUTION] >= pwm_cntr_f) ? P_LED_ON_VAL  : P_LED_OFF_VAL;
    end
  endgenerate

  /*
    * Outputs
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pwm_refresh_oh          <=  1'b0;
      pwm_data_od             <=  {P_NO_CHANNELS{P_LED_OFF_VAL}};
    end
    else
    begin
      pwm_data_od             <=  pwm_data_n;

      pwm_refresh_oh          <=  (pwm_cntr_f ==  {P_PWM_RESOLUTION{1'b1}}) ? 1'b1  : 1'b0;
    end
  end

endmodule // pwm_gen
