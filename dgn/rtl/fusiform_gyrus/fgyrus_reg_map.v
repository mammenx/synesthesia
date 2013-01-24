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


//Block Code
parameter FGYRUS_REG_CODE           = 4'd0;
parameter FGYRUS_FFT_REAL_RAM_CODE  = 4'd1;
parameter FGYRUS_FFT_IM_RAM_CODE    = 4'd2;
parameter FGYRUS_TWDLE_RAM_CODE     = 4'd3;
parameter FGYRUS_CORDIC_RAM_CODE    = 4'd4;

//REG Addresses
parameter FGYRUS_CONTROL_REG_ADDR   = 8'h00;
parameter FGYRUS_FSM_PSTATE_REG_ADDR= 8'h02;
parameter FGYRUS_STATUS_REG_ADDR    = 8'h04;
parameter FGYRUS_POST_NORM_REG_ADDR = 8'h06;

//FGYRUS Control register bits
parameter FGYRUS_CONTROL_REG_CONTROL_EN     = 8'h01;
