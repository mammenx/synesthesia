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
#include "io.h"
#include "sys/alt_errno.h"
#include "sys/alt_cache.h"

#include "altera_avalon_fifo.h"
#include "altera_avalon_fifo_util.h"



int altera_avalon_fifo_init(alt_u32 address, alt_u32 ienable,
                            alt_u32 emptymark, alt_u32 fullmark)
{
    if(altera_avalon_fifo_clear_event(address, ALTERA_AVALON_FIFO_EVENT_ALL) != ALTERA_AVALON_FIFO_OK)
    {
        return ALTERA_AVALON_FIFO_EVENT_CLEAR_ERROR;
    }

    if( altera_avalon_fifo_write_ienable(address, ienable) != ALTERA_AVALON_FIFO_OK)
    {
         return ALTERA_AVALON_FIFO_IENABLE_WRITE_ERROR;
    }

    if( altera_avalon_fifo_write_almostfull(address, fullmark) != ALTERA_AVALON_FIFO_OK)
    {
        return ALTERA_AVALON_FIFO_THRESHOLD_WRITE_ERROR;
    }
  
    if( altera_avalon_fifo_write_almostempty(address, emptymark) != ALTERA_AVALON_FIFO_OK)
    {
        return ALTERA_AVALON_FIFO_THRESHOLD_WRITE_ERROR;
    }

    return ALTERA_AVALON_FIFO_OK;
}

int altera_avalon_fifo_read_status(alt_u32 address, alt_u32 mask)
{
    return (IORD_ALTERA_AVALON_FIFO_STATUS(address) & mask);
}

int altera_avalon_fifo_read_ienable(alt_u32 address, alt_u32 mask)
{
	
    return (IORD_ALTERA_AVALON_FIFO_IENABLE(address) & mask);
}

int altera_avalon_fifo_read_almostfull(alt_u32 address)
{
    return IORD_ALTERA_AVALON_FIFO_ALMOSTFULL(address);
}

int altera_avalon_fifo_read_almostempty(alt_u32 address)
{
    return IORD_ALTERA_AVALON_FIFO_ALMOSTEMPTY(address);
}

int altera_avalon_fifo_read_event(alt_u32 address, alt_u32 mask)
{
    return (IORD_ALTERA_AVALON_FIFO_EVENT(address) & mask);
}

int altera_avalon_fifo_read_level(alt_u32 address)
{
    return IORD_ALTERA_AVALON_FIFO_LEVEL(address);
}

int altera_avalon_fifo_clear_event(alt_u32 address, alt_u32 mask)
{
    IOWR_ALTERA_AVALON_FIFO_EVENT(address, mask);
    if((IORD_ALTERA_AVALON_FIFO_EVENT(address) & mask) == 0)
        return ALTERA_AVALON_FIFO_OK;
    else
    return ALTERA_AVALON_FIFO_EVENT_CLEAR_ERROR;
}

int altera_avalon_fifo_write_ienable(alt_u32 address, alt_u32 mask)
{
    IOWR_ALTERA_AVALON_FIFO_IENABLE(address, mask);
    if(IORD_ALTERA_AVALON_FIFO_IENABLE(address) == mask)
        return ALTERA_AVALON_FIFO_OK;
    else
        return ALTERA_AVALON_FIFO_IENABLE_WRITE_ERROR;
}

int altera_avalon_fifo_write_almostfull(alt_u32 address, alt_u32 data)
{
    IOWR_ALTERA_AVALON_FIFO_ALMOSTFULL(address, data);
    if(IORD_ALTERA_AVALON_FIFO_ALMOSTFULL(address) == data)
        return ALTERA_AVALON_FIFO_OK;
    else
        return ALTERA_AVALON_FIFO_THRESHOLD_WRITE_ERROR;
}

int altera_avalon_fifo_write_almostempty(alt_u32 address, alt_u32 data)
{
    IOWR_ALTERA_AVALON_FIFO_ALMOSTEMPTY(address, data);
    if(IORD_ALTERA_AVALON_FIFO_ALMOSTEMPTY(address) == data)
        return ALTERA_AVALON_FIFO_OK;
    else
        return ALTERA_AVALON_FIFO_THRESHOLD_WRITE_ERROR;
}

int altera_avalon_fifo_write_fifo(alt_u32 write_address,
                                  alt_u32 ctrl_address,
                                  alt_u32 data)
{
    if(!altera_avalon_fifo_read_status(ctrl_address, ALTERA_AVALON_FIFO_STATUS_F_MSK))
    {
        IOWR_ALTERA_AVALON_FIFO_DATA(write_address, data);
        return ALTERA_AVALON_FIFO_OK;
    }
    else
    {
        return ALTERA_AVALON_FIFO_FULL;
    }
}

int altera_avalon_read_fifo(alt_u32 read_address, alt_u32 ctrl_address, int *data)
{
    int return_val = 0;
    *data = 0;
    
    if(!altera_avalon_fifo_read_status(ctrl_address, ALTERA_AVALON_FIFO_STATUS_E_MSK))
    {
        return_val = altera_avalon_fifo_read_level(ctrl_address);
        *data = IORD_ALTERA_AVALON_FIFO_DATA(read_address);
    
    }
    return return_val;
}

int altera_avalon_fifo_read_fifo(alt_u32 read_address, alt_u32 ctrl_address)
{
    if(!altera_avalon_fifo_read_status(ctrl_address, ALTERA_AVALON_FIFO_STATUS_E_MSK))
    {
        return IORD_ALTERA_AVALON_FIFO_DATA(read_address);
    }
    return 0;
}

int altera_avalon_fifo_write_other_info(alt_u32 write_address,
					alt_u32 ctrl_address,
					alt_u32 data)
{
    if(!altera_avalon_fifo_read_status(ctrl_address, ALTERA_AVALON_FIFO_STATUS_F_MSK))
    {
	IOWR_ALTERA_AVALON_FIFO_OTHER_INFO(write_address, data);
	return ALTERA_AVALON_FIFO_OK;
    }
    else
    {
	return ALTERA_AVALON_FIFO_FULL;
    }
}

int altera_avalon_fifo_read_other_info(alt_u32 read_address)
{
    return IORD_ALTERA_AVALON_FIFO_OTHER_INFO(read_address);
}

int altera_avalon_fifo_read_backpressure (alt_u32 read_address){
    // Read data from FIFO directly. If FIFO is empty and backpressure is supported, this call is backpressure.
    return IORD_ALTERA_AVALON_FIFO_DATA(read_address);  
}
