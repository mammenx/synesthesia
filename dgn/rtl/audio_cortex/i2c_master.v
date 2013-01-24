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
 -- Module Name       : i2c_master
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module drives read-write transactions on an
                        I2C bus.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------

 -- $Header$
 

 -- $Log$

 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module i2c_master
  (
    clk_ir,                   //System clock input
    rst_il,                   //Active low reset

    //I2C interface
    i2c_sda_io,               //SDA
    i2c_scl_od,               //SCL

    //Local Bus interface
    lb_rd_en_ih,              //1->Read enable
    lb_wr_en_ih,              //1->Write enable
    lb_addr_id,               //Address input
    lb_wr_data_id,            //Write Data input
    lb_rd_valid_od,           //1->lb_rd_data_od is valid
    lb_rd_data_od             //Read Data output
 

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

  input                       lb_rd_en_ih;
  input                       lb_wr_en_ih;
  input   [P_LB_ADDR_W-1:0]   lb_addr_id;
  input   [P_LB_DATA_W-1:0]   lb_wr_data_id;


//----------------------- Inout Declarations -----------------------------
  inout                       i2c_sda_io;

//----------------------- Output Declarations -----------------------------
  output                      i2c_scl_od;

  output                      lb_rd_valid_od;
  output  [P_LB_DATA_W-1:0]   lb_rd_data_od;

//----------------------- Output Register Declaration ---------------------
  reg                        i2c_scl_od;

  reg                        lb_rd_valid_od;
  reg    [P_LB_DATA_W-1:0]   lb_rd_data_od;


//----------------------- Internal Register Declarations ------------------
  reg   [P_8B_W-1:0]        addr_f;
  reg   [P_16B_W-1:0]       data_f;
  reg   [P_8B_W-1:0]        clk_div_val_f;

  reg   [P_8B_W-1:0]        i2c_prd_cntr_f;
  reg   [3:0]               bit_idx_f;
  reg                       sdo_f;

  reg                       nack_detected_f;

  genvar  i;

//----------------------- Internal Wire Declarations ----------------------
  wire                      fsm_idle_c;
  wire                      start_i2c_xtn_c;
  wire                      sample_data_c;
  wire  [3:0]               bit_sample_idx_c;

  wire                      wrap_prd_cntr_c;
  wire                      i2c_prd_by_4_tick_c;
  wire                      i2c_prd_by_2_tick_c;

  wire  [P_8B_W-1:0]        addr_rev_w;
  wire  [P_8B_W-1:0]        data_h_rev_w;
  wire  [P_8B_W-1:0]        data_l_rev_w;

//----------------------- FSM Parameters --------------------------------------
//only for FSM state vector representation
parameter     [2:0]                  // synopsys enum fsm_pstate
IDLE_S             = 3'd0,
START_S            = 3'd1,
ADDR_S             = 3'd2,
DATA_0_S           = 3'd3,
DATA_1_S           = 3'd4,
STOP_S             = 3'd5;

//----------------------- FSM Register Declarations ------------------
reg           [2:0]                            // synthesis syn_encoding = "user"
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

IDLE_S        : state_name = "IDLE";

START_S       : state_name = "START";
ADDR_S        : state_name = "ADDR";
DATA_0_S      : state_name = "DATA_0";
DATA_1_S      : state_name = "DATA_1";
STOP_S        : state_name = "STOP";


default       : state_name = "INVALID STATE";
endcase
end
//synthesis translate_on

//----------------------- Start of Code -----------------------------------

  /*
    * Local bus decoding logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      lb_rd_valid_od          <=  1'b0;
      lb_rd_data_od           <=  {P_LB_DATA_W{1'b0}};

      addr_f                  <=  {P_8B_W{1'b0}};
      data_f                  <=  {P_16B_W{1'b0}};
      clk_div_val_f           <=  {P_8B_W{1'b0}};
    end
    else
    begin
      lb_rd_valid_od          <=  lb_rd_en_ih;

      case(lb_addr_id)

        I2C_DRIVER_STATUS_REG_ADDR  :
        begin
          lb_rd_data_od       <=  {{P_16B_W-2{1'b0}},nack_detected_f,~fsm_idle_c};
        end

        I2C_DRIVER_ADDR_REG_ADDR  :
        begin
          lb_rd_data_od       <=  {{P_8B_W{1'b0}},addr_f};
        end

        I2C_DRIVER_DATA_REG_ADDR  :
        begin
          lb_rd_data_od       <=  data_f;
        end

        I2C_DRIVER_CLK_DIV_REG_ADDR :
        begin
          lb_rd_data_od       <=  {{P_8B_W{1'b0}},clk_div_val_f};
        end

        default :
        begin
          lb_rd_data_od       <=  16'hdead;
        end

      endcase


      if(lb_wr_en_ih)
      begin
        addr_f                <=  (lb_addr_id ==  I2C_DRIVER_ADDR_REG_ADDR) ? lb_wr_data_id[P_8B_W-1:0] : addr_f;

        data_f                <=  (lb_addr_id ==  I2C_DRIVER_DATA_REG_ADDR) ? lb_wr_data_id : data_f;

        clk_div_val_f         <=  (lb_addr_id ==  I2C_DRIVER_CLK_DIV_REG_ADDR)  ? lb_wr_data_id[P_8B_W-1:0] : clk_div_val_f;
      end
      else
      begin
        addr_f                <=  addr_f;
        data_f[P_8B_W-1 - bit_sample_idx_c] <=  sample_data_c ? i2c_sda_io  : data_f[P_8B_W-1 - bit_sample_idx_c];
        clk_div_val_f         <=  clk_div_val_f;
      end
    end
  end


  //Logic for triggering I2C xtn, on write to I2C_DRIVER_STATUS_REG
  assign  start_i2c_xtn_c     = (lb_addr_id ==  I2C_DRIVER_STATUS_REG_ADDR) ? lb_wr_en_ih : 1'b0;

  //bit reverse the address
  generate
    for(i=0;i<P_8B_W;i=i+1)
    begin : addr_rev
      assign  addr_rev_w[i]   = addr_f[P_8B_W-1-i];

      assign  data_h_rev_w[i] = data_f[P_16B_W-1-i];

      assign  data_l_rev_w[i] = data_f[P_8B_W-1-i];
    end
  endgenerate


  /*
    * FSM Logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      fsm_pstate              <=  IDLE_S;
    end
    else
    begin
      fsm_pstate              <=  next_state;
    end
  end

  always@(*)
  begin
    next_state                = fsm_pstate;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if(start_i2c_xtn_c)
        begin
          next_state          = START_S;
        end
      end

      START_S :
      begin
        if(wrap_prd_cntr_c)
        begin
          next_state          = ADDR_S;
        end
      end

      ADDR_S  :
      begin
        if(bit_idx_f[3] & wrap_prd_cntr_c)
        begin
          if(nack_detected_f)
          begin
            next_state        = STOP_S;
          end
          else
          begin
            next_state        = DATA_0_S;
          end
        end
      end

      DATA_0_S  :
      begin
        if(bit_idx_f[3] & wrap_prd_cntr_c)
        begin
          if(nack_detected_f)
          begin
            next_state        = STOP_S;
          end
          else
          begin
            next_state        = DATA_1_S;
          end
        end
      end

      DATA_1_S  :
      begin
        if(bit_idx_f[3] & wrap_prd_cntr_c)
        begin
          next_state          = STOP_S;
        end
      end

      STOP_S  :
      begin
        if(wrap_prd_cntr_c)
        begin
          next_state          = IDLE_S;
        end
      end

    endcase
  end

  assign  fsm_idle_c          = (fsm_pstate ==  IDLE_S) ? 1'b1  : 1'b0;


  /*
    * I2C period counter logic
    * This counter will derive the required I2C period
    *
    * Bit counter is used indexing the addr/data bits
    *
    * Flag to hold nack detected status
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      i2c_prd_cntr_f          <=  {P_8B_W{1'b0}};
      bit_idx_f               <=  4'd0;

      nack_detected_f         <=  1'b0;
    end
    else
    begin
      i2c_prd_cntr_f          <=  (fsm_idle_c | wrap_prd_cntr_c)  ? {P_8B_W{1'b0}}
                                                                  : i2c_prd_cntr_f  + 1'b1;

      if((fsm_pstate == ADDR_S) | (fsm_pstate ==  DATA_0_S) | (fsm_pstate ==  DATA_1_S))
      begin
        bit_idx_f             <=  (bit_idx_f[3] & wrap_prd_cntr_c)  ? 4'd0
                                                                    : bit_idx_f + wrap_prd_cntr_c;
      end
      else
      begin
        bit_idx_f             <=  4'd0;
      end

      //Slave must pull down SDO pin low during ack phase for
      //correct ack, else nack
      nack_detected_f       <=  nack_detected_f ? ~start_i2c_xtn_c  //clear NACK flag
                                                : bit_idx_f[3]  & i2c_scl_od  & i2c_prd_by_2_tick_c & i2c_sda_io;
    end
  end

  //Counter wrap logic
  assign  wrap_prd_cntr_c     = (i2c_prd_cntr_f ==  clk_div_val_f)  ? 1'b1  : 1'b0;

  //Generate a tick 4 times every I2C cycle
  assign  i2c_prd_by_4_tick_c = (i2c_prd_cntr_f[P_8B_W-3:0] ==  clk_div_val_f[P_8B_W-1:2])  ? 1'b1  : 1'b0;

  //Generate a tick 2 times every I2C cycle
  assign  i2c_prd_by_2_tick_c = (i2c_prd_cntr_f[P_8B_W-2:0] ==  clk_div_val_f[P_8B_W-1:1])  ? 1'b1  : 1'b0;

  /*
    * SDO, SCL logic
  */
  always@(posedge clk_ir, negedge rst_il)
  begin
    if(~rst_il)
    begin
      sdo_f                   <=  1'b1;
      i2c_scl_od              <=  1'b1;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          sdo_f               <=  1'b1;
          i2c_scl_od          <=  1'b1;
        end

        START_S :
        begin
          sdo_f               <=  1'b0;
          i2c_scl_od          <=  i2c_scl_od  & ~i2c_prd_by_2_tick_c;
        end

        ADDR_S  :
        begin
          sdo_f               <=  ~bit_idx_f[3] & addr_rev_w[bit_idx_f[2:0]];
          i2c_scl_od          <=  i2c_scl_od  ? i2c_prd_by_2_tick_c | ~i2c_prd_by_4_tick_c
                                              : i2c_prd_by_4_tick_c;
        end

        DATA_0_S  :
        begin
          sdo_f               <=  ~bit_idx_f[3] & data_h_rev_w[bit_idx_f[2:0]];
          i2c_scl_od          <=  i2c_scl_od  ? i2c_prd_by_2_tick_c | ~i2c_prd_by_4_tick_c
                                              : i2c_prd_by_4_tick_c;
        end

        DATA_1_S  :
        begin
          sdo_f               <=  ~bit_idx_f[3] & data_l_rev_w[bit_idx_f[2:0]];
          i2c_scl_od          <=  i2c_scl_od  ? i2c_prd_by_2_tick_c | ~i2c_prd_by_4_tick_c
                                              : i2c_prd_by_4_tick_c;
        end

        STOP_S  :
        begin
          sdo_f               <=  sdo_f | i2c_prd_by_2_tick_c;
          i2c_scl_od          <=  1'b1;
        end

      endcase
    end
  end

  //Generate data sampling signal for read operations
  assign  sample_data_c       = addr_f[0] & ((fsm_pstate == DATA_0_S) | (fsm_pstate ==  DATA_1_S))  &
                                i2c_prd_by_2_tick_c & i2c_scl_od;

  //Bit sample index
  assign  bit_sample_idx_c[3] = (fsm_pstate ==  DATA_0_S) ? 1'b1  : 1'b0;
  assign  bit_sample_idx_c[2:0] = bit_idx_f[2:0];


  //SDA Bus Trisatate logic
  assign  i2c_sda_io          = bit_idx_f[3]  ? 1'bz  : sdo_f;

endmodule // i2c_master
