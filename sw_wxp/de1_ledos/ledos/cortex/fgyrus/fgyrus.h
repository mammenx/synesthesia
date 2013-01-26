/*
 * fgyrus.h
 *
 *  Created on: Oct 21, 2012
 *      Author: Gregory
 */
#include <io.h>
#include "alt_types.h"

#ifndef FGYRUS_H_
#define FGYRUS_H_

//FGYRUS Block Codes
#define	FGYRUS_LCHNL_BLK_CODE		0x00000
#define	FGYRUS_RCHNL_BLK_CODE		0x10000

//FGYRUS Register addresses
#define	FGYRUS_CONTROL_REG_ADDR		0x00000
#define	FGYRUS_FSM_PSTATE_REG_ADDR	0x00020
#define	FGYRUS_STATUS_REG_ADDR		0x00040
#define	FGYRUS_POST_NORM_REG_ADDR	0x00060

//FGYRUS Memory base addresses
#define	FGYRUS_FFT_REAL_RAM_BASE	0x01000
#define	FGYRUS_FFT_IM_RAM_BASE		0x02000
#define	FGYRUS_TWDLE_RAM_BASE		0x03000
#define	FGYRUS_CORDIC_RAM_BASE		0x04000

//Field Masks
#define	FGYRUS_EN_MSK				0x1
#define	FGYRUS_FSM_PSTATE_MSK		0x7
#define	FGYRUS_BUSY_MSK				0x1

//Read FGYRUS Registers
#define	IORD_FGYRUS_CTRL(base, fg)				\
		IORD_32DIRECT(base, get_full_fgyrus_addr(fg, FGYRUS_CONTROL_REG_ADDR))

#define	IORD_FGYRUS_FSM_PSTATE(base, fg)				\
		IORD_32DIRECT(base, get_full_fgyrus_addr(fg, FGYRUS_FSM_PSTATE_REG_ADDR))

#define	IORD_FGYRUS_STATUS(base, fg)				\
		IORD_32DIRECT(base, get_full_fgyrus_addr(fg, FGYRUS_STATUS_REG_ADDR))

#define	IORD_FGYRUS_POST_NORM(base, fg)				\
		IORD_32DIRECT(base, get_full_fgyrus_addr(fg, FGYRUS_POST_NORM_REG_ADDR))


//Write FGYRUS Registers
#define	IOWR_FGYRUS_CTRL(base, fg, data)				\
		IOWR_32DIRECT(base, get_full_fgyrus_addr(fg, FGYRUS_CONTROL_REG_ADDR), data)

#define	IOWR_FGYRUS_POST_NORM(base, fg, data)				\
		IOWR_32DIRECT(base, get_full_fgyrus_addr(fg, FGYRUS_POST_NORM_REG_ADDR), data)

//Utils
typedef	enum	{
	LCHNL	=	0,	//Left Channel FGYRUS
	RCHNL	=	1	//Right Channel FGYRUS
}FGYRUS_TYPE;

typedef	enum	{
	IDLE	=	0,
	DECIMATE,
	FFT,
	FFT_WAIT,
	CORDIC,
	ABS
}FGYRUS_STATUS_TYPE;

typedef	enum	{
	NORM_OFF	=	0x0,
	NORM_16		=	0x1,	//Divide by 16
	NORM_128	=	0x2,	//Divide by 128
	NORM_256	=	0x3,	//Divide by 256
	NORM_4k		=	0x4,	//Divide by 4096
	NORM_64k	=	0x5,	//Divide by 65536

}FGYRUS_POST_NORM_TYPE;

alt_u32				get_full_fgyrus_addr(FGYRUS_TYPE fg, alt_u32 addr);
FGYRUS_STATUS_TYPE	get_fgyrus_status(alt_u32 base, FGYRUS_TYPE fg);
FGYRUS_STATUS_TYPE	get_fgyrus_fsm_pstate(alt_u32 base, FGYRUS_TYPE fg);
void				enable_fgyrus(alt_u32 base, FGYRUS_TYPE fg);
void				disable_fgyrus(alt_u32 base, FGYRUS_TYPE fg);
void				configure_post_norm(alt_u32 base, FGYRUS_TYPE fg, FGYRUS_POST_NORM_TYPE val);

#endif /* FGYRUS_H_ */
