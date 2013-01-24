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
 -- Module Name       : complex_div
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module accepts a complex number and returns
                        the value of imaginary_part/real_part. Acts as a
                        wrapper file for lpm_divide function.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module complex_div
  (
    clk_ir,                   //Clock
    rst_il,                   //Asynchronous Active low reset

    //Inputs
    real_id,                //Real part of complex number
    im_id,                  //Imaginary part of complex number

    //Outputs
    res_q_od,               //Quotient of division
    res_r_od                //Remainder of division
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_DATA_W          = 32;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input   [P_DATA_W-1:0]      real_id;
  input   [P_DATA_W-1:0]      im_id;


//----------------------- Output Declarations -----------------------------
  output  [P_DATA_W-1:0]      res_q_od;
  output  [P_DATA_W-1:0]      res_r_od;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------


//----------------------- Start of Code -----------------------------------

  //Instantiating LPM_DIVIDE
  lpm_divide  lpm_divide_inst
  (
    .quotient       (res_q_od),
    .remain         (res_r_od),
    .numer          (im_id),
    .denom          (real_id),
    .clock          (clk_ir),
    .clken          (1'b1),
    .aclr           (~rst_il)
  );

	defparam  lpm_divide_inst.lpm_type = "lpm_divide";
	defparam  lpm_divide_inst.lpm_widthn = P_DATA_W;
	defparam  lpm_divide_inst.lpm_widthd = P_DATA_W;
	defparam  lpm_divide_inst.lpm_nrepresentation = "UNSIGNED";
	defparam  lpm_divide_inst.lpm_drepresentation = "UNSIGNED";
	//defparam  lpm_divide_inst.lpm_remainderpositive = "TRUE";
	defparam  lpm_divide_inst.lpm_pipeline = 1;
	//defparam  lpm_divide_inst.lpm_hint = "UNUSED";

endmodule // complex_div
