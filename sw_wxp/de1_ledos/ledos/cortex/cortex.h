/*
 * cortex.h
 *
 *  Created on: Oct 21, 2012
 *      Author: Gregory
 */
#include "acortex/acortex.h"
#include "fgyrus/fgyrus.h"
#include "vcortex/vcortex.h"
#include "../ledos_types.h"

#ifndef CORTEX_H_
#define CORTEX_H_

void cortex_init(alt_32 base, FS_T fs, BPS_T bps);

#endif /* CORTEX_H_ */
