/*
 * sram.c
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */

#include "sram.h"
#include "alt_types.h"

alt_u16 sram_read16(alt_u32 base, alt_u32 addr){

	IOWR_SRAM_ACC_ADDR_H(base, (addr >> 16) & SRAM_ADDR_H_MSK);
	IOWR_SRAM_ACC_ADDR_L(base, addr & SRAM_ADDR_L_MSK);

	IOWR_SRAM_ACC_CTRL(base, SRAM_MM_RD_EN_MSK);

	return IORD_SRAM_ACC_DATA(base);
}

void	sram_write16(alt_u32 base, alt_u32 addr, alt_u16 data){

	IOWR_SRAM_ACC_ADDR_H(base, (addr >> 16) & SRAM_ADDR_H_MSK);
	IOWR_SRAM_ACC_ADDR_L(base, addr & SRAM_ADDR_L_MSK);

	IOWR_SRAM_ACC_DATA(base, data);

	IOWR_SRAM_ACC_CTRL(base, SRAM_MM_WR_EN_MSK);

	return;
}
