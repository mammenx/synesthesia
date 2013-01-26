/*
 * cortex.c
 *
 *  Created on: Dec 13, 2012
 *      Author: Gregory
 */
#include "cortex.h"
#include "sys/alt_stdio.h"

void cortex_init(alt_32 base, FS_T fs, BPS_T bps){
	acortex_init(base,fs,bps);

	//Fgyrus
	configure_post_norm(CORTEX_MM_SL_BASE, LCHNL, NORM_64k);
	configure_post_norm(CORTEX_MM_SL_BASE, RCHNL, NORM_64k);

	enable_vcortex(base);

	alt_printf("Cortex Init done\r\n");

	return;
}
