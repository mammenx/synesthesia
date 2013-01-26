/*
 * fgyrus.c
 *
 *  Created on: Oct 21, 2012
 *      Author: Gregory
 */

#include "fgyrus.h"
#include "alt_types.h"


alt_u32	get_full_fgyrus_addr(FGYRUS_TYPE fg, alt_u32 addr){
	return	(fg == LCHNL) ? addr + FGYRUS_LCHNL_BLK_CODE : addr + FGYRUS_RCHNL_BLK_CODE;
}


FGYRUS_STATUS_TYPE	get_fgyrus_status(alt_u32 base, FGYRUS_TYPE fg){
	if(IORD_FGYRUS_STATUS(base, fg) & FGYRUS_BUSY_MSK){
		return DECIMATE; //As long as its not idle
	}
	else{
		return IDLE;
	}
}


FGYRUS_STATUS_TYPE	get_fgyrus_fsm_pstate(alt_u32 base, FGYRUS_TYPE fg){
	return IORD_FGYRUS_FSM_PSTATE(base, fg) & FGYRUS_FSM_PSTATE_MSK;
}

void enable_fgyrus(alt_u32 base, FGYRUS_TYPE fg){
	IOWR_FGYRUS_CTRL(base, fg, FGYRUS_EN_MSK);
}

void disable_fgyrus(alt_u32 base, FGYRUS_TYPE fg){
	IOWR_FGYRUS_CTRL(base, fg, 0x0);
}

void configure_post_norm(alt_u32 base, FGYRUS_TYPE fg, FGYRUS_POST_NORM_TYPE val){
	IOWR_FGYRUS_POST_NORM(base, fg, val);
}
