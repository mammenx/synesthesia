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
 -- Module Name       : clk_mux
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : 
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module clk_mux
  (
    clk_vec_ir,               //Inpput clock vector
    rst_il,                   //Asynchronous active low reset

    clk_en_vec_id,            //One hot

    clk_or                    //Output clock
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_NO_CLOCKS       = 4;

//----------------------- Input Declarations ------------------------------
  input   [P_NO_CLOCKS-1:0]   clk_vec_ir;
  input                       rst_il;

  input   [P_NO_CLOCKS-1:0]   clk_en_vec_id;

//----------------------- Output Declarations -----------------------------
  output                      clk_or;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire    [P_NO_CLOCKS-1:0]   clk_en_vec_sync_w;
  wire    [P_NO_CLOCKS-1:0]   clk_gate_vec_c;
  wire    [P_NO_CLOCKS-1:0]   xeno_hot_chk_vec_c;


  genvar  i,j;

//----------------------- Start of Code -----------------------------------

  /*
  * Synchronize enable signals to respective clocks
  */
  generate
    for(i=0;  i<P_NO_CLOCKS;  i=i+1)
    begin : clk_sync_xeno
      dd_sync dd_sync_clk_inst(.clk_ir    (clk_vec_ir[i]),
                               .rst_il    (rst_il),
                               .signal_id (clk_en_vec_id[i]),
                               .signal_od (clk_en_vec_sync_w[i])
                             );

      //Check if any of the other signals are still high!
      if(i==0)
      begin
        assign  xeno_hot_chk_vec_c[i] = |(clk_en_vec_sync_w[P_NO_CLOCKS-1:i+1]);
      end
      else if(i==P_NO_CLOCKS-1)
      begin
        assign  xeno_hot_chk_vec_c[i] = |(clk_en_vec_sync_w[i-1:0]);
      end
      else
      begin
        assign  xeno_hot_chk_vec_c[i] = |({clk_en_vec_sync_w[P_NO_CLOCKS-1:i+1],  clk_en_vec_sync_w[i-1:0]});
      end
    end
  endgenerate

  //Gate the clocks with synced masks
  assign  clk_gate_vec_c      = clk_vec_ir  & clk_en_vec_sync_w & ~xeno_hot_chk_vec_c;

  assign  clk_or  = |(clk_gate_vec_c);

endmodule // clk_mux
