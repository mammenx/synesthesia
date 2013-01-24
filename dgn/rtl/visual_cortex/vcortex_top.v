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
 -- Module Name       : vcortex_top
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Tope level wrapper for VCORTEX
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module vcortex_top
  (
    clk_ir,                   //Clock input
    rst_il,                   //Active low reset

    //PWM Output
    pwm_data_od,              //PWM Channel data

    //Local bus interface
    lb_rd_en_ih,              //1->Read enable
    lb_wr_en_ih,              //1->Write enable
    lb_addr_id,               //Address input
    lb_wr_data_id,            //Write Data input
    lb_rd_valid_od,           //1->lb_rd_data_od is valid
    lb_wr_valid_od,           //1->Write is valid
    lb_rd_data_od             //Read Data output


  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_LB_ADDR_W       = 12;
  parameter P_LB_DATA_W       = P_16B_W;
  //parameter P_LB_DATA_W       = P_32B_W;

  parameter P_RAM_ADDR_W      = 4;
  parameter P_RAM_DATA_W      = P_16B_W;
  //parameter P_RAM_DATA_W      = P_32B_W;

  parameter P_NO_CHANNELS     = 16;
  parameter P_PWM_RESOLUTION  = 16; //16b resolution
  //parameter P_PWM_RESOLUTION  = 32; //32b resolution
  parameter P_ON_VEC_W        = P_NO_CHANNELS * P_PWM_RESOLUTION;


//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;



//----------------------- Output Declarations -----------------------------
  output  [P_NO_CHANNELS-1:0] pwm_data_od;

  output                      lb_rd_valid_od;
  output                      lb_wr_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire    [P_RAM_ADDR_W-1:0]  pwm_ram_addr_w;
  wire    [P_RAM_DATA_W-1:0]  pwm_ram_wr_data_w;
  wire                        pwm_ram_wr_en_w;
  wire    [P_RAM_DATA_W-1:0]  pwm_ram_rd_data_w;

  wire    [P_RAM_ADDR_W-1:0]  pwm_ram_addr_1_w;
  wire    [P_RAM_DATA_W-1:0]  pwm_ram_rd_data_1_w;

  wire                        pwm_refresh_w;
  wire    [P_ON_VEC_W-1:0]    pwm_on_vec_w;

  wire                        pwm_gen_en_w;


//----------------------- Start of Code -----------------------------------

  vcortex_lb        vcortex_lb_inst
  (
    .clk_ir               (clk_ir),
    .rst_il               (rst_il),

    .pwm_ram_addr_od      (pwm_ram_addr_w),
    .pwm_ram_rd_data_id   (pwm_ram_rd_data_w),
    .pwm_ram_wr_data_od   (pwm_ram_wr_data_w),
    .pwm_ram_wr_en_oh     (pwm_ram_wr_en_w),

    .pwm_gen_en_oh        (pwm_gen_en_w),

    .lb_rd_en_ih          (lb_rd_en_ih),
    .lb_wr_en_ih          (lb_wr_en_ih),
    .lb_addr_id           (lb_addr_id),
    .lb_wr_data_id        (lb_wr_data_id),
    .lb_rd_valid_od       (lb_rd_valid_od),
    .lb_wr_valid_od       (lb_wr_valid_od),
    .lb_rd_data_od        (lb_rd_data_od)

  );

/*
  pwm_ram       pwm_ram_inst
  (
    .aclr         (~rst_il),
    .clock        (clk_ir),
    .data         (pwm_ram_wr_data_w),
    .rdaddress_a  (pwm_ram_addr_w),
    .rdaddress_b  (pwm_ram_addr_1_w),
    .wraddress    (pwm_ram_addr_w),
    .wren         (pwm_ram_wr_en_w),
    .qa           (pwm_ram_rd_data_w),
    .qb           (pwm_ram_rd_data_1_w)
  );
*/

  pwm_ram         pwm_ram_inst
  (
	  .address_a    (pwm_ram_addr_w),
	  .address_b    (pwm_ram_addr_1_w),
	  .clock        (clk_ir),
	  .data_a       (pwm_ram_wr_data_w),
	  .data_b       (32'd0),
	  .wren_a       (pwm_ram_wr_en_w),
	  .wren_b       (1'b0),
	  .q_a          (pwm_ram_rd_data_w),
	  .q_b          (pwm_ram_rd_data_1_w)
  );


  pwm_refresh     pwm_refresh_inst
  (
    .clk_ir             (clk_ir),
    .rst_il             (rst_il),

    .pwm_ram_rd_addr_od (pwm_ram_addr_1_w),
    .pwm_ram_rd_data_id (pwm_ram_rd_data_1_w),

    .pwm_refresh_ih     (pwm_refresh_w),
    .pwm_on_vec_od      (pwm_on_vec_w)

  );


  pwm_gen           pwm_gen_inst
  (
    .clk_ir          (clk_ir),
    .rst_il          (rst_il),

    .pwm_en_ih       (pwm_gen_en_w),
    .pwm_on_vec_id   (pwm_on_vec_w),

    .pwm_refresh_oh  (pwm_refresh_w),
    .pwm_data_od     (pwm_data_od)

  );



endmodule // vcortex_top
