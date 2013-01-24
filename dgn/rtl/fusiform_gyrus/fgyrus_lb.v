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
 -- Module Name       : fgyrus_lb
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Decodes local bus transactions to correct fgyrus
                        blocks.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module fgyrus_lb
  (
    clk_ir,                   //Clock
    rst_il,                   //Asynchronous active low reset

    //Control status signals
    fgyrus_en_oh,             //1->Enable FGYRUS block
    fgyrus_busy_ih,           //1->FGYRUS FSM is busy
    fgyrus_fsm_pstate_id,     //Present state of FGYRUS FSM
    fgyrus_fft_done_ih,       //1->All FFT stages over
    fgyrus_post_norm_od,      //Post FFT Normalize mode

    //RAMs interface
    lb2ram_addr_od,           //Address output to RAM {FFT,CORDIC,TWIDDLE etc..}
    lb2fft_real_ram_wr_en_oh, //1->Write data to FFT REAL RAM
    lb2fft_im_ram_wr_en_oh,   //1->Write data to FFT IM RAM
    lb2twiddle_ram_wr_en_oh,  //1->Write data to TWIDDLE RAM
    lb2cordic_ram_wr_en_oh,   //1->Write data to CORDIC RAM
    lb2fft_real_ram_rd_en_oh, //1->Read data to FFT REAL RAM
    lb2fft_im_ram_rd_en_oh,   //1->Read data to FFT IM RAM
    lb2twiddle_ram_rd_en_oh,  //1->Read data to TWIDDLE RAM
    lb2cordic_ram_rd_en_oh,   //1->Read data to CORDIC RAM
    lb2ram_wr_data_od,        //Write data to RAM
    fft_real_ram_rd_data_id,  //Read data from FFT REAL RAM
    fft_im_ram_rd_data_id,    //Read data from FFT IM RAM
    twiddle_ram_rd_real_data_id,  //Read real data from TWIDDLE RAM
    twiddle_ram_rd_im_data_id,    //Read im data from TWIDDLE RAM
    cordic_ram_rd_data_id,    //Read data from CORDIC RAM

    //NIOS Interrupt
    irq_rst_ih,               //1->Clear interrupt
    irq_oh,                   //1->Interrupt NIOS processor

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
  parameter P_LB_DATA_W       = P_32B_W;

  parameter P_RD_DELAY        = 4;  //No of clocks delay for each read xtn

  `include  "fgyrus_reg_map.v"

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       fgyrus_busy_ih;
  input   [2:0]               fgyrus_fsm_pstate_id;
  input                       fgyrus_fft_done_ih;

  input   [P_32B_W-1:0]       fft_real_ram_rd_data_id;
  input   [P_32B_W-1:0]       fft_im_ram_rd_data_id;
  input   [P_16B_W-1:0]       twiddle_ram_rd_real_data_id;
  input   [P_16B_W-1:0]       twiddle_ram_rd_im_data_id;
  input   [P_16B_W-1:0]       cordic_ram_rd_data_id;

  input                       irq_rst_ih;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;

//----------------------- Output Declarations -----------------------------
  output                      fgyrus_en_oh;
  output  [3:0]               fgyrus_post_norm_od;

  output  [7:0]               lb2ram_addr_od;
  output                      lb2fft_real_ram_wr_en_oh;
  output                      lb2fft_im_ram_wr_en_oh;
  output                      lb2twiddle_ram_wr_en_oh;
  output                      lb2cordic_ram_wr_en_oh;
  output                      lb2fft_real_ram_rd_en_oh;
  output                      lb2fft_im_ram_rd_en_oh;
  output                      lb2twiddle_ram_rd_en_oh;
  output                      lb2cordic_ram_rd_en_oh;
  output  [P_32B_W-1:0]       lb2ram_wr_data_od;

  output                      irq_oh;

  output                      lb_rd_valid_od;
  output                      lb_wr_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;

//----------------------- Output Register Declaration ---------------------
  reg                         fgyrus_en_oh;
  reg     [3:0]               fgyrus_post_norm_od;

  reg     [7:0]               lb2ram_addr_od;
  reg                         lb2fft_real_ram_wr_en_oh;
  reg                         lb2fft_im_ram_wr_en_oh;
  reg                         lb2twiddle_ram_wr_en_oh;
  reg                         lb2cordic_ram_wr_en_oh;
  reg                         lb2fft_real_ram_rd_en_oh;
  reg                         lb2fft_im_ram_rd_en_oh;
  reg                         lb2twiddle_ram_rd_en_oh;
  reg                         lb2cordic_ram_rd_en_oh;
  reg     [P_32B_W-1:0]       lb2ram_wr_data_od;

  reg                         irq_oh;

  reg                         lb_wr_valid_od;
  reg     [P_LB_DATA_W-1:0]   lb_rd_data_od;

//----------------------- Internal Register Declarations ------------------
  reg     [P_RD_DELAY-1:0]    rd_delay_vec;
  reg     [P_8B_W-1:0]        reg_data_f;


//----------------------- Internal Wire Declarations ----------------------
  wire                        reg_code_sel_c;
  wire                        fft_real_ram_code_sel_c;
  wire                        fft_im_ram_code_sel_c;
  wire                        twiddle_ram_code_sel_c;
  wire                        cordic_ram_code_sel_c;

//----------------------- Start of Code -----------------------------------

  //Decode the block code from address
  assign  reg_code_sel_c          = (lb_addr_id[P_LB_ADDR_W-1:P_LB_ADDR_W-4]  ==  FGYRUS_REG_CODE)          ? 1'b1  : 1'b0;
  assign  fft_real_ram_code_sel_c = (lb_addr_id[P_LB_ADDR_W-1:P_LB_ADDR_W-4]  ==  FGYRUS_FFT_REAL_RAM_CODE) ? 1'b1  : 1'b0;
  assign  fft_im_ram_code_sel_c   = (lb_addr_id[P_LB_ADDR_W-1:P_LB_ADDR_W-4]  ==  FGYRUS_FFT_IM_RAM_CODE)   ? 1'b1  : 1'b0;
  assign  twiddle_ram_code_sel_c  = (lb_addr_id[P_LB_ADDR_W-1:P_LB_ADDR_W-4]  ==  FGYRUS_TWDLE_RAM_CODE)    ? 1'b1  : 1'b0;
  assign  cordic_ram_code_sel_c   = (lb_addr_id[P_LB_ADDR_W-1:P_LB_ADDR_W-4]  ==  FGYRUS_CORDIC_RAM_CODE)   ? 1'b1  : 1'b0;

  //Generating RAM interface signals
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb2ram_addr_od          <=  8'd0;
      lb2fft_real_ram_wr_en_oh<=  1'b0;
      lb2fft_im_ram_wr_en_oh  <=  1'b0;
      lb2twiddle_ram_wr_en_oh <=  1'b0;
      lb2cordic_ram_wr_en_oh  <=  1'b0;
      lb2fft_real_ram_rd_en_oh<=  1'b0;
      lb2fft_im_ram_rd_en_oh  <=  1'b0;
      lb2twiddle_ram_rd_en_oh <=  1'b0;
      lb2cordic_ram_rd_en_oh  <=  1'b0;
      lb2ram_wr_data_od       <=  {P_32B_W{1'b0}};
    end
    else
    begin
      lb2ram_addr_od          <=  lb_addr_id[7:0];

      lb2fft_real_ram_wr_en_oh<=  fft_real_ram_code_sel_c & lb_wr_en_ih;
      lb2fft_im_ram_wr_en_oh  <=  fft_im_ram_code_sel_c & lb_wr_en_ih;
      lb2twiddle_ram_wr_en_oh <=  twiddle_ram_code_sel_c  & lb_wr_en_ih;
      lb2cordic_ram_wr_en_oh  <=  cordic_ram_code_sel_c   & lb_wr_en_ih;

      lb2fft_real_ram_rd_en_oh<=  (lb2fft_real_ram_rd_en_oh)  ? ~(~rd_delay_vec[P_RD_DELAY-2] & rd_delay_vec[P_RD_DELAY-1]) : fft_real_ram_code_sel_c & lb_rd_en_ih;
      lb2fft_im_ram_rd_en_oh  <=  (lb2fft_im_ram_rd_en_oh  )  ? ~(~rd_delay_vec[P_RD_DELAY-2] & rd_delay_vec[P_RD_DELAY-1]) : fft_im_ram_code_sel_c   & lb_rd_en_ih;
      lb2twiddle_ram_rd_en_oh <=  (lb2twiddle_ram_rd_en_oh )  ? ~(~rd_delay_vec[P_RD_DELAY-2] & rd_delay_vec[P_RD_DELAY-1]) : twiddle_ram_code_sel_c  & lb_rd_en_ih;
      lb2cordic_ram_rd_en_oh  <=  (lb2cordic_ram_rd_en_oh  )  ? ~(~rd_delay_vec[P_RD_DELAY-2] & rd_delay_vec[P_RD_DELAY-1]) : cordic_ram_code_sel_c   & lb_rd_en_ih;

      lb2ram_wr_data_od       <=  lb_wr_data_id;
    end
  end

  //Register write logic
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fgyrus_en_oh            <=  1'b0;
      fgyrus_post_norm_od     <=  4'd0;
    end
    else
    begin
      if(reg_code_sel_c & lb_wr_en_ih)
      begin
        case(lb_addr_id[7:0]) //synthesis full_case

          FGYRUS_CONTROL_REG_ADDR   : fgyrus_en_oh        <=  lb_wr_data_id[0];

          FGYRUS_POST_NORM_REG_ADDR : fgyrus_post_norm_od <=  lb_wr_data_id[3:0];

        endcase
      end
      else
      begin
        fgyrus_en_oh          <=  fgyrus_en_oh;
        fgyrus_post_norm_od   <=  fgyrus_post_norm_od;
      end
    end
  end

  //Register data mux logic
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      reg_data_f              <=  {P_8B_W{1'b1}};
    end
    else
    begin
      case(lb_addr_id[P_8B_W-1:0])

        FGYRUS_CONTROL_REG_ADDR   : reg_data_f  <=  {7'd0,fgyrus_en_oh};
        FGYRUS_FSM_PSTATE_REG_ADDR: reg_data_f  <=  {5'd0,fgyrus_fsm_pstate_id};
        FGYRUS_STATUS_REG_ADDR    : reg_data_f  <=  {7'd0,fgyrus_busy_ih};
        FGYRUS_POST_NORM_REG_ADDR : reg_data_f  <=  {4'd0,fgyrus_post_norm_od};

        default   : reg_data_f  <=  {P_8B_W{1'b1}};
      endcase
    end
  end

  //Local bus read data mux logic
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb_wr_valid_od          <=  1'b0;
      lb_rd_data_od           <=  {P_LB_DATA_W{1'b0}};
    end
    else
    begin
      lb_wr_valid_od          <=  lb_wr_en_ih;

      case(1'b1)  //synthesis parallel_case

        reg_code_sel_c  :
        begin
          lb_rd_data_od       <=  {24'd0,reg_data_f};
        end

        fft_real_ram_code_sel_c  :
        begin
          lb_rd_data_od       <=  fft_real_ram_rd_data_id;
        end

        fft_im_ram_code_sel_c  :
        begin
          lb_rd_data_od       <=  fft_im_ram_rd_data_id;
        end

        twiddle_ram_code_sel_c  :
        begin
          lb_rd_data_od       <=  {twiddle_ram_rd_real_data_id,twiddle_ram_rd_im_data_id};
        end

        cordic_ram_code_sel_c :
        begin
          lb_rd_data_od       <=  {16'd0,cordic_ram_rd_data_id};
        end

      endcase
    end
  end

  /*  Read delay vector logic */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      rd_delay_vec            <=  {P_RD_DELAY{1'b0}};
    end
    else
    begin
      rd_delay_vec            <=  {rd_delay_vec[P_RD_DELAY-2:0],lb_rd_en_ih}; //shift operation
    end
  end

  assign  lb_rd_valid_od      =   rd_delay_vec[P_RD_DELAY-1];


  //Interrupt logic
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      irq_oh                  <=  1'b0;
    end
    else
    begin
      if(irq_rst_ih)
      begin
        irq_oh                <=  1'b0;
      end
      else
      begin
        irq_oh                <=  irq_oh  | fgyrus_fft_done_ih;
      end
    end
  end

endmodule // fgyrus_lb
