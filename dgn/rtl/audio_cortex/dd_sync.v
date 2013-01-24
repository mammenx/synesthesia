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
 -- Module Name       : dd_sync
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Basic 2xDFLOP synchronizer
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module dd_sync
  (
    clk_ir,
    rst_il,

    signal_id,

    signal_od
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_NO_SYNC_STAGES  = 2;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       signal_id;


//----------------------- Output Declarations -----------------------------
  output                      signal_od;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [P_NO_SYNC_STAGES-1:0]  sync_f;

//----------------------- Internal Wire Declarations ----------------------



//----------------------- Start of Code -----------------------------------

  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sync_f                  <=  {P_NO_SYNC_STAGES{1'b0}};
    end
    else
    begin
      sync_f                  <=  {sync_f[P_NO_SYNC_STAGES-2:0],signal_id};
    end
  end

  assign  signal_od           =   sync_f[P_NO_SYNC_STAGES-1];

endmodule // dd_sync
