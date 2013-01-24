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
 -- Module Name       : butterfly_wing
 -- Author            : mammenx
 -- Associated modules: complex_mult
 -- Function          : This block implements a simple FFT butterfly, which
                        accepts two input samples & twiddle factor.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module butterfly_wing
  (
    clk_ir,                   //Clock, rising edge
    rst_il,                   //Active low asynchronous reset

    //Inputs
    sample_a_real_id,         //Input sample A real part
    sample_a_im_id,           //Input sample A imaginary part

    sample_b_real_id,         //Input sample B real part
    sample_b_im_id,           //Input sample B imaginary part

    twdl_factor_real_id,      //Input twiddle factor real part
    twdl_factor_im_id,        //Input twiddle facotr imaginary part

    samples_rdy_ih,           //1->Samples are ready for computation


    //Outputs
    data_real_od,             //Output data real part
    data_im_od,               //Output data imaginary part
    data_rdy_oh               //1->Output data ready

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_IDATA_W         = 32; //32b multiplier input data width
  parameter P_ODATA_W         = 42; //42b multiplier output data width
  parameter P_TWDL_W          = 10; //10b twiddle width

  parameter P_MUL_LAT         = 4;  //Multiplier latency

  /*  not exposed outside */
  localparam  P_PST_W         = P_MUL_LAT + 1;
  localparam  P_DIV           = P_TWDL_W  - 2;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input   [P_IDATA_W-1:0]     sample_a_real_id;
  input   [P_IDATA_W-1:0]     sample_a_im_id;

  input   [P_IDATA_W-1:0]     sample_b_real_id;
  input   [P_IDATA_W-1:0]     sample_b_im_id;

  input   [P_TWDL_W-1:0]      twdl_factor_real_id;
  input   [P_TWDL_W-1:0]      twdl_factor_im_id;

  input                       samples_rdy_ih;

//----------------------- Output Declarations -----------------------------
  output  [P_IDATA_W-1:0]     data_real_od;
  output  [P_IDATA_W-1:0]     data_im_od;

  output                      data_rdy_oh;

//----------------------- Output Register Declaration ---------------------
  reg     [P_IDATA_W-1:0]     data_real_od;
  reg     [P_IDATA_W-1:0]     data_im_od;

  reg                         data_rdy_oh;

//----------------------- Internal Register Declarations ------------------
  reg     [P_PST_W-1:0]       pst_vec;

  reg     [P_IDATA_W:0]       mul_res_norm_im_f;
  reg     [P_IDATA_W:0]       mul_res_norm_real_f;
  reg     [P_IDATA_W:0]       mul_res_inv_im_f;
  reg     [P_IDATA_W:0]       mul_res_inv_real_f;

//----------------------- Internal Wire Declarations ----------------------
  wire    [P_ODATA_W-1:0]     mul_res_im_w;
  wire    [P_ODATA_W-1:0]     mul_res_real_w;

  wire    [P_ODATA_W-1:0]     mul_res_norm_im_w;
  wire    [P_ODATA_W-1:0]     mul_res_norm_real_w;

  wire    [P_IDATA_W:0]       mul_res_inv_im_c;
  wire    [P_IDATA_W:0]       mul_res_inv_real_c;

  wire    [P_IDATA_W+1:0]     data_0_real_c;
  wire    [P_IDATA_W+1:0]     data_0_im_c;
  wire    [P_IDATA_W+1:0]     data_1_real_c;
  wire    [P_IDATA_W+1:0]     data_1_im_c;


//----------------------- Start of Code -----------------------------------

  /*
    *               Butterfly Structure
    *                                                 +---+
    * sample_a  ------------------------------------->| + |--------------->
    *                                         \   /   +---+   data_0_out
    *                                          \ /
    *                                           X
    *                               +----------/ \
    *                              /              \
    *               +---+         /       +----+   \
    *               | m |        /        |    |    \ +---+   data_1_out
    * sample_b  --->| u |---------------->| -1 |----->| + |--------------->
    *               | l |                 |    |      +---+
    * twiddle   --->| t |                 +----+
    *               +---+
    *
  */

  /*
    * PST vector generation logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pst_vec                 <=  {P_PST_W{1'b0}};
    end
    else
    begin
      pst_vec[0]              <=  samples_rdy_ih;

      pst_vec[P_PST_W-1:1]    <=  pst_vec[P_PST_W-2:0]; //shift register
    end
  end

  //Normalize the multiplier output - division
  assign  mul_res_norm_im_w   =   {{P_DIV{mul_res_im_w[P_ODATA_W-1]}},    mul_res_im_w[P_ODATA_W-1:P_DIV]};
  assign  mul_res_norm_real_w =   {{P_DIV{mul_res_real_w[P_ODATA_W-1]}},  mul_res_real_w[P_ODATA_W-1:P_DIV]};

  //Calculating negative value of multiplier output - 2's compliment
  assign  mul_res_inv_im_c    =   ~mul_res_norm_im_w[P_IDATA_W:0]   + 1'b1;
  assign  mul_res_inv_real_c  =   ~mul_res_norm_real_w[P_IDATA_W:0] + 1'b1;

  /*
    * Intermediate Stage
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      mul_res_norm_im_f       <=  {P_IDATA_W+1{1'b0}};
      mul_res_norm_real_f     <=  {P_IDATA_W+1{1'b0}};
      mul_res_inv_im_f        <=  {P_IDATA_W+1{1'b0}};
      mul_res_inv_real_f      <=  {P_IDATA_W+1{1'b0}};
    end
    else
    begin
      mul_res_norm_im_f       <=  mul_res_norm_im_w[P_IDATA_W:0];
      mul_res_norm_real_f     <=  mul_res_norm_real_w[P_IDATA_W:0];
      mul_res_inv_im_f        <=  mul_res_inv_im_c;
      mul_res_inv_real_f      <=  mul_res_inv_real_c;
    end
  end

  //Final Stage sum
  //  assign  data_0_real_c       =   {{2{sample_a_real_id[P_IDATA_W-1]}},sample_a_real_id}  + {mul_res_norm_real_f[P_IDATA_W],mul_res_norm_real_f};
  //  assign  data_0_im_c         =   {{2{sample_a_im_id[P_IDATA_W-1]}},sample_a_im_id}      + {mul_res_norm_im_f[P_IDATA_W],mul_res_norm_im_f};
  //  assign  data_1_real_c       =   {{2{sample_a_real_id[P_IDATA_W-1]}},sample_a_real_id}  + {mul_res_inv_real_f[P_IDATA_W],mul_res_inv_real_f};
  //  assign  data_1_im_c         =   {{2{sample_a_im_id[P_IDATA_W-1]}},sample_a_im_id}      + {mul_res_inv_im_f[P_IDATA_W],mul_res_inv_im_f};
  assign  data_0_real_c       =   {{2{sample_a_real_id[P_IDATA_W-1]}},sample_a_real_id}  + {{2{mul_res_norm_real_f[P_IDATA_W]}},mul_res_norm_real_f[P_IDATA_W-1:0]};
  assign  data_0_im_c         =   {{2{sample_a_im_id[P_IDATA_W-1]}},sample_a_im_id}      + {{2{mul_res_norm_im_f[P_IDATA_W]}},mul_res_norm_im_f[P_IDATA_W-1:0]};
  assign  data_1_real_c       =   {{2{sample_a_real_id[P_IDATA_W-1]}},sample_a_real_id}  + {{2{mul_res_inv_real_f[P_IDATA_W]}},mul_res_inv_real_f[P_IDATA_W-1:0]};
  assign  data_1_im_c         =   {{2{sample_a_im_id[P_IDATA_W-1]}},sample_a_im_id}      + {{2{mul_res_inv_im_f[P_IDATA_W]}},mul_res_inv_im_f[P_IDATA_W-1:0]};


  /*
    * Output Data Muxing Logic
    * data_0 will come first followed data_1
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      data_real_od            <=  {P_IDATA_W{1'b0}};
      data_im_od              <=  {P_IDATA_W{1'b0}};
      data_rdy_oh             <=  1'b0;
    end
    else
    begin
    /*
      if(pst_vec[P_MUL_LAT-1])
      begin
        data_real_od          <=  data_0_real_c[P_IDATA_W+1:2];

        data_im_od            <=  data_0_im_c[P_IDATA_W+1:2];
      end
      else if(pst_vec[P_MUL_LAT])
      begin
        data_real_od          <=  data_1_real_c[P_IDATA_W+1:2];

        data_im_od            <=  data_1_im_c[P_IDATA_W+1:2];
      end

      data_rdy_oh             <=  |(pst_vec[P_MUL_LAT:P_MUL_LAT-1]);
    */

      if(pst_vec[P_MUL_LAT-1])
      begin
        data_real_od          <=  data_0_real_c[P_IDATA_W-1:0];

        data_im_od            <=  data_0_im_c[P_IDATA_W-1:0];
      end
      else if(pst_vec[P_MUL_LAT])
      begin
        data_real_od          <=  data_1_real_c[P_IDATA_W-1:0];

        data_im_od            <=  data_1_im_c[P_IDATA_W-1:0];
      end

      data_rdy_oh             <=  |(pst_vec[P_MUL_LAT:P_MUL_LAT-1]);
 
    end
  end

  /*
    * Instantiating Multiplier
  */
  complex_mult    complex_mult_inst
  (
	  .aclr         (~rst_il),  //active high port
	  .clock        (clk_ir),
	  .dataa_imag   (sample_b_im_id),
	  .dataa_real   (sample_b_real_id),
	  .datab_imag   (twdl_factor_im_id),
	  .datab_real   (twdl_factor_real_id),
	  .result_imag  (mul_res_im_w),
	  .result_real  (mul_res_real_w)
  );




endmodule // butterfly_wing
