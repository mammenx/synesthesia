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
 -- Module Name       : wav_prsr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module parses wav files and manages data xfr
                        from SRAM to Codec.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module wav_prsr
  (  
      clk_ir,                 //Clock Input
      rst_il,                 //Active low reset

      //SRAM interface
      sram_empty_ih,          //1->SRAM is empty
      sram_rd_en_oh,          //1->Read enabled
      sram_rd_data_valid_ih,  //1->Read data is valid
      sram_rd_data_id,        //Data read from SRAM

      //Local Bus interface
      lb_rd_en_ih,            //1->Read enable
      lb_wr_en_ih,            //1->Write enable
      lb_addr_id,             //Address input
      lb_wr_data_id,          //Write Data input
      lb_rd_valid_od,         //1->lb_rd_data_od is valid
      lb_rd_data_od,          //Read Data output
      lb_wr_valid_od,         //1->Write transaction has gone through

      //Outputs to WM DAC Driver
      wav_bps_od,             //0->16bps, 1->32bps


      //PCM FIFO Outputs
      pcm_ff_afull_ih,        //1->PCM Fifo is almost full
      pcm_ff_wr_en_oh,        //1->Write pcm_data
      pcm_ff_ldata_od,        //32b left channel PCM data
      pcm_ff_rdata_od         //32b right channel PCM data
     

  );

//----------------------- Global parameters Declarations ------------------
  parameter P_64B_W           = 64;
  parameter P_32B_W           = 32;
  parameter P_16B_W           = 16;
  parameter P_8B_W            = 8;

  parameter P_SRAM_DATA_W     = P_16B_W;
  parameter P_HDR_RAM_ADDR_W  = P_8B_W;
  parameter P_HDR_RAM_DATA_W  = P_16B_W;
  parameter P_PCM_FF_DATA_W   = P_32B_W;
  parameter P_LB_ADDR_W       = P_8B_W;
  parameter P_LB_DATA_W       = P_16B_W;

  //Parser FSM register size
  localparam  P_FSM_CHUNK_W   = 2;
  localparam  P_FSM_FIELD_W   = 3;
  localparam  P_FSM_REG_W     = 1 + P_FSM_CHUNK_W + P_FSM_FIELD_W;

  `define     D_FSM_STATUS_TAP  P_FSM_REG_W-1
  `define     D_FSM_CHUNK_TAP   P_FSM_REG_W-2:P_FSM_FIELD_W
  `define     D_FSM_FIELD_TAP   P_FSM_FIELD_W-1:0

  //WAVE Format parameters
  localparam  P_RIFF_PTRN     = 32'h52494646;
  localparam  P_WAVE_PTRN     = 32'h57415645;
  localparam  P_FMT_PTRN      = 32'h666d7420;
  localparam  P_DATA_PTRN     = 32'h64617461;
  localparam  P_PCM_FMT_PTRN  = 16'h0100; //little endian format!

  `include  "acortex_reg_map.v"

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       sram_empty_ih;
  input                       sram_rd_data_valid_ih;
  input   [P_SRAM_DATA_W-1:0] sram_rd_data_id;

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;

  input                       pcm_ff_afull_ih;

//----------------------- Output Declarations -----------------------------
  output                      sram_rd_en_oh;

  output                      lb_rd_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;
  output                      lb_wr_valid_od;

  output                      wav_bps_od;

  output                      pcm_ff_wr_en_oh;
  output  [P_PCM_FF_DATA_W-1:0]   pcm_ff_ldata_od;
  output  [P_PCM_FF_DATA_W-1:0]   pcm_ff_rdata_od;

//----------------------- Output Register Declaration ---------------------
  reg                         lb_rd_valid_od;
  reg     [P_LB_DATA_W-1:0]   lb_rd_data_od;

  reg                         pcm_ff_wr_en_oh;
  reg     [P_PCM_FF_DATA_W-1:0]   pcm_ff_ldata_od;
  reg     [P_PCM_FF_DATA_W-1:0]   pcm_ff_rdata_od;


//----------------------- Internal Register Declarations ------------------
  reg                         prsr_en_f;
  reg     [P_HDR_RAM_ADDR_W-1:0]  hdr_ram_rd_addr_f;

  reg     [P_32B_W-1:0]       word_cntr_f;  //No of 16b words read from SRAM
  reg     [11:0]              pst_vec_f;    //Internal pipeline vector

  reg     [P_32B_W-1:0]       pcm_data_size_f;

  reg                         rst_field_c;
  reg                         last_word_f;

  reg                         num_chnnls_f; //0->Mono, 1->Dual
  reg                         bps_f;        //0->16bps, 1->32bps

  reg   [1:0]                 tggl_f;

  reg   [4:0]                 fmt_chnk_end_ptr_f; //16b pointer to end of FMT chunk

//----------------------- Internal Wire Declarations ----------------------
  wire    [P_HDR_RAM_DATA_W-1:0]  wav_hdr_ram_rd_data_w;

  wire                        end_of_file_c;

  wire                        hdr_ram_wr_en_c;
  wire  [P_8B_W-1:0]          hdr_ram_wr_addr_w;

  wire  [4:0]                 data_chnk_end_ptr_c;  //pointer to end of data chunk / beginning of PCM data
  wire  [4:0]                 pcm_data_end_ptr_offst_c;   //an offset used to predict end of file

//----------------------- FSM Parameters --------------------------------------
//
//  FSM State vector breakup
//
//  +-------------+-----------+-----------+
//  | STATUS  (1) | CHUNK (2) | FIELD (3) |
//  +-------------+-----------+-----------+
//
//only for FSM state vector representation
parameter
P_FSM_IDLE_S          = 1'b0,
P_FSM_ACTIV_S         = 1'b1;

parameter     [P_FSM_CHUNK_W-1:0]             // synopsys enum fsm_pstate
P_FSM_CHUNK_WAVE_S    = 0,
P_FSM_CHUNK_FMT_S     = 1,
P_FSM_CHUNK_DATA_S    = 2,
P_FSM_CHUNK_PCM_DATA_S= 3;

parameter     [P_FSM_FIELD_W-1:0]             // synopsys enum fsm_pstate
P_FSM_FIELD_ID_S      = 0,
P_FSM_FIELD_SIZE_S    = 1,
P_FSM_FIELD_FMT_S     = 2,
P_FSM_FIELD_NCHNNL_S  = 3,
P_FSM_FIELD_FS_S      = 4,
P_FSM_FIELD_BRATE_S   = 5,
P_FSM_FIELD_BLKA_S    = 6,
P_FSM_FIELD_BPS_S     = 7;

//----------------------- FSM Register Declarations ------------------
reg           [P_FSM_REG_W-1:0]               // synthesis preserve syn_encoding = "user"
fsm_pstate, next_state;

//----------------------- FSM String Declarations ------------------
//synthesis translate_off
reg           [8*20:0]        fsm_status_name,fsm_chunk_name,fsm_field_name;
//synthesis translate_on

//----------------------- FSM Debugging Logic Declarations ------------------
//synthesis translate_off
always @ (fsm_pstate[`D_FSM_STATUS_TAP])
begin
case (fsm_pstate[`D_FSM_STATUS_TAP])

P_FSM_IDLE_S    : fsm_status_name = "IDLE";

P_FSM_ACTIV_S   : fsm_status_name = "ACTIVE";

endcase
end

always @ (fsm_pstate[`D_FSM_CHUNK_TAP])
begin
case (fsm_pstate[`D_FSM_CHUNK_TAP])

P_FSM_CHUNK_WAVE_S      : fsm_chunk_name  = "WAVE CHUNK";

P_FSM_CHUNK_FMT_S       : fsm_chunk_name  = "FMT CHUNK";

P_FSM_CHUNK_DATA_S      : fsm_chunk_name  = "DATA CHUNK";

P_FSM_CHUNK_PCM_DATA_S  : fsm_chunk_name  = "PCM DATA CHUNK";

endcase
end

always @ (fsm_pstate[`D_FSM_FIELD_TAP])
begin
case (fsm_pstate[`D_FSM_FIELD_TAP])

P_FSM_FIELD_ID_S        : fsm_field_name  = "ID FIELD";

P_FSM_FIELD_SIZE_S      : fsm_field_name  = "SIZE FIELD";

P_FSM_FIELD_FMT_S       : fsm_field_name  = "FORMAT FIELD";

P_FSM_FIELD_NCHNNL_S    : fsm_field_name  = "NO CHANNELS FIELD";

P_FSM_FIELD_FS_S        : fsm_field_name  = "FS FIELD";

P_FSM_FIELD_BRATE_S     : fsm_field_name  = "BYTE RATE FIELD";

P_FSM_FIELD_BLKA_S      : fsm_field_name  = "BLOCK ALIGN FIELD";

P_FSM_FIELD_BPS_S       : fsm_field_name  = "BPS FIELD";

endcase
end
//synthesis translate_on


//----------------------- Start of Code -----------------------------------

  /*
    * Decoding LB transactions
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

        PRSR_CTRL_REG_ADDR            :   lb_rd_data_od <=  {{P_LB_DATA_W-1{1'b0}},prsr_en_f};

        PRSR_FSM_PSTATE_REG_ADDR      :   lb_rd_data_od <=  {{P_LB_DATA_W-P_FSM_REG_W{1'b0}},fsm_pstate};

        PRSR_BYTES_READ_H_REG_ADDR    :   lb_rd_data_od <=  word_cntr_f[P_32B_W-2:P_16B_W-1];

        PRSR_BYTES_READ_L_REG_ADDR    :   lb_rd_data_od <=  {word_cntr_f[P_16B_W-2:0],1'b0};

        PRSR_HDR_RAM_RD_ADDR_REG_ADDR :   lb_rd_data_od <=  {{P_LB_DATA_W-P_HDR_RAM_ADDR_W{1'b0}},hdr_ram_rd_addr_f};

        PRSR_HDR_RAM_RD_DATA_REG_ADDR :   lb_rd_data_od <=  wav_hdr_ram_rd_data_w;

        default :     lb_rd_data_od   <=  16'hdead;

      endcase
    end
  end

  assign  lb_wr_valid_od      = lb_wr_en_ih;


  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      prsr_en_f               <=  1'b0;
      hdr_ram_rd_addr_f       <=  {P_HDR_RAM_ADDR_W{1'b0}};
    end
    else
    begin
      if(lb_wr_en_ih)
      begin
        prsr_en_f             <=  (lb_addr_id ==  PRSR_CTRL_REG_ADDR) ? lb_wr_data_id[0]  : prsr_en_f;

        hdr_ram_rd_addr_f     <=  (lb_addr_id ==  PRSR_HDR_RAM_RD_ADDR_REG_ADDR)  ? lb_wr_data_id[P_HDR_RAM_ADDR_W-1:0] : hdr_ram_rd_addr_f;
      end
      else
      begin
        prsr_en_f             <=  prsr_en_f;
        hdr_ram_rd_addr_f     <=  hdr_ram_rd_addr_f;
      end
    end
  end

  /*
    * FSM Sequential logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fsm_pstate              <=  {P_FSM_IDLE_S,P_FSM_CHUNK_WAVE_S,P_FSM_FIELD_ID_S};
    end
    else
    begin
      fsm_pstate              <=  next_state;
    end
  end


  /*
    * FSM Combinational logic
  */
  always@(*)
  begin
    next_state  = fsm_pstate;
    rst_field_c = 1'b0;

    //FSM Status update
    case(fsm_pstate[`D_FSM_STATUS_TAP]) //synthesis full_case

      P_FSM_IDLE_S  :
      begin
        if(prsr_en_f & ~sram_empty_ih)
        begin
          next_state[`D_FSM_STATUS_TAP] = P_FSM_ACTIV_S;
          rst_field_c                   = 1'b1;
        end
      end

      P_FSM_ACTIV_S :
      begin
        if(end_of_file_c)
        begin
          next_state[`D_FSM_STATUS_TAP] = P_FSM_IDLE_S;
        end
      end

    endcase

    //FSM Chunk update
    case(fsm_pstate[`D_FSM_CHUNK_TAP])  //synthesis full_case

      P_FSM_CHUNK_WAVE_S  :
      begin
        if(sram_rd_data_valid_ih  & (word_cntr_f[2:0] ==  3'd5))
        begin
          next_state[`D_FSM_CHUNK_TAP]  = P_FSM_CHUNK_FMT_S;
          rst_field_c                   = 1'b1;
        end
      end

      P_FSM_CHUNK_FMT_S :
      begin
        //if(sram_rd_data_valid_ih  & (word_cntr_f[4:0] ==  5'd17))
        if(sram_rd_data_valid_ih  & (word_cntr_f[4:0] ==  fmt_chnk_end_ptr_f))
        begin
          next_state[`D_FSM_CHUNK_TAP]  = P_FSM_CHUNK_DATA_S;
          rst_field_c                   = 1'b1;
        end
      end

      P_FSM_CHUNK_DATA_S  :
      begin
        //if(sram_rd_data_valid_ih  & (word_cntr_f[4:0] ==  5'd21))
        if(sram_rd_data_valid_ih  & (word_cntr_f[4:0] ==  data_chnk_end_ptr_c))
        begin
          next_state[`D_FSM_CHUNK_TAP]  = P_FSM_CHUNK_PCM_DATA_S;
          rst_field_c                   = 1'b1;
        end
      end

      P_FSM_CHUNK_PCM_DATA_S  :
      begin
        rst_field_c = 1'b1;

        if(end_of_file_c)
        begin
          next_state[`D_FSM_CHUNK_TAP]  = P_FSM_CHUNK_WAVE_S;
        end
      end

    endcase

    //FSM Field update
    if(rst_field_c)
    begin
      next_state[`D_FSM_FIELD_TAP]  = P_FSM_FIELD_ID_S;
    end
    else  if(sram_rd_data_valid_ih)
    begin
      case(fsm_pstate[`D_FSM_FIELD_TAP])  //synthesis full_case

        P_FSM_FIELD_ID_S  :
        begin
          if(pst_vec_f[1])
          begin
            next_state[`D_FSM_FIELD_TAP]  = P_FSM_FIELD_SIZE_S;
          end
        end

        P_FSM_FIELD_SIZE_S  :
        begin
          if(pst_vec_f[3])
          begin
            next_state[`D_FSM_FIELD_TAP]  = P_FSM_FIELD_FMT_S;
          end
        end

        P_FSM_FIELD_FMT_S :
        begin
          if(fsm_pstate[`D_FSM_CHUNK_TAP] ==  P_FSM_CHUNK_FMT_S)
          begin
            next_state[`D_FSM_FIELD_TAP]  = P_FSM_FIELD_NCHNNL_S;
          end
          //else - will get rst to ID anyway
        end

        P_FSM_FIELD_NCHNNL_S  :
        begin
          next_state[`D_FSM_FIELD_TAP]    = P_FSM_FIELD_FS_S;
        end

        P_FSM_FIELD_FS_S  :
        begin
          if(pst_vec_f[7])
          begin
            next_state[`D_FSM_FIELD_TAP]  = P_FSM_FIELD_BRATE_S;
          end
        end

        P_FSM_FIELD_BRATE_S :
        begin
          if(pst_vec_f[9])
          begin
            next_state[`D_FSM_FIELD_TAP]  = P_FSM_FIELD_BLKA_S;
          end
        end

        P_FSM_FIELD_BLKA_S  :
        begin
          next_state[`D_FSM_FIELD_TAP]    = P_FSM_FIELD_BPS_S;
        end

        P_FSM_FIELD_BPS_S : //Never hit; gets reset
        begin
          next_state[`D_FSM_FIELD_TAP]    = P_FSM_FIELD_ID_S;
        end

      endcase
    end

  end

  /*
    * Word counter logic
    * Keeps track of number of 16b words read from SRAM
    *
    * Extracting the number of bytes of PCM data from WAV file
    *
    * Last word flag gives early indication of end of file
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      word_cntr_f             <=  {P_32B_W{1'b0}};
      pcm_data_size_f         <=  {P_32B_W{1'b1}}; //start with infinity
      last_word_f             <=  1'b0;
      fmt_chnk_end_ptr_f      <=  5'd0;
    end
    else
    begin
      if(end_of_file_c)
      begin
        word_cntr_f           <=  {P_32B_W{1'b0}};
      end
      else
      begin
        word_cntr_f           <=  word_cntr_f + sram_rd_data_valid_ih;
      end

      if(end_of_file_c)
      begin
        pcm_data_size_f       <=  {P_32B_W{1'b1}};
      end
      else if(sram_rd_data_valid_ih & (fsm_pstate[`D_FSM_FIELD_TAP] ==  P_FSM_FIELD_SIZE_S))
      begin
        pcm_data_size_f       <=  {sram_rd_data_id[P_8B_W-1:0],sram_rd_data_id[P_16B_W-1:P_8B_W],pcm_data_size_f[P_32B_W-1:P_SRAM_DATA_W]}; //shift data in [big endian format]
      end
      else
      begin
        pcm_data_size_f       <=  pcm_data_size_f;
      end

      if(last_word_f)
      begin
        last_word_f           <=  ~end_of_file_c;
      end
      else
      begin
        //last_word_f           <=  (word_cntr_f  ==  ({1'b0,pcm_data_size_f[P_32B_W-1:1]}  + pcm_data_size_f[0]  + 6'd20)) ? 1'b1  : 1'b0;
        last_word_f           <=  (word_cntr_f  ==  ({1'b0,pcm_data_size_f[P_32B_W-1:1]}  + pcm_data_size_f[0]  + pcm_data_end_ptr_offst_c))
                                  ? sram_rd_data_valid_ih : 1'b0;
      end

      if((word_cntr_f ==  32'd8)  & sram_rd_data_valid_ih)
      begin
        fmt_chnk_end_ptr_f    <=  (sram_rd_data_id[P_SRAM_DATA_W-1  -:  P_8B_W] ==  8'd18)  ? 5'd18 : 5'd17;
      end
      else
      begin
        fmt_chnk_end_ptr_f    <=  fmt_chnk_end_ptr_f;
      end
    end
  end

  assign  data_chnk_end_ptr_c =   fmt_chnk_end_ptr_f  + 3'd4;

  assign  pcm_data_end_ptr_offst_c  =   fmt_chnk_end_ptr_f  + 2'd3;


  //Check if end of file has been reached
  assign  end_of_file_c       = last_word_f & sram_rd_data_valid_ih;

  /*
    * PST Vector logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pst_vec_f               <=  12'd0;
    end
    else
    begin
      pst_vec_f[0]            <=  pst_vec_f[0]  ? ~(sram_rd_data_valid_ih & ~rst_field_c) :
                                                  rst_field_c;

      if(rst_field_c)
      begin
        pst_vec_f[11:1]       <=  11'd0;
      end
      else  if(sram_rd_data_valid_ih)
      begin
        pst_vec_f[11:1]       <=  {pst_vec_f[10:0]};  //shift
      end
      else
      begin
        pst_vec_f[11:1]       <=  pst_vec_f[11:1];
      end
    end
  end

  //Issue read to SRAM when parser is enabled & PCM Fifo has space
  assign  sram_rd_en_oh       = (fsm_pstate[`D_FSM_STATUS_TAP]  ==  P_FSM_ACTIV_S)  ? ~pcm_ff_afull_ih  :
                                                                                      1'b0;

  /*
    * Extracting misc information from header
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      num_chnnls_f            <=  1'b0;
      bps_f                   <=  1'b0;
    end
    else
    begin
      if(fsm_pstate[`D_FSM_FIELD_TAP]  ==  P_FSM_FIELD_NCHNNL_S)
      begin
        num_chnnls_f          <=  sram_rd_data_valid_ih ? sram_rd_data_id[1] : num_chnnls_f;
      end
      else
      begin
        num_chnnls_f          <=  num_chnnls_f;
      end

      if(fsm_pstate[`D_FSM_FIELD_TAP] ==  P_FSM_FIELD_BPS_S)
      begin
        bps_f                 <=  sram_rd_data_valid_ih ? sram_rd_data_id[5]  : bps_f;  //2^5 = 32
      end
      else
      begin
        bps_f                 <=  bps_f;
      end
    end
  end

  /*
    * Logic for formatting PCM data
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pcm_ff_wr_en_oh         <=  1'b0;
      pcm_ff_ldata_od         <=  {P_PCM_FF_DATA_W{1'b0}};
      pcm_ff_rdata_od         <=  {P_PCM_FF_DATA_W{1'b0}};

      tggl_f                  <=  2'd0;
    end
    else
    begin
      if(fsm_pstate[`D_FSM_CHUNK_TAP] ==  P_FSM_CHUNK_PCM_DATA_S)
      begin
        if(~num_chnnls_f) //Mono
        begin
          pcm_ff_rdata_od     <=  {P_PCM_FF_DATA_W{1'b0}};  //Null Channel

          if(~bps_f)  //16bps
          begin
            pcm_ff_ldata_od   <=  {{P_16B_W{sram_rd_data_id[P_SRAM_DATA_W-1]}},sram_rd_data_id};  //2's compliment form
            pcm_ff_wr_en_oh   <=  sram_rd_data_valid_ih;
          end
          else  //32bps
          begin
            tggl_f            <=  tggl_f  + sram_rd_data_valid_ih;

            pcm_ff_ldata_od   <=  {pcm_ff_ldata_od[P_16B_W-1:0],sram_rd_data_id};
            pcm_ff_wr_en_oh   <=  sram_rd_data_valid_ih & tggl_f[0];
          end
        end
        else  //Dual
        begin
          if(~bps_f)  //16bps
          begin
            tggl_f            <=  tggl_f  + sram_rd_data_valid_ih;

            pcm_ff_ldata_od   <=  ~tggl_f[0]  ? {{P_16B_W{sram_rd_data_id[P_SRAM_DATA_W-1]}},sram_rd_data_id} :  //2's compliment form
                                                pcm_ff_ldata_od;

            pcm_ff_rdata_od   <=  tggl_f[0]  ?  {{P_16B_W{sram_rd_data_id[P_SRAM_DATA_W-1]}},sram_rd_data_id} :  //2's compliment form
                                                pcm_ff_rdata_od;

            pcm_ff_wr_en_oh   <=  sram_rd_data_valid_ih & tggl_f[0];
          end
          else  //32bps
          begin
            tggl_f            <=  tggl_f  + sram_rd_data_valid_ih;

            pcm_ff_ldata_od   <=  ~tggl_f[1]  ? {pcm_ff_ldata_od[P_16B_W-1:0],sram_rd_data_id}  : pcm_ff_ldata_od;
            pcm_ff_rdata_od   <=  tggl_f[1]   ? {pcm_ff_rdata_od[P_16B_W-1:0],sram_rd_data_id}  : pcm_ff_rdata_od;
            pcm_ff_wr_en_oh   <=  sram_rd_data_valid_ih & (&(tggl_f));
          end
        end
      end
      else
      begin
        pcm_ff_wr_en_oh       <=  1'b0;
      end
    end
  end


  /*
    * Instantiating Headr RAM
  */
  wav_hdr_ram       wav_hdr_ram_inst
  (
    .clock          (clk_ir),
    .data           (sram_rd_data_id),
    .rdaddress      (hdr_ram_rd_addr_f),
    .wraddress      (hdr_ram_wr_addr_w),
    .wren           (hdr_ram_wr_en_c),
    .q              (wav_hdr_ram_rd_data_w)
  );

  assign  hdr_ram_wr_en_c     = sram_rd_data_valid_ih & fsm_pstate[`D_FSM_STATUS_TAP]
                                                      & (fsm_pstate[`D_FSM_CHUNK_TAP] !=  P_FSM_CHUNK_PCM_DATA_S);

  assign  hdr_ram_wr_addr_w   = word_cntr_f[P_8B_W-1:0];


  assign  wav_bps_od          = bps_f;

endmodule // wav_prsr
