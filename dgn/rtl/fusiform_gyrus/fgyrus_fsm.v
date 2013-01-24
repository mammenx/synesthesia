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
 -- Module Name       : fgyrus_fsm
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module generates the control/cordination
                        signals for other blocks. Issues reads/writes to
                        cache ram.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module fgyrus_fsm
  (
    clk_ir,                   //Clock input
    rst_il,                   //Asynchronous active low reset

    //Local bus interface
    fgyrus_en_ih,             //1->Enable FFT processing
    fgyrus_fft_done_oh,       //1->FFT processing is finished
    fgyrus_pcm_done_oh,       //1->All PCM samples have been processed
    fgyrus_busy_oh,           //1->FGYRUS is busy processing FFT
    fgyrus_fsm_pstate_od,     //Present state of FGYRUS FSM
    fgyrus_post_norm_id,      //FFT Post normalize config

    //Trigger signals
    fgyrus_pcm_rdy_ih,        //1->128 PCM samples are ready for FFT

    //PCM RAM interface
    pcm_ram_rd_addr_od,       //Read address to PCM RAM
    pcm_ram_rd_data_id,       //Read data from PCM RAM

    //FFT CACHE RAM interface
    fft_ram_rd_addr_od,       //Read address to FFT cache
    fft_ram_rd_real_data_id,  //Real data read from FFT cache
    fft_ram_rd_im_data_id,    //Imaginary data read from FFT cache
    fft_ram_wr_real_en_oh,    //1->Write data to FFT real cache
    fft_ram_wr_im_en_oh,      //1->Write data to FFT im cache
    fft_ram_wr_addr_od,       //1->Write address to FFT RAM
    fft_ram_wr_real_data_od,  //Real write data to FFT cache
    fft_ram_wr_im_data_od,    //Imaginary write data to FFT cache

    //FFT Result RAM - where the final ABS values are stored for direct access
    //by CPU
    fft_res_wr_addr_od,       //Write address to FFT Res RAM
    fft_res_wr_data_od,       //Write Data to FFT Res RAM
    fft_res_wr_en_oh,         //1->Write enable to FFT Res RAM

    //Twiddle RAM interface
    twiddle_ram_rd_addr_od,   //Read address to twiddle ram
    twiddle_ram_real_data_id, //Real data read from twiddle RAM
    twiddle_ram_im_data_id,   //Imaginary data read from twiddle RAM

    //CORDIC RAM interface
    cordic_ram_rd_addr_od,    //Read address to CORDIC ram
    cordic_ram_rd_data_id,    //Data read from CORDIC ram

    //Butterfly interface
    sample_a_real_od,         //Output sample A real part
    sample_a_im_od,           //Output sample A imaginary part

    sample_b_real_od,         //Output sample B real part
    sample_b_im_od,           //Output sample B imaginary part

    twdl_factor_real_od,      //Output twiddle factor real part
    twdl_factor_im_od,        //Output twiddle facotr imaginary part

    samples_rdy_oh,           //1->Samples are ready for computation

    fft_data_real_id,         //FFT data real part from butterfly
    fft_data_im_id,           //FFT data imaginary part from butterfly
    fft_data_rdy_ih           //1->FFT data ready



  );

//----------------------- Global parameters Declarations ------------------
  parameter   P_64B_W           = 64;
  parameter   P_32B_W           = 32;
  parameter   P_16B_W           = 16;

  parameter   P_RAM_RD_LAT      = 2;
  parameter   P_BUTTERFLY_LAT   = 5;

  parameter   P_NO_SAMPLES      = 128;
  localparam  P_NO_SAMPLES_LOG2 = $clog2(P_NO_SAMPLES); //should be 7!
  localparam  P_NO_STAGES       = P_NO_SAMPLES_LOG2;
  localparam  P_SAMPLE_DEPTH    = P_NO_SAMPLES_LOG2;
  localparam  P_PST_VEC_LEN     = 7;  //must be at least 7!!
  localparam  P_PST_VEC_EXTN_LEN= 7;

//----------------------- Input Declarations ------------------------------
  input                       clk_ir;
  input                       rst_il;

  input                       fgyrus_en_ih;
  input   [3:0]               fgyrus_post_norm_id;

  input                       fgyrus_pcm_rdy_ih;

  input   [P_32B_W-1:0]       pcm_ram_rd_data_id;

  input   [P_32B_W-1:0]       fft_ram_rd_real_data_id;
  input   [P_32B_W-1:0]       fft_ram_rd_im_data_id;

  input   [P_16B_W-1:0]       twiddle_ram_real_data_id;
  input   [P_16B_W-1:0]       twiddle_ram_im_data_id;

  input   [P_16B_W-1:0]       cordic_ram_rd_data_id;

  input   [P_32B_W-1:0]       fft_data_real_id;
  input   [P_32B_W-1:0]       fft_data_im_id;
  input                       fft_data_rdy_ih;


//----------------------- Output Declarations -----------------------------
  output                        fgyrus_fft_done_oh;
  output                        fgyrus_pcm_done_oh;
  output                        fgyrus_busy_oh;
  output  [2:0]                 fgyrus_fsm_pstate_od;

  output  [P_SAMPLE_DEPTH-1:0]  pcm_ram_rd_addr_od;

  output  [P_SAMPLE_DEPTH-1:0]  fft_ram_rd_addr_od;
  output                        fft_ram_wr_real_en_oh;
  output                        fft_ram_wr_im_en_oh;
  output  [P_SAMPLE_DEPTH-1:0]  fft_ram_wr_addr_od;
  output  [P_32B_W-1:0]         fft_ram_wr_real_data_od;
  output  [P_32B_W-1:0]         fft_ram_wr_im_data_od;

  output  [P_SAMPLE_DEPTH-1:0]  twiddle_ram_rd_addr_od;

  output  [7:0]               cordic_ram_rd_addr_od;

  output  [P_32B_W-1:0]       sample_a_real_od;
  output  [P_32B_W-1:0]       sample_a_im_od;

  output  [P_32B_W-1:0]       sample_b_real_od;
  output  [P_32B_W-1:0]       sample_b_im_od;

  output  [P_16B_W-1:0]       twdl_factor_real_od;
  output  [P_16B_W-1:0]       twdl_factor_im_od;

  output                      samples_rdy_oh;
  
  output  [P_SAMPLE_DEPTH-1:0]  fft_res_wr_addr_od;
  output  [P_32B_W-1:0]         fft_res_wr_data_od;
  output                        fft_res_wr_en_oh;


//----------------------- Output Register Declaration ---------------------
  reg                           fgyrus_fft_done_oh;
  reg                           fgyrus_pcm_done_oh;
  reg                           fgyrus_busy_oh;

  reg     [P_SAMPLE_DEPTH-1:0]  twiddle_ram_rd_addr_od;

  reg     [7:0]                 cordic_ram_rd_addr_od;

  reg     [P_SAMPLE_DEPTH-1:0]  fft_ram_rd_addr_od;
  reg                           fft_ram_wr_real_en_oh;
  reg                           fft_ram_wr_im_en_oh;
  reg     [P_SAMPLE_DEPTH-1:0]  fft_ram_wr_addr_od;
  reg     [P_32B_W-1:0]         fft_ram_wr_real_data_od;
  reg     [P_32B_W-1:0]         fft_ram_wr_im_data_od;

  reg     [P_32B_W-1:0]       sample_a_real_od;
  reg     [P_32B_W-1:0]       sample_a_im_od;

  reg     [P_32B_W-1:0]       sample_b_real_od;
  reg     [P_32B_W-1:0]       sample_b_im_od;

  reg                         samples_rdy_oh;

  reg     [P_SAMPLE_DEPTH-1:0]  fft_res_wr_addr_od;
  reg     [P_32B_W-1:0]         fft_res_wr_data_od;
  reg                           fft_res_wr_en_oh;

//----------------------- Internal Register Declarations ------------------
  reg     [P_PST_VEC_LEN-1:0]   pst_vec_f;
  reg     [P_PST_VEC_EXTN_LEN-1:0]  pst_vec_extn_f;
  reg     [P_SAMPLE_DEPTH-1:0]  sample_cntr_f;
  reg                           decimate_ovr_f;

  reg     [P_NO_STAGES-1:0]     fft_stage_no_f;
  reg     [P_NO_STAGES-1:0]     sample_offset_f;

  reg     [P_SAMPLE_DEPTH-1:0]  fft_sample_1_f;
  reg     [P_SAMPLE_DEPTH-1:0]  fft_sample_2_f;
  reg     [P_SAMPLE_DEPTH-1:0]  fft_sample_1_1d;
  reg     [P_SAMPLE_DEPTH-1:0]  fft_sample_2_1d;

  reg                           twiddle_ram_inc_en_f;

  reg     [P_32B_W-1:0]         sample_real_inv_f;
  reg     [P_32B_W-1:0]         sample_im_inv_f;
  reg     [P_32B_W-1:0]         sample_real_for_div_f;
  reg     [P_32B_W-1:0]         sample_im_for_div_f;
  reg                           sample_real_is_zero_f;
  reg                           sample_real_is_zero_1d;
  reg                           sample_real_is_zero_2d;
  reg                           sample_real_is_zero_3d;

  reg     [P_32B_W-1:0]         pre_div_real_data_f;
  reg     [P_32B_W-1:0]         abs_val_f /*  synthesis preserve  */;
  reg                           norm_pre_div_data_f;
  reg                           norm_post_div_data_f;
  reg                           norm_post_div_data_1d;

  reg     [P_32B_W-1:0]         div_res_q_f /*  synthesis preserve  */;
  reg                           div_res_rdy_1d;

  reg                           div_load_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                          sample_cntr_max_c;
  wire    [P_SAMPLE_DEPTH-1:0]  sample_cntr_bit_rev_w;

  wire    [P_SAMPLE_DEPTH-1:0]  fft_sample_inc_val_w;
  wire    [P_SAMPLE_DEPTH:0]    fft_sample_val_nxt_c;
  wire                          inc_fft_sample_w;
  wire                          wrap_sample_offset_c;
  wire                          inc_fft_sample_offset_c;
  wire                          inc_fft_stage_no_c;
  wire                          fft_all_stages_ovr_c;

  wire    [P_32B_W-1:0]         div_res_q_w /*  synthesis keep  */;
  wire    [P_32B_W-1:0]         div_res_r_w /*  synthesis keep  */;
  wire                          div_res_rdy_w;
  wire                          div_res_rdy_pulse_c;

  wire                          cordic_ovr_c;
  wire                          abs_ovr_c;

//----------------------- Generate Variable Declarations ------------------
  genvar  i;

//----------------------- FSM Parameters --------------------------------------
//only for FSM state vector representation
parameter     [2:0]                  // synopsys enum fsm_pstate
IDLE_S              = 3'd0,
DECIMATE_S          = 3'd1,
FFT_S               = 3'd2,
FFT_WAIT_S          = 3'd3,
CORDIC_S            = 3'd4,
ABS_S               = 3'd5;

//----------------------- FSM Register Declarations ------------------
reg           [2:0]                            // synthesis syn_encoding = "user"
fsm_pstate, next_state;

//----------------------- FSM String Declarations ------------------
//synthesis translate_off
reg           [8*10:0]      state_name;//"state name" is user defined
//synthesis translate_on

//----------------------- FSM Debugging Logic Declarations ------------------
//synthesis translate_off
always @ (fsm_pstate)
begin
case (fsm_pstate)
IDLE_S      : state_name  = "IDLE_S";
DECIMATE_S  : state_name  = "DECIMATE_S";
FFT_S       : state_name  = "FFT_S";
FFT_WAIT_S  : state_name  = "FFT_WAIT_S";
CORDIC_S    : state_name  = "CORDIC_S";
ABS_S       : state_name  = "ABS_S";
default     : state_name  = "INVALID!";
endcase
end
//synthesis translate_on


//----------------------- Start of Code -----------------------------------

  /*
    * Sequential part of FSM
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fsm_pstate              <=  IDLE_S;

      fgyrus_fft_done_oh      <=  1'b0;
      fgyrus_pcm_done_oh      <=  1'b0;
      fgyrus_busy_oh          <=  1'b0;
    end
    else
    begin
      fsm_pstate              <=  next_state;

      fgyrus_fft_done_oh      <=  (fsm_pstate ==  FFT_S)  ? fft_all_stages_ovr_c  : 1'b0;
      fgyrus_pcm_done_oh      <=  (fsm_pstate ==  ABS_S)  ? abs_ovr_c : 1'b0;
      fgyrus_busy_oh          <=  (fsm_pstate ==  IDLE_S) ? 1'b0      : 1'b1;
    end
  end

  assign  fgyrus_fsm_pstate_od  = fsm_pstate;

  /*
    * Combinational part of FSM
  */
  always@(*)
  begin
    next_state                = fsm_pstate;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if(fgyrus_pcm_rdy_ih  & fgyrus_en_ih)
        begin
          next_state          = DECIMATE_S;
        end
      end

      DECIMATE_S  :
      begin
        if(decimate_ovr_f)
        begin
          next_state          = FFT_S;
        end
      end

      FFT_S :
      begin
        if(fft_all_stages_ovr_c)
        begin
          next_state          = FFT_WAIT_S;
        end
      end

      FFT_WAIT_S  :
      begin
        if(fft_ram_wr_real_en_oh & ~fft_data_rdy_ih) //wait for last write to FFT RAM
        begin
          next_state          = CORDIC_S;
        end
      end

      CORDIC_S  :
      begin
        if(cordic_ovr_c)
        begin
          next_state          = ABS_S;
        end
      end

      ABS_S :
      begin
        if(abs_ovr_c)
        begin
          next_state          = IDLE_S;
        end
      end

    endcase
  end


  /*
    * PST Vector logic - Internal pipeline stage management
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      pst_vec_f               <=  {P_PST_VEC_LEN{1'b0}};
      pst_vec_extn_f          <=  {P_PST_VEC_EXTN_LEN{1'b0}};

      decimate_ovr_f          <=  1'b0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          pst_vec_f           <=  {{(P_PST_VEC_LEN-1){1'b0}},fgyrus_pcm_rdy_ih};
          pst_vec_extn_f      <=  {P_PST_VEC_EXTN_LEN{1'b0}};
        end

        DECIMATE_S  :
        begin
          pst_vec_f[P_PST_VEC_LEN-1:P_RAM_RD_LAT+1] <=  0;

          pst_vec_f[P_RAM_RD_LAT:0] <=  decimate_ovr_f  ? {{P_RAM_RD_LAT-1{1'b0}},1'b1} :
                                                          {pst_vec_f[P_RAM_RD_LAT-1:0],~sample_cntr_max_c};
        end

        FFT_S :
        begin
          pst_vec_f           <=  {pst_vec_f[P_PST_VEC_LEN-2:0],  pst_vec_f[P_PST_VEC_LEN-1]}; //shift register
        end

        FFT_WAIT_S  :
        begin
          if(fft_ram_wr_real_en_oh & ~fft_data_rdy_ih)
          begin
            pst_vec_f           <=  {{(P_PST_VEC_LEN-1){1'b0}},1'b1};
          end
          else
          begin
            pst_vec_f         <=  {pst_vec_f[P_PST_VEC_LEN-2:0],  pst_vec_f[P_PST_VEC_LEN-1]}; //shift register
          end
        end

        CORDIC_S  :
        begin
          if(cordic_ovr_c)
          begin
            pst_vec_f           <=  {{(P_PST_VEC_LEN-1){1'b0}},1'b1};
            pst_vec_extn_f      <=  {P_PST_VEC_EXTN_LEN{1'b0}};
          end
          else
          begin
            pst_vec_f[0]                <=  div_res_rdy_pulse_c;
            pst_vec_f[3:1]              <=  pst_vec_f[2:0];

            pst_vec_f[P_PST_VEC_LEN-1:4]<=  {pst_vec_f[P_PST_VEC_LEN-2:4],div_res_rdy_pulse_c};

            pst_vec_extn_f              <=  {pst_vec_extn_f[P_PST_VEC_EXTN_LEN-2:0],pst_vec_f[P_PST_VEC_LEN-1]};  //shift register
          end
        end


        ABS_S :
        begin
          pst_vec_f           <=  {pst_vec_f[P_PST_VEC_LEN-2:0],div_res_rdy_pulse_c};

          pst_vec_extn_f[1:0] <=  {pst_vec_extn_f[0],div_res_rdy_pulse_c};
        end

      endcase

      decimate_ovr_f          <=  (fsm_pstate ==  DECIMATE_S) ? pst_vec_f[P_RAM_RD_LAT] & ~pst_vec_f[P_RAM_RD_LAT-1]  : 1'b0;
    end
  end

  //Calculate the FFT sample increment value
  assign  fft_sample_inc_val_w  = {fft_stage_no_f[P_NO_STAGES-2:0],1'b0};

  /*
    * Sample Counter logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sample_cntr_f           <=  {P_SAMPLE_DEPTH{1'b0}};
    end
    else
    begin
      case(fsm_pstate)

        DECIMATE_S  :
        begin
          sample_cntr_f       <=  decimate_ovr_f  ? {P_SAMPLE_DEPTH{1'b0}}  :
                                                    sample_cntr_f + 1'b1;
        end

        FFT_S :
        begin
          sample_cntr_f       <=  inc_fft_sample_w  ? fft_sample_val_nxt_c[P_SAMPLE_DEPTH-1:0]  :
                                                      sample_cntr_f;
        end

        default :
        begin
          sample_cntr_f       <=  {P_SAMPLE_DEPTH{1'b0}};
        end

      endcase
    end
  end

  //When to increment sample counter
  assign  inc_fft_sample_w    = pst_vec_f[P_PST_VEC_LEN-1];

  //Generate signal if sample counter has reached max value
  assign  sample_cntr_max_c   = &(sample_cntr_f); //will be asserted high only if all bits are one

  //Calculate next value of fft sample data
  assign  fft_sample_val_nxt_c  = {1'b0,sample_cntr_f}  + {1'b0,fft_sample_inc_val_w};

  //Bit reversed version of sample counter
  generate
    for (i=0; i < P_SAMPLE_DEPTH; i=i+1)
    begin : BIT_REV
      assign  sample_cntr_bit_rev_w[i]  = sample_cntr_f[P_SAMPLE_DEPTH-1-i];
    end
  endgenerate

  //All PCM data are read in bit reversed order
  assign  pcm_ram_rd_addr_od  = sample_cntr_bit_rev_w;


  /*
    * FFT RAM logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fft_ram_rd_addr_od      <=  {P_SAMPLE_DEPTH{1'b0}};
      fft_ram_wr_real_en_oh   <=  1'b0;
      fft_ram_wr_im_en_oh     <=  1'b0;
      fft_ram_wr_addr_od      <=  {P_SAMPLE_DEPTH{1'b1}};
      fft_ram_wr_real_data_od <=  {P_32B_W{1'b0}};
      fft_ram_wr_im_data_od   <=  {P_32B_W{1'b0}};

      fft_sample_1_f          <=  {P_SAMPLE_DEPTH{1'b0}};
      fft_sample_2_f          <=  {P_SAMPLE_DEPTH{1'b0}};
      fft_sample_1_1d         <=  {P_SAMPLE_DEPTH{1'b0}};
      fft_sample_2_1d         <=  {P_SAMPLE_DEPTH{1'b0}};
    end
    else
    begin
      fft_sample_1_f          <=  sample_cntr_f + sample_offset_f;
      fft_sample_2_f          <=  fft_sample_1_f  + fft_stage_no_f;

      fft_sample_1_1d         <=  pst_vec_f[P_PST_VEC_LEN-1]  ? fft_sample_1_f  : fft_sample_1_1d;
      fft_sample_2_1d         <=  pst_vec_f[P_PST_VEC_LEN-1]  ? fft_sample_2_f  : fft_sample_2_1d;

      case(fsm_pstate)

        IDLE_S  :
        begin
          fft_ram_rd_addr_od        <=  {P_SAMPLE_DEPTH{1'b0}};
          fft_ram_wr_real_en_oh     <=  1'b0;
          fft_ram_wr_im_en_oh       <=  1'b0;
          fft_ram_wr_addr_od        <=  {P_SAMPLE_DEPTH{1'b1}}; //will roll over to zero
          fft_ram_wr_real_data_od   <=  {P_32B_W{1'b0}};
          fft_ram_wr_im_data_od     <=  {P_32B_W{1'b0}};
        end

        DECIMATE_S  :
        begin
          fft_ram_wr_real_en_oh     <=  pst_vec_f[P_RAM_RD_LAT];
          fft_ram_wr_im_en_oh       <=  pst_vec_f[P_RAM_RD_LAT];
          fft_ram_wr_addr_od        <=  fft_ram_wr_addr_od  + pst_vec_f[P_RAM_RD_LAT];
          fft_ram_wr_real_data_od   <=  pcm_ram_rd_data_id;
          fft_ram_wr_im_data_od     <=  {P_32B_W{1'b0}};
        end

        FFT_S :
        begin
          fft_ram_rd_addr_od        <=  pst_vec_f[3]  ? fft_sample_2_f  : fft_sample_1_f;

          fft_ram_wr_real_en_oh     <=  fft_data_rdy_ih;
          fft_ram_wr_im_en_oh       <=  fft_data_rdy_ih;
          fft_ram_wr_addr_od        <=  pst_vec_f[5]  ? fft_sample_1_1d : fft_sample_2_1d;
          fft_ram_wr_real_data_od   <=  fft_data_real_id;
          fft_ram_wr_im_data_od     <=  fft_data_im_id;
        end

        FFT_WAIT_S  :
        begin
          fft_ram_rd_addr_od        <=  {P_SAMPLE_DEPTH{1'b0}};
          fft_ram_wr_real_en_oh     <=  fft_data_rdy_ih;
          fft_ram_wr_im_en_oh       <=  fft_data_rdy_ih;

          if(fft_ram_wr_real_en_oh & ~fft_data_rdy_ih)
          begin
            fft_ram_wr_addr_od      <=  {P_SAMPLE_DEPTH{1'b0}};
          end
          else
          begin
            fft_ram_wr_addr_od      <=  pst_vec_f[5]  ? fft_sample_1_1d : fft_sample_2_1d;
          end

          fft_ram_wr_real_data_od   <=  fft_data_real_id;
          fft_ram_wr_im_data_od     <=  fft_data_im_id;
        end

        CORDIC_S  :
        begin
          fft_ram_rd_addr_od        <=  cordic_ovr_c  ? {P_SAMPLE_DEPTH{1'b0}}  : fft_ram_rd_addr_od  + div_res_rdy_pulse_c;

          fft_ram_wr_im_en_oh       <=  pst_vec_extn_f[0];
          fft_ram_wr_addr_od        <=  fft_ram_wr_addr_od  + fft_ram_wr_im_en_oh;
          fft_ram_wr_im_data_od     <=  {{P_16B_W{1'b0}},cordic_ram_rd_data_id};
        end

        ABS_S :
        begin
          fft_ram_rd_addr_od        <=  fft_ram_rd_addr_od  + div_res_rdy_pulse_c;

          fft_ram_wr_real_en_oh     <=  pst_vec_extn_f[1];
          fft_ram_wr_addr_od        <=  fft_ram_wr_addr_od  + fft_ram_wr_real_en_oh;
          fft_ram_wr_real_data_od   <=  abs_val_f;
        end

      endcase
    end
  end


  /*
    * Offset counter logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sample_offset_f         <=  {P_SAMPLE_DEPTH{1'b0}};
    end
    else
    begin
      if(fsm_pstate ==  FFT_S)
      begin
        if(wrap_sample_offset_c)
        begin
          sample_offset_f     <=  {P_SAMPLE_DEPTH{1'b0}};
        end
        else
        begin
          sample_offset_f     <=  sample_offset_f + inc_fft_sample_offset_c;
        end
      end
      else
      begin
        sample_offset_f       <=  {P_SAMPLE_DEPTH{1'b0}};
      end
    end
  end

  //Check when to wrap the value of sample offset
  assign  wrap_sample_offset_c  = (sample_offset_f  ==  fft_stage_no_f);

  //Generate signal to increment sample offset
  assign  inc_fft_sample_offset_c = (fft_sample_val_nxt_c[P_SAMPLE_DEPTH] | fft_stage_no_f[P_NO_STAGES-1]) & pst_vec_f[P_PST_VEC_LEN-1];


  /*
    * FFT Stage no. logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fft_stage_no_f          <=  {{P_NO_STAGES-1{1'b0}},1'b1};
    end
    else
    begin
      if(fsm_pstate ==  FFT_S)
      begin
        fft_stage_no_f        <=  inc_fft_stage_no_c  ? {fft_stage_no_f[P_NO_STAGES-2:0],fft_stage_no_f[P_NO_STAGES-1]}  :
                                                        fft_stage_no_f;
      end
      else
      begin
        fft_stage_no_f        <=  fft_stage_no_f;
      end
    end
  end

  //Generate signal to increment the FFT stage no
  assign  inc_fft_stage_no_c  =   wrap_sample_offset_c;

  //Check if all all FFT stages are over
  assign  fft_all_stages_ovr_c  = inc_fft_stage_no_c  & fft_stage_no_f[P_NO_STAGES-1];


  /*
    * Butterfly interface logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sample_a_real_od        <=  {P_32B_W{1'b0}};
      sample_a_im_od          <=  {P_32B_W{1'b0}};
      sample_b_real_od        <=  {P_32B_W{1'b0}};
      sample_b_im_od          <=  {P_32B_W{1'b0}};
      samples_rdy_oh          <=  1'b0;
    end
    else
    begin
      sample_a_real_od        <=  pst_vec_f[5]  ? fft_ram_rd_real_data_id : sample_a_real_od;
      sample_a_im_od          <=  pst_vec_f[5]  ? fft_ram_rd_im_data_id   : sample_a_im_od;
      sample_b_real_od        <=  pst_vec_f[6]  ? fft_ram_rd_real_data_id : sample_b_real_od;
      sample_b_im_od          <=  pst_vec_f[6]  ? fft_ram_rd_im_data_id   : sample_b_im_od;

      samples_rdy_oh          <=  (fsm_pstate ==  FFT_S)  ? pst_vec_f[6]  : 1'b0;
    end
  end

  //Misc assignments to butterfly
  assign  twdl_factor_real_od =   twiddle_ram_real_data_id;
  assign  twdl_factor_im_od   =   twiddle_ram_im_data_id;


  /*
    * Twiddle Ram address logic - follows the increment pattern of sample
    * offset
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      twiddle_ram_rd_addr_od  <=  {{P_SAMPLE_DEPTH-1{1'b0}},1'b1};  //see twiddle ram mif file for the layout

      twiddle_ram_inc_en_f    <=  1'b0;
    end
    else
    begin
      twiddle_ram_inc_en_f    <=  inc_fft_sample_offset_c;

      if(fsm_pstate ==  FFT_S)
      begin
        twiddle_ram_rd_addr_od  <=  twiddle_ram_rd_addr_od  + twiddle_ram_inc_en_f;
      end
      else
      begin
        twiddle_ram_rd_addr_od  <=  {{P_SAMPLE_DEPTH-1{1'b0}},1'b1};
      end
    end
  end


  /*
    * Preparing data for division
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sample_real_inv_f       <=  {P_32B_W{1'b0}};
      sample_im_inv_f         <=  {P_32B_W{1'b0}};
      sample_real_for_div_f   <=  {P_32B_W{1'b1}};  //denominator should not be zero
      sample_im_for_div_f     <=  {P_32B_W{1'b0}};
      sample_real_is_zero_f   <=  1'b0;
      sample_real_is_zero_1d  <=  1'b0;
      sample_real_is_zero_2d  <=  1'b0;
      sample_real_is_zero_2d  <=  1'b0;

      pre_div_real_data_f     <=  {P_32B_W{1'b0}};
      abs_val_f               <=  {P_32B_W{1'b0}};
      norm_pre_div_data_f     <=  1'b0;
      norm_post_div_data_f    <=  1'b0;
      norm_post_div_data_1d   <=  1'b0;

      div_load_f              <=  1'b0;
    end
    else
    begin
      //Check if the denominator (real) input is zero
      sample_real_is_zero_f   <=  ~(|fft_ram_rd_real_data_id);
      sample_real_is_zero_1d  <=  sample_real_is_zero_f;
      sample_real_is_zero_2d  <=  sample_real_is_zero_1d;
      sample_real_is_zero_3d  <=  sample_real_is_zero_2d;

      //Calculate the negative value of complex data  - 2's compliment
      //In sync with pst_vec_f[2]
      sample_real_inv_f       <=  ~fft_ram_rd_real_data_id  + 1'b1;
      sample_im_inv_f         <=  ~fft_ram_rd_im_data_id    + 1'b1;

      //For ABS_S
      norm_pre_div_data_f     <=  pst_vec_f[4]  & ~(|pre_div_real_data_f[P_32B_W-1:P_16B_W]); //check if upper 16b are zero
      pre_div_real_data_f     <=  norm_pre_div_data_f                 ? {pre_div_real_data_f[P_16B_W-1:0],{P_16B_W{1'b0}}}  :
                                  fft_ram_rd_real_data_id[P_32B_W-1]  ? sample_real_inv_f :
                                                                        fft_ram_rd_real_data_id;
                                                                                                      

      //Only unsigned division is supported
      //Need to pass the +ve value to the division module
      //Division block is shared/common for both CORDIC & ABS stages
      if(fsm_pstate ==  CORDIC_S)
      begin
      //Insync with pst_vec_f[3]
        sample_real_for_div_f <=  fft_ram_rd_real_data_id[P_32B_W-1]  ? sample_real_inv_f : fft_ram_rd_real_data_id;
        sample_im_for_div_f   <=  fft_ram_rd_im_data_id[P_32B_W-1]    ? sample_im_inv_f   : fft_ram_rd_im_data_id;
        div_load_f            <=  pst_vec_f[3];
      end
      else  //ABS_S
      begin
        sample_real_for_div_f <=  fft_ram_rd_im_data_id;    //denominator
        sample_im_for_div_f   <=  pre_div_real_data_f;  //numerator
        div_load_f            <=  pst_vec_f[6];
      end


      //Normalize the final abs value
      if(pst_vec_extn_f[1] ||  (fsm_pstate !=  ABS_S))
      begin
        norm_post_div_data_f  <=  1'b0;
      end
      else if(pst_vec_f[5])
      begin
        norm_post_div_data_f  <=  ~norm_pre_div_data_f;
      end
      else
      begin
        norm_post_div_data_f  <=  norm_post_div_data_f;
      end

      norm_post_div_data_1d   <=  norm_post_div_data_f  & div_res_rdy_pulse_c;

      //Insync with pst_vec_extn_f[0]
      abs_val_f               <=  norm_post_div_data_1d ? {div_res_q_f[P_16B_W-1:0],{P_16B_W{1'b0}}}  :
                                                          div_res_q_f;
    end
  end

  /*
    * Logic for CORDIC RAM read address
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      cordic_ram_rd_addr_od   <=  8'd0;

      div_res_q_f             <=  {P_32B_W{1'b0}};
      div_res_rdy_1d          <=  1'b0;
    end
    else
    begin
      //insync with div_res_rdy_w
      div_res_rdy_1d          <=  div_res_rdy_w;
      div_res_q_f             <=  div_res_q_w;

      //In Sync with pst_vec_f[4]
      cordic_ram_rd_addr_od   <=  ((|div_res_q_f[P_32B_W-1:8])  | sample_real_is_zero_3d) ? 8'hff : //division by zero is infinity
                                                                                            div_res_q_f[7:0];
    end
  end

  //Check for 0->1 transition on div_res_rdy_w
  assign  div_res_rdy_pulse_c = div_res_rdy_w & ~div_res_rdy_1d;

  //Check for last write to FFT ram
  assign  cordic_ovr_c  = (&fft_ram_wr_addr_od) & fft_ram_wr_im_en_oh;
  assign  abs_ovr_c     = (&fft_ram_wr_addr_od) & fft_ram_wr_real_en_oh;


  /*
  * FFT Res RAM interfacing logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fft_res_wr_en_oh        <=  1'b0;
      fft_res_wr_addr_od      <=  {P_SAMPLE_DEPTH{1'b0}};
      fft_res_wr_data_od      <=  {P_32B_W{1'b0}};
    end
    else
    begin
      if(fsm_pstate ==  ABS_S)
      begin
        //Post FFT Normalization logic
        case(fgyrus_post_norm_id)

          4'd0  : /*  No Normalization  */
          begin
            fft_res_wr_data_od    <=  fft_ram_wr_real_data_od;
          end

          4'd1  : /*  1/16  */
          begin
            fft_res_wr_data_od    <=  {4'd0,fft_ram_wr_real_data_od[P_32B_W-1:4]};
          end

          4'd2  : /*  1/128 */
          begin
            fft_res_wr_data_od    <=  {7'd0,fft_ram_wr_real_data_od[P_32B_W-1:7]};
          end

          4'd3  : /*  1/256 */
          begin
            fft_res_wr_data_od    <=  {8'd0,fft_ram_wr_real_data_od[P_32B_W-1:8]};
          end

          4'd4  : /*  1/4096 */
          begin
            fft_res_wr_data_od    <=  {12'd0,fft_ram_wr_real_data_od[P_32B_W-1:12]};
          end

          4'd5  : /*  1/65536 */
          begin
            fft_res_wr_data_od    <=  {16'd0,fft_ram_wr_real_data_od[P_32B_W-1:16]};
          end

          default : /*  No Normalization  */
          begin
            fft_res_wr_data_od    <=  fft_ram_wr_real_data_od;
          end

        endcase

        fft_res_wr_en_oh      <=  fft_ram_wr_real_en_oh;
        fft_res_wr_addr_od    <=  fft_ram_wr_addr_od;
      end
      else
      begin
        fft_res_wr_en_oh      <=  1'b0;
      end
    end
  end

  /*
    * Instantiating division module
  */
 /*
  complex_div       complex_div_inst
  (
    .clk_ir         (clk_ir),
    .rst_il         (rst_il),

    .real_id        (sample_real_for_div_f),
    .im_id          (sample_im_for_div_f),

    .res_q_od       (div_res_q_w),
    .res_r_od       (div_res_r_w)
  );
  */

  divider_rad4    div_rad4_inst
  (
    .clk          (clk_ir),
    .rst          (~rst_il),
    .load         (div_load_f),
    .n            (sample_im_for_div_f),
    .d            (sample_real_for_div_f),
    .q            (div_res_q_w),
    .r            (div_res_r_w),
    .ready        (div_res_rdy_w)
  );

endmodule // fgyrus_fsm
