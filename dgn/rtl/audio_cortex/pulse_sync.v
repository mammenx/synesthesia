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
 -- Module Name       : pulse_sync
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Used for synchronizing single pulses across clock
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


module pulse_sync
  (
    clk_a_ir,                 //Input Clock A
    rst_a_il,                 //Input Active low reset for clk_a_ir
    pulse_a_ih,               //Active high pulse in clock A

    clk_b_ir,                 //Input Clock B
    rst_b_il,                 //Input Active low reset for clk_b_ir
    pulse_b_oh                //Active high pulse in clock B - Synchronized
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_NO_OF_PULSES    = 2;
  parameter P_NO_OF_DELAYS    = 3;  //min 3!

//----------------------- Input Declarations ------------------------------
  input                       clk_a_ir;
  input                       rst_a_il;
  input   [P_NO_OF_PULSES-1:0]pulse_a_ih;

  input                       clk_b_ir;
  input                       rst_b_il;

//----------------------- Output Declarations -----------------------------
  output  [P_NO_OF_PULSES-1:0]pulse_b_oh;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg     [(P_NO_OF_PULSES*2)-1:0]dd_sync_a2b_f;
  reg     [(P_NO_OF_PULSES*2)-1:0]dd_sync_b2a_f;

  reg     [P_NO_OF_PULSES-1:0]sample_hold_f;

  reg     [(P_NO_OF_PULSES*P_NO_OF_DELAYS)-1:0]  pulse_filter_f;

//----------------------- Internal Wire Declarations ----------------------
  genvar  i;

//----------------------- Start of Code -----------------------------------

  /*
    * Clock Domain  - A
  */
  generate
    for(i=0;i<P_NO_OF_PULSES;i=i+1)
    begin : clk_domain_a

      always@(posedge clk_a_ir, rst_a_il)
      begin
        if(~rst_a_il)
        begin
          sample_hold_f[i]              <=  1'b0;
          dd_sync_b2a_f[(i*2)+1:(i*2)]  <=  2'b00;
        end
        else
        begin
          if(sample_hold_f[i])
          begin
            sample_hold_f[i]            <=  ~dd_sync_b2a_f[(i*2)+1]; //wait for ack from Clock Domain B
          end
          else
          begin
            sample_hold_f[i]            <=  pulse_a_ih[i]; //sample pulse A
          end

          dd_sync_b2a_f[(i*2)+1:(i*2)]  <=  {dd_sync_b2a_f[(i*2)],dd_sync_a2b_f[(i*2)+1]};
        end
      end

    end
  endgenerate


  /*
    * Clock Domain  - B
  */
  generate
    for(i=0;i<P_NO_OF_PULSES;i=i+1)
    begin : clk_domain_b

      always@(posedge clk_b_ir, rst_b_il)
      begin
        if(~rst_b_il)
        begin
          dd_sync_a2b_f[(i*2)+1:(i*2)]  <=  2'b00;
          pulse_filter_f[((i+1)*P_NO_OF_DELAYS)-1:(i*P_NO_OF_DELAYS)] <=  {P_NO_OF_DELAYS{1'b0}};
        end
        else
        begin
          dd_sync_a2b_f[(i*2)+1:(i*2)]        <=  {dd_sync_a2b_f[(i*2)],sample_hold_f[i]};

          //Detect rising edge of synchronized signal
          pulse_filter_f[(i*P_NO_OF_DELAYS)]  <=  dd_sync_a2b_f[(i*2)+1];
          pulse_filter_f[(i*P_NO_OF_DELAYS)+1]<=  ~pulse_filter_f[(i*P_NO_OF_DELAYS)] & dd_sync_a2b_f[(i*2)+1];

          //Apply delay
          pulse_filter_f[((i+1)*P_NO_OF_DELAYS)-1:(i*P_NO_OF_DELAYS)+2] <=  pulse_filter_f[((i+1)*P_NO_OF_DELAYS)-2:(i*P_NO_OF_DELAYS)+1];
        end
      end

    end
  endgenerate

  //Final Output
  generate
    for(i=0;i<P_NO_OF_PULSES;i=i+1)
    begin : final_output

      assign  pulse_b_oh[i]   = pulse_filter_f[((i+1)*P_NO_OF_DELAYS)-1];

    end
  endgenerate

endmodule // pulse_sync
