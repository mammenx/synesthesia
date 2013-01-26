/*
 * vcortex.h
 *
 *  Created on: Oct 21, 2012
 *      Author: Gregory
 */
#include <io.h>
#include "alt_types.h"

#ifndef VCORTEX_H_
#define VCORTEX_H_

//VCORTEX Register addresses
#define	VCORTEX_CONTROL_REG_ADDR		0x30000

//VCORTEX Memory base addresses
#define	VCORTEX_PWM_RAM_BASE			0x31000

#define	VCORTEX_PWM_CHNNLS				16

//Field Masks
#define	VCORTEX_CTRL_EN_MSK				0x1

//Read VCORTEX Registers
#define	IORD_VCORTEX_CTRL(base)				\
		IORD_32DIRECT(base, VCORTEX_CONTROL_REG_ADDR)

//Write VCORTEX Registers
#define	IOWR_VCORTEX_CTRL(base, data)				\
		IOWR_32DIRECT(base, VCORTEX_CONTROL_REG_ADDR, data)

//Utils
void enable_vcortex(alt_u32 base);
void disable_vcortex(alt_u32 base);
void pwm_paint(alt_u32 base, alt_u16 * bffr);	//16b x 16 channels buffer

#endif /* VCORTEX_H_ */
