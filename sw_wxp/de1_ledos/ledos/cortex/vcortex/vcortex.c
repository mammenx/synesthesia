/*
 * vcortex.c
 *
 *  Created on: Oct 21, 2012
 *      Author: Gregory
 */
#include "vcortex.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"


void enable_vcortex(alt_u32 base){
	IOWR_VCORTEX_CTRL(base, VCORTEX_CTRL_EN_MSK);
}

void disable_vcortex(alt_u32 base){
	IOWR_VCORTEX_CTRL(base, 0x0);
}

void pwm_paint(alt_u32 base, alt_u16 * bffr){
	alt_u8 i;


	for(i=0; i<VCORTEX_PWM_CHNNLS; i++){
		//alt_printf("[%x] = 0x%x | ",i,(alt_u32)bffr[i]);

		IOWR_32DIRECT(base, VCORTEX_PWM_RAM_BASE + (i<<4), (alt_u32)bffr[i]);
	}

	//alt_printf("\n");
}
