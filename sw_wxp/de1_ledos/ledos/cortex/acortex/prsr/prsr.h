/*
 * prsr.h
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */
#include <io.h>
#include "alt_types.h"
#include "ch.h"

#ifndef PRSR_H_
#define PRSR_H_

//Parser Register addresses
#define PRSR_CTRL_REG_ADDR              0x22000
#define PRSR_FSM_PSTATE_REG_ADDR        0x22010
#define PRSR_BYTES_READ_H_REG_ADDR      0x22020
#define PRSR_BYTES_READ_L_REG_ADDR      0x22030
#define PRSR_HDR_RAM_RD_ADDR_REG_ADDR   0x22040
#define PRSR_HDR_RAM_RD_DATA_REG_ADDR   0x22050

//Parser Fields Masks
#define	PRSR_EN_MSK						0x1
#define	PRSR_FSM_PSTATE_MSK				0x3f
#define	PRSR_HDR_RAM_RD_ADDR_MSK		0xff
#define	PRSR_HDR_RAM_RD_DATA_MSK		0xffff

//Read parser registers
#define	IORD_PRSR_CTRL(base)				\
		IORD_32DIRECT(base, PRSR_CTRL_REG_ADDR)

#define	IORD_PRSR_FSM_PSTATE(base)				\
		IORD_32DIRECT(base, PRSR_FSM_PSTATE_REG_ADDR)

#define	IORD_PRSR_BYTES_READ_H(base)				\
		IORD_32DIRECT(base, PRSR_BYTES_READ_H_REG_ADDR)

#define	IORD_PRSR_BYTES_READ_L(base)				\
		IORD_32DIRECT(base, PRSR_BYTES_READ_L_REG_ADDR)

#define	IORD_PRSR_HDR_RAM_RD_ADDR(base)				\
		IORD_32DIRECT(base, PRSR_HDR_RAM_RD_ADDR_REG_ADDR)

#define	IORD_PRSR_HDR_RAM_RD_DATA(base)				\
		IORD_32DIRECT(base, PRSR_HDR_RAM_RD_DATA_REG_ADDR)

//Write Parser registers
#define	IOWR_PRSR_CTRL(base, data)				\
		IOWR_32DIRECT(base, PRSR_CTRL_REG_ADDR, data)

#define	IOWR_PRSR_HDR_RAM_RD_ADDR(base, data)				\
		IOWR_32DIRECT(base, PRSR_HDR_RAM_RD_ADDR_REG_ADDR, data)

//Utils
void	prsr_enable(alt_u32 base);
void	prsr_disable(alt_u32 base);
alt_u16 prsr_hdr_ram_read16(alt_u32 base, alt_u8 addr);
void	get_wav_hdr_frm_prsr(alt_u32 base, alt_u16 *bffr);	//Note that buffer must be
															//at least 46 bytes i.e. 23 words
alt_u32	prsr_get_bytes_read(alt_u32 base);

#endif /* PRSR_H_ */
