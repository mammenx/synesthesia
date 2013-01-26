/*
 * dac_drvr.c
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */
#include "dac_drvr.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"


void disable_dac_drvr(alt_u32 base){
	IOWR_DAC_DRVR_CTRL(base, IORD_DAC_DRVR_CTRL(base) & ~DAC_DRVR_EN_MSK);
}

void enable_dac_drvr(alt_u32 base){
	IOWR_DAC_DRVR_CTRL(base, IORD_DAC_DRVR_CTRL(base) |	DAC_DRVR_EN_MSK);
}

void disable_adc_drvr(alt_u32 base){
	IOWR_DAC_DRVR_CTRL(base, IORD_DAC_DRVR_CTRL(base) & ~ADC_DRVR_EN_MSK);
}

void enable_adc_drvr(alt_u32 base){
	IOWR_DAC_DRVR_CTRL(base, IORD_DAC_DRVR_CTRL(base) |	ADC_DRVR_EN_MSK);
}

void configure_dac_drvr_bps(alt_u32 base, BPS_T val){
	if(val){	//32bps
		IOWR_DAC_DRVR_CTRL(base, IORD_DAC_DRVR_CTRL(base) |	DAC_DRVR_BPS_MSK);
	}
	else{		//16bps
		IOWR_DAC_DRVR_CTRL(base, IORD_DAC_DRVR_CTRL(base) &	~DAC_DRVR_BPS_MSK);
	}
}

void enable_mclk(alt_u32 base){
	//alt_printf("[enable_mclk] Reg pre - 0x%x\n",IORD_DAC_DRVR_MCLK_SEL(base));

	IOWR_DAC_DRVR_MCLK_SEL(base, IORD_DAC_DRVR_MCLK_SEL(base)	|	DAC_DRVR_MCLK_EN_MSK);

	//alt_printf("[enable_mclk] Reg post - 0x%x\n",IORD_DAC_DRVR_MCLK_SEL(base));

}

void disable_mclk(alt_u32 base){
	IOWR_DAC_DRVR_MCLK_SEL(base, 0x0);

	//alt_printf("[disable_mclk] Reg - 0x%x\n",IORD_DAC_DRVR_MCLK_SEL(base));

}

void update_mclk(alt_u32 base, FS_T val){
	disable_mclk(base);

	IOWR_DAC_DRVR_MCLK_SEL(base, fs2mclk_lookup[val]);

	enable_mclk(base);
}

void update_fs_div(alt_u32 base, FS_T val){
	IOWR_DAC_DRVR_FS_DIV(base, fs2div_lookup[val]);
}
