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
 -- Module Name       : vcortex_lb
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block decodes LB transactions meant for the
                        VCORTEX.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module vcortex_lb
  (
    clk_ir,                   //Clock input
    rst_il,                   //Active low reset

    //PWM RAM I/F
    pwm_ram_addr_od,          //Read address to PWM RAM
    pwm_ram_rd_data_id,       //Read data from PWM RAM
    pwm_ram_wr_data_od,       //Write data to PWM RAM
    pwm_ram_wr_en_oh,         //1->Write to PWM RAM

    //PWM GEN I/F
    pwm_gen_en_oh,            //1->Enable PWM

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

  parameter P_RD_DELAY        = 2;  //No of clocks delay for each read xtn

  `include  "vcortex_reg_map.v"



//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input   [P_LB_DATA_W-1:0]   pwm_ram_rd_data_id;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;


//----------------------- Output Declarations -----------------------------
  output  [P_RAM_ADDR_W-1:0]  pwm_ram_addr_od;
  output  [P_RAM_DATA_W-1:0]  pwm_ram_wr_data_od;
  output                      pwm_ram_wr_en_oh;

  output                      pwm_gen_en_oh;

  output                      lb_rd_valid_od;
  output                      lb_wr_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;

//----------------------- Output Register Declaration ---------------------
  reg                         pwm_gen_en_oh;

  reg                         lb_wr_valid_od;
  reg     [P_LB_DATA_W-1:0]   lb_rd_data_od;

//----------------------- Internal Register Declarations ------------------
  reg     [P_RD_DELAY:0]      rd_delay_vec;
  reg     [P_RD_DELAY-1:0]    reg_code_sel_del_f;
  reg     [P_RD_DELAY-1:0]    pwm_ram_sel_del_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                        reg_code_sel_c;
  wire                        pwm_ram_sel_c;

//----------------------- Start of Code -----------------------------------

  //Decode the block code from address
  assign  reg_code_sel_c      = (lb_addr_id[P_LB_ADDR_W-1:P_LB_ADDR_W-4]  ==  VCORTEX_REG_CODE)     ? 1'b1  : 1'b0;
  assign  pwm_ram_sel_c       = (lb_addr_id[P_LB_ADDR_W-1:P_LB_ADDR_W-4]  ==  VCORTEX_PWM_RAM_CODE) ? 1'b1  : 1'b0;

  assign  pwm_ram_addr_od     = lb_addr_id[P_RAM_ADDR_W-1:0];
  assign  pwm_ram_wr_data_od  = lb_wr_data_id;
  assign  pwm_ram_wr_en_oh    = pwm_ram_sel_c & lb_wr_en_ih;

  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pwm_gen_en_oh           <=  1'b0;
      lb_rd_data_od           <=  {P_LB_DATA_W{1'b0}};

      reg_code_sel_del_f      <=  {P_RD_DELAY{1'b0}};
      pwm_ram_sel_del_f       <=  {P_RD_DELAY{1'b0}};
    end
    else
    begin
      pwm_gen_en_oh           <=  (reg_code_sel_c & lb_wr_en_ih)  ? lb_wr_data_id[0]  : pwm_gen_en_oh;

      reg_code_sel_del_f      <=  {reg_code_sel_del_f[P_RD_DELAY-2:0],reg_code_sel_c};
      pwm_ram_sel_del_f       <=  {pwm_ram_sel_del_f[P_RD_DELAY-2:0],pwm_ram_sel_c};

      if(rd_delay_vec[P_RD_DELAY-1])
      begin
        case(1'b1)

          reg_code_sel_del_f[P_RD_DELAY-1]  : lb_rd_data_od <=  {{P_LB_DATA_W-1{1'b0}},pwm_gen_en_oh};

          pwm_ram_sel_del_f[P_RD_DELAY-1]   : lb_rd_data_od <=  pwm_ram_rd_data_id;

          default :         lb_rd_data_od <=  16'hdead;

        endcase
      end
      else
      begin
        lb_rd_data_od         <=  lb_rd_data_od;
      end
    end
  end

  assign  lb_rd_valid_od      =   rd_delay_vec[P_RD_DELAY];

  /*  Read delay vector logic */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb_wr_valid_od          <=  1'b0;
      rd_delay_vec            <=  {P_RD_DELAY+1{1'b0}};
    end
    else
    begin
      lb_wr_valid_od          <=  lb_wr_en_ih;

      rd_delay_vec            <=  {rd_delay_vec[P_RD_DELAY-1:0],lb_rd_en_ih}; //shift operation
    end
  end



endmodule // vcortex_lb
