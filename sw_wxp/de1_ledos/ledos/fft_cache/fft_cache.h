/*
 * fft_cache.h
 *
 *  Created on: Dec 11, 2012
 *      Author: Gregory
 */

#ifndef FFT_CACHE_H_
#define FFT_CACHE_H_

#include "system.h"
#include "alt_types.h"
#include <io.h>


#define	FFT_LCACHE_BASE			0x80
#define	FFT_RCACHE_BASE			0x00

#define	FFT_LCACHE_BASE_DIRECT	0x800
#define	FFT_RCACHE_BASE_DIRECT	0x000

#define	FFT_NUM_SAMPLES			128

/*	Function to read the fft cache	*/
void read_fft_cache(alt_u32 * lfft_bffr, alt_u32 * rfft_bffr, alt_u8 num);

#endif /* FFT_CACHE_H_ */
