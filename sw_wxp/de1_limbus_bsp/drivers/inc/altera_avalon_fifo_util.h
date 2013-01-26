/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/
#ifndef __ALT_FIFO_UTIL_H__
#define __ALT_FIFO_UTIL_H__

#include "altera_avalon_fifo_regs.h"

#define ALTERA_AVALON_FIFO_TYPE (volatile alt_u32*)

int altera_avalon_fifo_init(alt_u32 address, alt_u32 ienable, 
  alt_u32 emptymark, alt_u32 fullmark);

int altera_avalon_fifo_read_status(alt_u32 address, alt_u32 mask);
int altera_avalon_fifo_read_ienable(alt_u32 address, alt_u32 mask);
int altera_avalon_fifo_read_almostfull(alt_u32 address);
int altera_avalon_fifo_read_almostempty(alt_u32 address);
int altera_avalon_fifo_read_event(alt_u32 address, alt_u32 mask);
int altera_avalon_fifo_read_level(alt_u32 address);

int altera_avalon_fifo_clear_event(alt_u32 address, alt_u32 mask);
int altera_avalon_fifo_write_ienable(alt_u32 address, alt_u32 mask);
int altera_avalon_fifo_write_almostfull(alt_u32 address, alt_u32 data);
int altera_avalon_fifo_write_almostempty(alt_u32 address, alt_u32 data);

int altera_avalon_fifo_write_fifo(alt_u32 write_address, alt_u32 ctrl_address,
    alt_u32 data);
int altera_avalon_fifo_write_other_info(alt_u32 write_address, alt_u32 ctrl_address,
    alt_u32 data);

int altera_avalon_read_fifo(alt_u32 read_address, alt_u32 ctrl_address, int *data);
int altera_avalon_fifo_read_fifo(alt_u32 read_address, alt_u32 ctrl_address);
int altera_avalon_fifo_read_other_info(alt_u32 read_address);
int altera_avalon_fifo_read_backpressure (alt_u32 read_address);

//Return Codes
#define ALTERA_AVALON_FIFO_OK 0
#define ALTERA_AVALON_FIFO_EVENT_CLEAR_ERROR -1
#define ALTERA_AVALON_FIFO_IENABLE_WRITE_ERROR -2
#define ALTERA_AVALON_FIFO_THRESHOLD_WRITE_ERROR    -3
#define ALTERA_AVALON_FIFO_FULL -4

#endif /* __ALT_FIFO_UTIL_H__ */
