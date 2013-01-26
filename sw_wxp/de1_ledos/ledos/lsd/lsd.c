/*
 * lsd.c
 *
 *  Created on: Dec 28, 2012
 *      Author: Gregory
 */

#include "lsd.h"
#include <stdio.h>
#include "../cortex/cortex.h"

static void acid_sunshine(int argc, alt_u32 *lfft_bffr, alt_u32 *rfft_bffr, alt_u16 *pwm_bffr){
	alt_u8	i;

	for(i=0; i<VCORTEX_PWM_CHNNLS; i++){
		//pwm_bffr[i]	=	(alt_u16)(lfft_bffr[i]	>>	16);
		//pwm_bffr[i]	=	pwm_bffr[i]	<<	12;

		pwm_bffr[i]	=	(alt_u16)(lfft_bffr[i]	<<	14);
	}

	return;
}

static const Acid acid_box[]	=	{
		{"sunshine",acid_sunshine},
		{NULL, NULL}
};

Acid * get_acid_box(void){
	return (Acid *)(acid_box);
}
