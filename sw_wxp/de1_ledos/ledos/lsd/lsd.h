/*
 * lsd.h
 *
 *  Created on: Dec 28, 2012
 *      Author: Gregory
 */
#include "alt_types.h"

#ifndef LSD_H_
#define LSD_H_

/*
 * Plugin (Acid) function prototype
 */
typedef void (*acid_t)(int argc, alt_u32 *lfft_bffr, alt_u32 *rfft_bffr, alt_u16 *pwm_bffr);

/*
 * Plugin (Acid) structure
 */
typedef	struct	{
	const char	*acid_name;		//Name of plugin
	acid_t		acid_function;	//Plugin function pointer
}Acid;

/*
 * Function returns pointer to array of available plugins (acid_box)
 */
Acid * get_acid_box(void);

#endif /* LSD_H_ */
