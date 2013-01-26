/*
 * acortex.h
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */
#include "dac/dac_drvr.h"
#include "i2c/i2c_drvr.h"
#include "prsr/prsr.h"
#include "sram/sram.h"
#include "../../ledos_types.h"


#ifndef ACORTEX_H_
#define ACORTEX_H_

//Acortex Reset Address
#define ADC_LCAPTURE_RAM_ADDR_REG 	0x24000
#define ADC_RCAPTURE_RAM_ADDR_REG 	0x25000
#define ADC_START_CAPTURE_REG     	0x26000
#define ACORTEX_AUDIO_SRC_SEL_REG 	0x27000
#define	ACORTEX_RESET_ADDR			0x28000

#define	ACORTEX_ADC_CAP_DEPTH		128	//number of samples that can be captured

#define ADC_START_CAPTURE_EN_MSK   	0x1
#define ADC_CAPTURE_BUSY_MSK   		0x1

#define	ACORTEX_I2C_CLK_DIV_VAL		100

//Read Acortex registers
#define	IORD_ADC_LCAPTURE_DATA(base)				\
		IORD_32DIRECT(base, ADC_LCAPTURE_RAM_ADDR_REG)

#define	IORD_ADC_RCAPTURE_DATA(base)				\
		IORD_32DIRECT(base, ADC_RCAPTURE_RAM_ADDR_REG)

#define	IORD_ADC_START_CAPTURE_REG(base)				\
		IORD_32DIRECT(base, ADC_START_CAPTURE_REG)

#define	IORD_ACORTEX_AUDIO_SRC_SEL_REG(base)				\
		IORD_32DIRECT(base, ACORTEX_AUDIO_SRC_SEL_REG)

//Write Acortex registers
#define	IOWR_ADC_LCAPTURE_DATA(base,data)				\
		IOWR_32DIRECT(base, ADC_LCAPTURE_RAM_ADDR_REG, data)

#define	IOWR_ADC_RCAPTURE_DATA(base,data)				\
		IOWR_32DIRECT(base, ADC_RCAPTURE_RAM_ADDR_REG,data)

#define	IOWR_ADC_START_CAPTURE_REG(base,data)				\
		IOWR_32DIRECT(base, ADC_START_CAPTURE_REG,data)

#define	IOWR_ACORTEX_AUDIO_SRC_SEL_REG(base,data)				\
		IOWR_32DIRECT(base, ACORTEX_AUDIO_SRC_SEL_REG,data)


typedef enum	{
	ADC		=	0x0,
	PRSR	=	0x1
}ACORTEX_AUDIO_SRC_SEL_VAL;

void reset_acortex(alt_u32 base);

void acortex_aud_src_sel(alt_u32 base,ACORTEX_AUDIO_SRC_SEL_VAL val);

void adc_cap(alt_u32 base, alt_u32 * lcap_bffr, alt_u32 * rcap_bffr);

void acortex_init(alt_32 base, FS_T fs, BPS_T bps);

#endif /* ACORTEX_H_ */
