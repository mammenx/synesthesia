/*
 * prsr.c
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */
#include "prsr.h"
#include "alt_types.h"

void	prsr_enable(alt_u32 base){
	IOWR_PRSR_CTRL(base, PRSR_EN_MSK);
	return;
}

void	prsr_disable(alt_u32 base){
	IOWR_PRSR_CTRL(base, 0x0);
	return;
}

alt_u16 prsr_hdr_ram_read16(alt_u32 base, alt_u8 addr){
	IOWR_PRSR_HDR_RAM_RD_ADDR(base, addr);

	return (alt_u16)(IORD_PRSR_HDR_RAM_RD_DATA(base)	&	0xffff);
}

void	get_wav_hdr_frm_prsr(alt_u32 base, alt_u16 *bffr){
	alt_u8	i;

	while(prsr_get_bytes_read(base) < 48){
		chThdSleepMilliseconds(1);	//wait for sufficient data to be read
	}

	for(i=0;i<23;i++){
		bffr[i]	=	prsr_hdr_ram_read16(base, i);
	}

	return;
}

alt_u32	prsr_get_bytes_read(alt_u32 base){
	return	(alt_u32)(((IORD_PRSR_BYTES_READ_H(base) & 0xffff) << 16) + (IORD_PRSR_BYTES_READ_L(base) & 0xffff));
}
