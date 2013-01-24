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
 -- Module Name       : sram_lb
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block maintains SRAM registers & decodes LB
                        transactions.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module sram_lb
  (
    clk_ir,                   //Acortex System Clock
    rst_il,                   //Active Low Reset

    //Local Bus interface
    lb_rd_en_ih,              //1->Read enable
    lb_wr_en_ih,              //1->Write enable
    lb_addr_id,               //Address input
    lb_wr_data_id,            //Write Data input
    lb_rd_valid_od,           //1->lb_rd_data_od is valid
    lb_rd_data_od,            //Read Data output
    lb_wr_valid_od,           //1->Write transaction has gone through

    //SRAM Interface
    sram_ff_rd_en_ih,         //SRAM FIFO Read enable
    sram_ff_wr_en_ih,         //SRAM FIFO Write enable
    sram_ff_full_ih,          //SRAM FIFO Full status
    sram_ff_empty_ih,         //SRAM FIFO Empty status
    sram_ff_aempty_ih,        //SRAM FIFO Almost Empty status
    sram_mm_rd_en_oh,         //1->Read enable
    sram_mm_wr_en_oh,         //1->Write enable
    sram_mm_addr_od,          //Address input
    sram_mm_wr_data_od,       //Write Data input
    sram_mm_rd_valid_id,      //1->lb_rd_data_od is valid
    sram_mm_rd_data_id,       //Read Data output
    sram_arb_mm_grant_ih      //1->Access granted to MM by arbiter


 
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_LB_ADDR_W       = P_8B_W;
  parameter P_LB_DATA_W       = P_16B_W;

  parameter P_SRAM_ADDR_W     = 18;

  `include  "acortex_reg_map.v"



//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;

  input                       sram_ff_rd_en_ih;
  input                       sram_ff_wr_en_ih;
  input                       sram_ff_full_ih;
  input                       sram_ff_empty_ih;
  input                       sram_ff_aempty_ih;

  input                       sram_mm_rd_valid_id;
  input   [P_LB_DATA_W-1:0]   sram_mm_rd_data_id;
  input                       sram_arb_mm_grant_ih;

//----------------------- Output Declarations -----------------------------
  output                      lb_rd_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;
  output                      lb_wr_valid_od;

  output                      sram_mm_rd_en_oh;
  output                      sram_mm_wr_en_oh;
  output  [P_SRAM_ADDR_W-1:0] sram_mm_addr_od;
  output  [P_LB_DATA_W-1:0]   sram_mm_wr_data_od;

//----------------------- Output Register Declaration ---------------------
  reg                        lb_rd_valid_od;
  reg    [P_LB_DATA_W-1:0]   lb_rd_data_od;
  reg                        lb_wr_valid_od;

  reg                        sram_mm_rd_en_oh;
  reg                        sram_mm_wr_en_oh;
  reg    [P_SRAM_ADDR_W-1:0] sram_mm_addr_od;
 
//----------------------- Internal Register Declarations ------------------
  reg                         sram_ff_oflw_flag_f;
  reg                         sram_ff_urun_flag_f;

  reg   [P_LB_DATA_W-1:0]     sram_data_f;
  reg                         sram_mm_rd_valid_1d;

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Start of Code -----------------------------------

  /*
    * Checking for SRAM FIFO Overrun/Underrun conditions
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sram_ff_oflw_flag_f     <=  1'b0;
      sram_ff_urun_flag_f     <=  1'b0;
    end
    else
    begin
      sram_ff_oflw_flag_f     <=  sram_ff_oflw_flag_f | (sram_ff_wr_en_ih & sram_ff_full_ih);

      sram_ff_urun_flag_f     <=  sram_ff_urun_flag_f | (sram_ff_rd_en_ih & sram_ff_empty_ih);
    end
  end

  /*
    * Read logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb_wr_valid_od          <=  1'b0;
      lb_rd_valid_od          <=  1'b0;
      lb_rd_data_od           <=  {P_LB_DATA_W{1'b0}};

      sram_mm_rd_valid_1d     <=  1'b0;
    end
    else
    begin
      sram_mm_rd_valid_1d     <=  sram_mm_rd_valid_id;  //give time for sram_data_f to update

      if(lb_addr_id ==  SRAM_ACC_CTRL_REG_ADDR) //wait until arbitration is granted
      begin
        lb_wr_valid_od        <=  (sram_mm_wr_en_oh & sram_arb_mm_grant_ih) | sram_mm_rd_valid_1d;
      end
      else
      begin
        lb_wr_valid_od        <=  lb_wr_en_ih;
      end

      lb_rd_valid_od          <=  lb_rd_en_ih;

      case(lb_addr_id)

        SRAM_STATUS_REG_ADDR    : lb_rd_data_od <=  {11'd0, sram_ff_oflw_flag_f,  sram_ff_urun_flag_f, sram_ff_full_ih, sram_ff_aempty_ih, sram_ff_empty_ih};

        SRAM_ACC_CTRL_REG_ADDR  : lb_rd_data_od <=  {14'd0, sram_mm_wr_en_oh, sram_mm_rd_en_oh};

        SRAM_ACC_ADDR_H_REG_ADDR: lb_rd_data_od <=  {14'd0, sram_mm_addr_od[P_SRAM_ADDR_W-1:P_SRAM_ADDR_W-2]};

        SRAM_ACC_ADDR_L_REG_ADDR: lb_rd_data_od <=  sram_mm_addr_od[P_SRAM_ADDR_W-3:0];

        SRAM_ACC_DATA_REG_ADDR  : lb_rd_data_od <=  sram_data_f;

      endcase

    end
  end

  /*
    * Arbiter interfacing logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sram_mm_rd_en_oh        <=  1'b0;
      sram_mm_wr_en_oh        <=  1'b0;
      sram_mm_addr_od         <=  {P_SRAM_ADDR_W{1'b0}};

      sram_data_f             <=  {P_LB_DATA_W{1'b0}};
    end
    else
    begin
      if(sram_mm_rd_en_oh)
      begin
        sram_mm_rd_en_oh      <=  ~sram_mm_rd_valid_id;
      end
      else
      begin
        sram_mm_rd_en_oh      <=  (lb_addr_id ==  SRAM_ACC_CTRL_REG_ADDR) ? lb_wr_en_ih & lb_wr_data_id[0]  :
                                                                            sram_mm_rd_en_oh;
      end

      if(sram_mm_wr_en_oh)
      begin
        sram_mm_wr_en_oh      <=  ~sram_arb_mm_grant_ih;
      end
      else
      begin
        sram_mm_wr_en_oh      <=  (lb_addr_id ==  SRAM_ACC_CTRL_REG_ADDR) ? lb_wr_en_ih & lb_wr_data_id[1]  :
                                                                            sram_mm_wr_en_oh;
      end

      if(lb_wr_en_ih)
      begin
        sram_mm_addr_od[P_SRAM_ADDR_W-3:0]  <=  (lb_addr_id ==  SRAM_ACC_ADDR_L_REG_ADDR) ? lb_wr_data_id :
                                                                                            sram_mm_addr_od[P_SRAM_ADDR_W-3:0];

        sram_mm_addr_od[P_SRAM_ADDR_W-1:P_SRAM_ADDR_W-2]  <=  (lb_addr_id ==  SRAM_ACC_ADDR_H_REG_ADDR) ? lb_wr_data_id[1:0]  :
                                                                                                          sram_mm_addr_od[P_SRAM_ADDR_W-1:P_SRAM_ADDR_W-2];
      end

      if(lb_wr_en_ih  & (lb_addr_id ==  SRAM_ACC_DATA_REG_ADDR))
      begin
        sram_data_f           <=  lb_wr_data_id;
      end
      else if(sram_mm_rd_valid_id)
      begin
        sram_data_f           <=  sram_mm_rd_data_id;
      end
      else
      begin
        sram_data_f           <=  sram_data_f;
      end
    end
  end

  assign  sram_mm_wr_data_od  = sram_data_f;

endmodule // sram_lb
