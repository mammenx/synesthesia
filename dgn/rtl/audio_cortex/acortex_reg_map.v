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




//    `ifndef __SYN_ACORTEX_REG_MAP
//    `define __SYN_ACORTEX_REG_MAP


//Block Code
parameter I2C_DRIVER                = 4'd0;
parameter SRAM                      = 4'd1;
parameter WAV_PRSR                  = 4'd2;
parameter DAC_DRVR                  = 4'd3;
parameter ADC_LCAPTURE_RAM          = 4'd4;
parameter ADC_RCAPTURE_RAM          = 4'd5;
parameter ADC_START_CAPTURE         = 4'd6;
parameter ACORTEX_AUDIO_SRC_SEL_REG = 4'd7;
parameter RESET                     = 4'd8;

//I2C_DRIVER REG Addresses
parameter I2C_DRIVER_STATUS_REG_ADDR        = 8'h00;
parameter I2C_DRIVER_ADDR_REG_ADDR          = 8'h01;
parameter I2C_DRIVER_DATA_REG_ADDR          = 8'h02;
parameter I2C_DRIVER_CLK_DIV_REG_ADDR       = 8'h03;

//SRAM REG Addresses
parameter SRAM_STATUS_REG_ADDR              = 8'h00;
parameter SRAM_ACC_CTRL_REG_ADDR            = 8'h01;
parameter SRAM_ACC_ADDR_H_REG_ADDR          = 8'h02;
parameter SRAM_ACC_ADDR_L_REG_ADDR          = 8'h03;
parameter SRAM_ACC_DATA_REG_ADDR            = 8'h04;

//WAV PRSR REG Addresses
parameter PRSR_CTRL_REG_ADDR                = 8'h00;
parameter PRSR_FSM_PSTATE_REG_ADDR          = 8'h01;
parameter PRSR_BYTES_READ_H_REG_ADDR        = 8'h02;
parameter PRSR_BYTES_READ_L_REG_ADDR        = 8'h03;
parameter PRSR_HDR_RAM_RD_ADDR_REG_ADDR     = 8'h04;
parameter PRSR_HDR_RAM_RD_DATA_REG_ADDR     = 8'h05;

//WM DAC DRVR REG Addresses
parameter DAC_DRVR_CTRL_REG_ADDR            = 8'h00;
parameter DAC_DRVR_STATUS_REG_ADDR          = 8'h01;
parameter DAC_DRVR_FS_DIV_REG_ADDR          = 8'h02;
parameter DAC_DRVR_MCLK_SEL_REG_ADDR        = 8'h03;

//    `endif
