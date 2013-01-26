/*
 * fft_cache.c
 *
 *  Created on: Dec 11, 2012
 *      Author: Gregory
 */
#include "fft_cache.h"

void read_fft_cache(alt_u32 * lfft_bffr, alt_u32 * rfft_bffr, alt_u8 num){
	alt_u8 i;

	for(i=0; i<num; i++){	//num should  be < 128
		rfft_bffr[i]	=	IORD_32DIRECT(FFT_CACHE_MM_SL_BASE, (i + FFT_RCACHE_BASE)<<4);
		lfft_bffr[i]	=	IORD_32DIRECT(FFT_CACHE_MM_SL_BASE, (i + FFT_LCACHE_BASE)<<4);
	}
}
