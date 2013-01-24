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
 -- Module Name       : wm8731_drvr_dac
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module drives PCM samples to the WM8731 codec.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

module wm8731_drvr_dac
  (
      clk_ir,                 //50MHz clock input
      rst_il,                 //Asynchronous active low reset

      //MCLK inputs from PLL
      mclk_pll_ir,            //Clk vector to be multiplexed

      //Local Bus interface
      lb_rd_en_ih,            //1->Read enable
      lb_wr_en_ih,            //1->Write enable
      lb_addr_id,             //Address input
      lb_wr_data_id,          //Write Data input
      lb_rd_valid_od,         //1->lb_rd_data_od is valid
      lb_wr_valid_od,         //1->Write is valid
      lb_rd_data_od,          //Read Data output
 

      //PCM Data from prsr
      pcm_ff_data_valid_ih,   //1->PCM data is valid
      pcm_ff_ldata_id,        //Left channel PCM data
      pcm_ff_rdata_id,        //Right channel PCM data
      pcm_ff_rd_ack_oh,       //1->Data has been read from fifo

      //ADC PCM Data to Fgyrus Buffer
      adc2fgyrus_pcm_valid_oh,//1->PCM Data valid
      adc2fgyrus_lpcm_od,     //Left Channel Data
      adc2fgyrus_rpcm_od,     //Left Channel Data

      //Digital Audio Interface
      aud_mclk_od,            //Master Clock to DAC
      aud_blck_od,            //6.25MHz Bit clock
      aud_adc_dat_id,         //ADC data line
      aud_adc_lrc_od,         //ADC sample rate clk
      aud_dac_dat_od,         //DAC data line
      aud_dac_lrc_od          //DAC sample rate clk
  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_LB_ADDR_W       = P_8B_W;
  parameter P_LB_DATA_W       = P_16B_W;

  `include  "acortex_reg_map.v"

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input   [3:0]               mclk_pll_ir;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;


  input                       pcm_ff_data_valid_ih;
  input   [P_32B_W-1:0]       pcm_ff_ldata_id;
  input   [P_32B_W-1:0]       pcm_ff_rdata_id;

  input                       aud_adc_dat_id;

//----------------------- Output Declarations -----------------------------
  output                      lb_rd_valid_od;
  output                      lb_wr_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;

  output                      pcm_ff_rd_ack_oh;

  output                      adc2fgyrus_pcm_valid_oh;
  output  [P_32B_W-1:0]       adc2fgyrus_lpcm_od;
  output  [P_32B_W-1:0]       adc2fgyrus_rpcm_od;

  output                      aud_mclk_od;
  output                      aud_blck_od;
  output                      aud_adc_lrc_od;
  output                      aud_dac_dat_od;
  output                      aud_dac_lrc_od;

//----------------------- Output Register Declaration ---------------------
  reg                         lb_rd_valid_od;
  reg    [P_LB_DATA_W-1:0]    lb_rd_data_od;

  reg                         pcm_ff_rd_ack_oh;

  reg                         adc2fgyrus_pcm_valid_oh;
  reg    [P_32B_W-1:0]        adc2fgyrus_lpcm_od;
  reg    [P_32B_W-1:0]        adc2fgyrus_rpcm_od;

  reg                         aud_blck_od;
  reg                         aud_adc_lrc_od;
  reg                         aud_dac_dat_od;
  reg                         aud_dac_lrc_od;


//----------------------- Internal Register Declarations ------------------
  reg                         dac_drvr_en_f;
  reg                         adc_drvr_en_f;
  reg     [10:0]              fs_div_val_f;
  reg     [1:0]               mclk_sel_f;
  reg                         mclk_en_f;
  reg                         bps_f;  //1->32bps, 0->16bps

  reg     [7:0]               bclk_gen_vec;
  reg     [9:0]               fs_cntr;

  reg     [31:0]              ldata_shift_reg;
  reg     [31:0]              rdata_shift_reg;

  reg                         chnnl_done_c;
  reg                         chnnl_done_1d;
  reg                         chnnl_done_2d;

  reg     [3:0]               mclk_en_vec_c;

  reg                         update_adc_data_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                        aud_dac_rdy_w;

  wire                        fs_cntr_rst_c;



//----------------------- FSM Parameters --------------------------------------
//only for FSM state vector representation
parameter     [2:0]                  // synopsys enum fsm_pstate
IDLE_S             =  3'd0,
START_S            =  3'd1,
LCHANNEL_S         =  3'd2,
RCHANNEL_S         =  3'd3,
WAIT_FOR_FS_S      =  3'd4;

//----------------------- FSM Register Declarations ------------------
reg           [2:0]                            //synthesis syn_encoding = "user"
fsm_pstate, next_state;

//----------------------- FSM String Declarations ------------------
//synthesis translate_off
reg           [8*20:0]      state_name;//"state name" is user defined
//synthesis translate_on

//----------------------- FSM Debugging Logic Declarations ------------------
//synthesis translate_off
always @ (fsm_pstate)
begin
case (fsm_pstate)

IDLE_S        : state_name = "IDLE_S";
START_S       : state_name = "START_S";
LCHANNEL_S    : state_name = "LCHANNEL_S";
RCHANNEL_S    : state_name = "RCHANNEL_S";
WAIT_FOR_FS_S : state_name = "WAIT_FOR_FS_S";

default       : state_name = "ILLEGAL STATE!!";
endcase
end
//synthesis translate_on


//----------------------- Start of Code -----------------------------------

  /*
    * LB transaction decoding
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb_rd_valid_od          <=  1'b0;
      lb_rd_data_od           <=  {P_LB_DATA_W{1'b0}};
    end
    else
    begin
      lb_rd_valid_od          <=  lb_rd_en_ih;

      case(lb_addr_id)

        DAC_DRVR_CTRL_REG_ADDR       :  lb_rd_data_od <=  {{P_LB_DATA_W-3{1'b0}},bps_f,adc_drvr_en_f,dac_drvr_en_f};
        DAC_DRVR_STATUS_REG_ADDR     :  lb_rd_data_od <=  {{P_LB_DATA_W-1{1'b0}},aud_dac_rdy_w};
        DAC_DRVR_FS_DIV_REG_ADDR     :  lb_rd_data_od <=  {5'd0,fs_div_val_f};
        DAC_DRVR_MCLK_SEL_REG_ADDR   :  lb_rd_data_od <=  {mclk_en_f,13'd0,mclk_sel_f};

        default : lb_rd_data_od     <=  16'hdead;

      endcase
    end
  end

  assign  lb_wr_valid_od      = lb_wr_en_ih;

  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      dac_drvr_en_f           <=  1'b0;
      adc_drvr_en_f           <=  1'b0;
      fs_div_val_f            <=  11'd0;
      mclk_sel_f              <=  2'd0;
      mclk_en_f               <=  1'b0;
      bps_f                   <=  1'b1; //default is 32bps
    end
    else
    begin
      if(lb_wr_en_ih)
      begin
        dac_drvr_en_f         <=  (lb_addr_id ==  DAC_DRVR_CTRL_REG_ADDR) ? lb_wr_data_id[0]  : dac_drvr_en_f;

        adc_drvr_en_f         <=  (lb_addr_id ==  DAC_DRVR_CTRL_REG_ADDR) ? lb_wr_data_id[1]  : adc_drvr_en_f;

        bps_f                 <=  (lb_addr_id ==  DAC_DRVR_CTRL_REG_ADDR) ? lb_wr_data_id[2]  : bps_f;

        fs_div_val_f          <=  (lb_addr_id ==  DAC_DRVR_FS_DIV_REG_ADDR) ? lb_wr_data_id[10:0] : fs_div_val_f;

        mclk_sel_f            <=  (lb_addr_id ==  DAC_DRVR_MCLK_SEL_REG_ADDR) ? lb_wr_data_id[1:0]  : mclk_sel_f;

        mclk_en_f             <=  (lb_addr_id ==  DAC_DRVR_MCLK_SEL_REG_ADDR) ? lb_wr_data_id[P_LB_DATA_W-1]  : mclk_en_f;
      end
      else
      begin
        dac_drvr_en_f         <=  dac_drvr_en_f;
        fs_div_val_f          <=  fs_div_val_f;
        mclk_sel_f            <=  mclk_sel_f;
        mclk_en_f             <=  mclk_en_f;
      end

    end
  end

  /*
    * BCLK generation logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      aud_blck_od              <=  1'b0;
      bclk_gen_vec            <=  8'd1;
    end
    else
    begin
      bclk_gen_vec            <=  {bclk_gen_vec[6:0], bclk_gen_vec[7]};

      if(~dac_drvr_en_f & ~adc_drvr_en_f)
      begin
        aud_blck_od           <=  1'b0;
      end
      else  if(bclk_gen_vec[3])
      begin
        aud_blck_od            <=  1'b1;
      end
      else if(bclk_gen_vec[7])
      begin
        aud_blck_od            <=  1'b0;
      end
      else
      begin
        aud_blck_od            <=  aud_blck_od;
      end
    end
  end

  /*
    * Sequential part of FSM
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fsm_pstate              <=  IDLE_S;
      pcm_ff_rd_ack_oh        <=  1'b0;
    end
    else
    begin
      fsm_pstate              <=  next_state;

      pcm_ff_rd_ack_oh        <=  (fsm_pstate ==  START_S)  ? pcm_ff_data_valid_ih  & bclk_gen_vec[6] & dac_drvr_en_f :
                                                              1'b0;
    end
  end

  /*
    * Combination part of FSM
  */
  always@(*)
  begin
    next_state                = fsm_pstate;
    chnnl_done_c              = 1'b0;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if(bclk_gen_vec[7])
        begin
          if((dac_drvr_en_f & pcm_ff_data_valid_ih) | adc_drvr_en_f)
          begin
            next_state          = START_S;
          end
        end
      end

      START_S :
      begin
        if(bclk_gen_vec[7])
        begin
          next_state          = LCHANNEL_S;
        end
      end

      LCHANNEL_S  :
      begin
        if(bps_f) //32b per sample
        begin
          chnnl_done_c        = (fs_cntr  ==  10'd32) ? bclk_gen_vec[7] : 1'b0;
        end
        else  //16b per sample
        begin
          chnnl_done_c        = (fs_cntr  ==  10'd16) ? bclk_gen_vec[7] : 1'b0;
        end

        if(chnnl_done_c)
        begin
          next_state          = RCHANNEL_S;
        end
      end

      RCHANNEL_S  :
      begin
        if(bps_f) //32b per sample
        begin
          chnnl_done_c        = (fs_cntr  ==  10'd64) ? bclk_gen_vec[7] : 1'b0;
        end
        else  //16b per sample
        begin
          chnnl_done_c        = (fs_cntr  ==  10'd32) ? bclk_gen_vec[7] : 1'b0;
        end

        if(chnnl_done_c)
        begin
          next_state          = WAIT_FOR_FS_S;
        end
      end
 
      WAIT_FOR_FS_S :
      begin
        if(fs_cntr_rst_c)
        begin
          next_state          = IDLE_S;
        end
      end

    endcase
  end

  //Generate busy status
  assign  aud_dac_rdy_w       = (fsm_pstate ==  IDLE_S)   ? 1'b1  : 1'b0;

  /*
    * FS counter logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fs_cntr                 <=  10'd0;
    end
    else
    begin
      if(fsm_pstate ==  IDLE_S)
      begin
        fs_cntr               <=  10'd0;
      end
      else
      begin
        fs_cntr             <=  fs_cntr + bclk_gen_vec[7];
      end
    end
  end

  //Generate signal to reset fs_cntr once max value is reached
  assign  fs_cntr_rst_c       = (fs_cntr  ==  fs_div_val_f)  ? 1'b1  : 1'b0;

  /*
    * Shift registers to shift out PCM data
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      ldata_shift_reg         <=  32'd0;
      rdata_shift_reg         <=  32'd0;
    end
    else
    begin
      case(fsm_pstate)

        START_S :
        begin
          ldata_shift_reg     <=  pcm_ff_rd_ack_oh  ? pcm_ff_ldata_id : ldata_shift_reg;
          rdata_shift_reg     <=  pcm_ff_rd_ack_oh  ? pcm_ff_rdata_id : rdata_shift_reg;
        end

        LCHANNEL_S  :
        begin
          rdata_shift_reg     <=  rdata_shift_reg;

          if(bclk_gen_vec[7])
          begin
            ldata_shift_reg <=  {ldata_shift_reg[30:0],1'b0}; //shift out MSB first
          end
        end

        RCHANNEL_S  :
        begin
          ldata_shift_reg     <=  ldata_shift_reg;

          if(bclk_gen_vec[7])
          begin
            rdata_shift_reg <=  {rdata_shift_reg[30:0],1'b0}; //shift out MSB first
          end
        end

        default :
        begin
          ldata_shift_reg     <=  32'd0;
          rdata_shift_reg     <=  32'd0;
        end

      endcase
    end
  end

  /*
    * DAC Output logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      aud_dac_dat_od          <=  1'b0;
      aud_dac_lrc_od          <=  1'b0;
    end
    else
    begin
      if(dac_drvr_en_f)
      begin
        if(bps_f)  //32b
        begin
          aud_dac_dat_od        <=  (fsm_pstate ==  LCHANNEL_S) ? ldata_shift_reg[31] :
                                                                  rdata_shift_reg[31];
        end
        else  //16b
        begin
          aud_dac_dat_od        <=  (fsm_pstate ==  LCHANNEL_S) ? ldata_shift_reg[15] :
                                                                  rdata_shift_reg[15];
        end

        aud_dac_lrc_od          <=  (fsm_pstate ==  START_S)    ? 1'b1  : 1'b0;
      end
      else
      begin
        aud_dac_dat_od        <=  1'b0;
        aud_dac_lrc_od        <=  1'b0;
      end
    end
  end

  /*
  * ADC Sampling Logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      aud_adc_lrc_od          <=  1'b0;

      adc2fgyrus_pcm_valid_oh <=  1'b0;
      adc2fgyrus_lpcm_od      <=  {P_32B_W{1'b0}};
      adc2fgyrus_rpcm_od      <=  {P_32B_W{1'b0}};

      update_adc_data_f       <=  1'b0;

      chnnl_done_1d           <=  1'b0;
      chnnl_done_2d           <=  1'b0;
    end
    else
    begin
      chnnl_done_1d           <=  chnnl_done_c;
      chnnl_done_2d           <=  chnnl_done_1d;

      if(adc_drvr_en_f)
      begin
        aud_adc_lrc_od        <=  (fsm_pstate ==  START_S)  ? 1'b1  : 1'b0;

        if(update_adc_data_f)
        begin
          adc2fgyrus_lpcm_od  <=  {{P_16B_W{adc2fgyrus_lpcm_od[P_16B_W-1]}},adc2fgyrus_lpcm_od[P_16B_W-1:0]};
          adc2fgyrus_rpcm_od  <=  {{P_16B_W{adc2fgyrus_rpcm_od[P_16B_W-1]}},adc2fgyrus_rpcm_od[P_16B_W-1:0]};
        end
        else
        begin
          adc2fgyrus_lpcm_od  <=  ((fsm_pstate ==  LCHANNEL_S)  & bclk_gen_vec[4])  ? {adc2fgyrus_lpcm_od[P_32B_W-2:0],aud_adc_dat_id}
                                                                                    : adc2fgyrus_lpcm_od;

          adc2fgyrus_rpcm_od  <=  ((fsm_pstate  ==  RCHANNEL_S) & bclk_gen_vec[4])  ? {adc2fgyrus_rpcm_od[P_32B_W-2:0],aud_adc_dat_id}
                                                                                    : adc2fgyrus_rpcm_od;
        end

        update_adc_data_f     <=  ((fsm_pstate ==  RCHANNEL_S)  & chnnl_done_c) ? ~bps_f : 1'b0;

        adc2fgyrus_pcm_valid_oh  <=  (fsm_pstate ==  WAIT_FOR_FS_S) ? chnnl_done_2d : 1'b0;
      end
      else
      begin
        adc2fgyrus_pcm_valid_oh  <=  1'b0;
        aud_adc_lrc_od        <=  1'b0;
        update_adc_data_f     <=  1'b0;
      end
    end
  end


  /*
    * MCLK Clock multiplexing
  */
  //  wm_xclk_mux       mclk_mux_inst
  //  (
  //    .clkselect      (mclk_sel_f),
  //    .ena            (mclk_en_f),
  //    .inclk0x        (mclk_pll_ir[0]),
  //    .inclk1x        (mclk_pll_ir[1]),
  //    .inclk2x        (mclk_pll_ir[2]),
  //    .inclk3x        (mclk_pll_ir[3]),
  //    .outclk         (aud_mclk_od)
  //  );

  //assign  aud_mclk_od         = mclk_en_f & mclk_pll_ir[mclk_sel_f];

  always@(*)  //one hot encoder
  begin
    mclk_en_vec_c = 4'd0;

    mclk_en_vec_c[mclk_sel_f] = mclk_en_f;
  end

  clk_mux   clk_mux_inst
  (
    .clk_vec_ir           (mclk_pll_ir),
    .rst_il               (rst_il),

    .clk_en_vec_id        (mclk_en_vec_c),

    .clk_or               (aud_mclk_od)
  );



endmodule // wm8731_drvr_dac
