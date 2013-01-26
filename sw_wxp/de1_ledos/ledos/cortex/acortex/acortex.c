/*
 * acortex.c
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */
#include "acortex.h"
#include "alt_types.h"
#include "ch.h"
#include "sys/alt_stdio.h"


void reset_acortex(alt_u32 base){
	IOWR_32DIRECT(base, ACORTEX_RESET_ADDR, 0x0);	//a write to this address resets the acortex

    chThdSleepMilliseconds(1);

    return;
}

void acortex_aud_src_sel(alt_u32 base,ACORTEX_AUDIO_SRC_SEL_VAL val){
	IOWR_ACORTEX_AUDIO_SRC_SEL_REG(base,val);
}

void adc_cap(alt_u32 base, alt_u32 * lcap_bffr, alt_u32 * rcap_bffr){
	alt_u8 i,cap_addr;

	IOWR_ADC_START_CAPTURE_REG(base, ADC_START_CAPTURE_EN_MSK);	//trigger ADC capture

	while(IORD_ADC_START_CAPTURE_REG(base)	&	ADC_CAPTURE_BUSY_MSK){	//wait for capture to complete
	    alt_printf("[adc_cap] capture busy\n");
		chThdSleepMilliseconds(1);
	}

    alt_printf("[adc_cap] capture completed\n");

	for(i=0; i<ACORTEX_ADC_CAP_DEPTH; i++){
		cap_addr	=	i << 1;

		IOWR_ADC_LCAPTURE_DATA(base, cap_addr);	//point to LS 16b

		lcap_bffr[i]	=	IORD_ADC_LCAPTURE_DATA(base)	&	0xffff;	//Read LS 16b

		cap_addr++;

		IOWR_ADC_LCAPTURE_DATA(base, cap_addr);	//point to MS 16b

		lcap_bffr[i]	+=	(IORD_ADC_LCAPTURE_DATA(base)	&	0xffff)	<<	16;	//Read MS 16b
	}

	for(i=0; i<ACORTEX_ADC_CAP_DEPTH; i++){
		cap_addr	=	i << 1;

		IOWR_ADC_RCAPTURE_DATA(base, cap_addr);	//point to LS 16b

		rcap_bffr[i]	=	IORD_ADC_RCAPTURE_DATA(base)	&	0xffff;	//Read LS 16b

		cap_addr++;

		IOWR_ADC_RCAPTURE_DATA(base, cap_addr);	//point to MS 16b

		rcap_bffr[i]	+=	(IORD_ADC_RCAPTURE_DATA(base)	&	0xffff)	<<	16;	//Read MS 16b
	}

}

void acortex_init(alt_32 base, FS_T fs, BPS_T bps){
	reset_acortex(base);

	configure_i2c_clk(base, ACORTEX_I2C_CLK_DIV_VAL);

	configure_dac_drvr_bps(base,bps);

	update_fs_div(base,fs);

	update_mclk(base,fs);


	alt_printf("ACORTEX Init done\r\n");

	return;
}
