/*
 * sram.h
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */
#include <io.h>
#include "alt_types.h"

#ifndef SRAM_H_
#define SRAM_H_

//Sram register addresses
#define SRAM_STATUS_REG_ADDR            0x21000
#define SRAM_ACC_CTRL_REG_ADDR          0x21010
#define SRAM_ACC_ADDR_H_REG_ADDR        0x21020
#define SRAM_ACC_ADDR_L_REG_ADDR        0x21030
#define SRAM_ACC_DATA_REG_ADDR          0x21040

//Sram fields masks
#define	SRAM_FF_EMPTY_MSK				0x1
#define	SRAM_FF_ALMOST_EMPTY_MSK		0x2
#define	SRAM_FF_FULL_MSK				0x4
#define	SRAM_FF_UNDERRUN_MSK			0x8
#define	SRAM_FF_OVERFLOW_MSK			0x16

#define	SRAM_MM_RD_EN_MSK				0x1
#define	SRAM_MM_WR_EN_MSK				0x2

#define	SRAM_ADDR_H_MSK					0x3
#define	SRAM_ADDR_L_MSK					0xffff

#define	SRAM_DATA_MSK					0xffff

//Read SRAM registers
#define	IORD_SRAM_STATUS(base)				\
		IORD_32DIRECT(base, SRAM_STATUS_REG_ADDR)

#define	IORD_SRAM_ACC_CTRL(base)			\
		IORD_32DIRECT(base, SRAM_ACC_CTRL_REG_ADDR)

#define	IORD_SRAM_ACC_ADDR_H(base)			\
		IORD_32DIRECT(base, SRAM_ACC_ADDR_H_REG_ADDR)

#define	IORD_SRAM_ACC_ADDR_L(base)			\
		IORD_32DIRECT(base, SRAM_ACC_ADDR_L_REG_ADDR)

#define	IORD_SRAM_ACC_DATA(base)			\
		IORD_32DIRECT(base, SRAM_ACC_DATA_REG_ADDR)

//Write SRAM registers
#define	IOWR_SRAM_STATUS(base, data)				\
		IOWR_32DIRECT(base, SRAM_STATUS_REG_ADDR, data)

#define	IOWR_SRAM_ACC_CTRL(base, data)			\
		IOWR_32DIRECT(base, SRAM_ACC_CTRL_REG_ADDR, data)

#define	IOWR_SRAM_ACC_ADDR_H(base, data)			\
		IOWR_32DIRECT(base, SRAM_ACC_ADDR_H_REG_ADDR, data)

#define	IOWR_SRAM_ACC_ADDR_L(base, data)			\
		IOWR_32DIRECT(base, SRAM_ACC_ADDR_L_REG_ADDR, data)

#define	IOWR_SRAM_ACC_DATA(base, data)			\
		IOWR_32DIRECT(base, SRAM_ACC_DATA_REG_ADDR, data)


//Utils
alt_u16 sram_read16(alt_u32 base, alt_u32 addr);
void	sram_write16(alt_u32 base, alt_u32 addr, alt_u16 data);

#endif /* SRAM_H_ */
