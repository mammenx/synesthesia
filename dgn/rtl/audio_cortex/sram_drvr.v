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



/*****************************************************************************
 *                                                                           *
 * Module:       sram_drvr                                                   *
 * Description:                                                              *
 *      This module chipselects reads and writes to the sram, with 2-cycle   *
 *  read latency and one cycle write latency.                                *
 *                                                                           *
 *****************************************************************************/


module sram_drvr (
 // Inputs
 clk,
 reset,

 address,
 byteenable,
 chipselect,
 read,
 write,
 writedata,

 // Bi-Directional
 SRAM_DQ,

 // Outputs
 SRAM_ADDR,
 SRAM_LB_N,
 SRAM_UB_N,
 SRAM_CE_N,
 SRAM_OE_N,
 SRAM_WE_N,
 
 readdata
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input    clk;
input    reset;

input  [17:0] address;
input  [1:0] byteenable;
input    chipselect;
input    read;
input    write;
input  [15:0] writedata;

// Bi-Directional
inout  [15:0] SRAM_DQ;  // SRAM Data bus 16 Bits

// Outputs
output reg [17:0] SRAM_ADDR;  // SRAM Address bus 18 Bits
output reg   SRAM_LB_N;  // SRAM Low-byte Data Mask 
output reg   SRAM_UB_N;  // SRAM High-byte Data Mask 
output reg   SRAM_CE_N;  // SRAM Chip chipselect
output reg   SRAM_OE_N;  // SRAM Output chipselect
output reg   SRAM_WE_N;  // SRAM Write chipselect

output reg [15:0] readdata;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires

// Internal Registers
reg   [15:0] writedata_reg;

// State Machine Registers

/*****************************************************************************
 *                            Output assignments                             *
 *****************************************************************************/

assign SRAM_DQ  = ((~SRAM_WE_N) ? writedata_reg : 16'hzzzz);

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/

always @(posedge clk)
begin
 if (reset == 1'b0)
 begin
  readdata  <= 16'h0000;
  writedata_reg <= 16'h0000;

  SRAM_ADDR  <= 18'h00000;
  SRAM_LB_N  <= 1'b1;
  SRAM_UB_N  <= 1'b1;
  SRAM_CE_N  <= 1'b1;
  SRAM_OE_N  <= 1'b1;
  SRAM_WE_N  <= 1'b1;
 end
 else
 begin
  readdata  <= SRAM_OE_N  ? readdata  : SRAM_DQ;
  writedata_reg <= writedata;

  SRAM_ADDR  <= address;
  SRAM_LB_N  <= ~(byteenable[0] & chipselect);
  SRAM_UB_N  <= ~(byteenable[1] & chipselect);
  SRAM_CE_N  <= ~(chipselect);
  SRAM_OE_N  <= ~(read & chipselect);
  SRAM_WE_N  <= ~(write & chipselect);
 end
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

