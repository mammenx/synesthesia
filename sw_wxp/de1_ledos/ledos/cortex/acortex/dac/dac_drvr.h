/*
 * dac_drvr.h
 *
 *  Created on: Sep 11, 2012
 *      Author: Gregory
 */
#include <io.h>
#include "alt_types.h"
#include "../../../ledos_types.h"

#ifndef DAC_DRVR_H_
#define DAC_DRVR_H_

//DAC Driver register addresses
#define DAC_DRVR_CTRL_REG_ADDR          0x23000
#define DAC_DRVR_STATUS_REG_ADDR        0x23010
#define DAC_DRVR_FS_DIV_REG_ADDR        0x23020
#define DAC_DRVR_MCLK_SEL_REG_ADDR      0x23030

//DAC Driver field masks
#define	DAC_DRVR_EN_MSK					0x1
#define	ADC_DRVR_EN_MSK					0x2
#define	DAC_DRVR_BPS_MSK				0x4
#define	DAC_DRVR_READY_MSK				0x1
#define	DAC_DRVR_FS_DIV_VAL_MSK			0x7ff
#define	DAC_DRVR_MCLK_SEL_MSK			0x3
#define	DAC_DRVR_MCLK_EN_MSK			0x8000

//Read DAC Driver registers
#define	IORD_DAC_DRVR_CTRL(base)				\
		IORD_32DIRECT(base, DAC_DRVR_CTRL_REG_ADDR)

#define	IORD_DAC_DRVR_STATUS(base)				\
		IORD_32DIRECT(base, DAC_DRVR_STATUS_REG_ADDR)

#define	IORD_DAC_DRVR_FS_DIV(base)				\
		IORD_32DIRECT(base, DAC_DRVR_FS_DIV_REG_ADDR)

#define	IORD_DAC_DRVR_MCLK_SEL(base)			\
		IORD_32DIRECT(base, DAC_DRVR_MCLK_SEL_REG_ADDR)

//Write DAC Driver registers
#define	IOWR_DAC_DRVR_CTRL(base, data)				\
		IOWR_32DIRECT(base, DAC_DRVR_CTRL_REG_ADDR, data)

#define	IOWR_DAC_DRVR_STATUS(base, data)				\
		IOWR_32DIRECT(base, DAC_DRVR_STATUS_REG_ADDR, data)

#define	IOWR_DAC_DRVR_FS_DIV(base, data)				\
		IOWR_32DIRECT(base, DAC_DRVR_FS_DIV_REG_ADDR, data)

#define	IOWR_DAC_DRVR_MCLK_SEL(base, data)			\
		IOWR_32DIRECT(base, DAC_DRVR_MCLK_SEL_REG_ADDR, data)

typedef enum	{
	CLK_18MHZ	=	0x0,
	CLK_16MHZ	=	0x1,	//not implemented !
	CLK_12MHZ	=	0x2,
	CLK_11MHZ	=	0x3
}MCLK_SEL_VAL;

static const MCLK_SEL_VAL fs2mclk_lookup[]	=	{
		[FS_8KHZ]	=	CLK_12MHZ,
		[FS_32KHZ]	=	CLK_12MHZ,
		[FS_44KHZ]	=	CLK_11MHZ,
		[FS_48KHZ]	=	CLK_12MHZ,
		[FS_88KHZ]	=	CLK_11MHZ,
		[FS_96KHZ]	=	CLK_12MHZ
};


typedef	enum	{	//	==	BCLK_FREQ(6.25MHz)	/	FS
	FS_DIV_8KHZ		=	781,
	FS_DIV_32KHZ	=	195,
	FS_DIV_44KHZ	=	142,
	FS_DIV_48KHZ	=	130,
	FS_DIV_88KHZ	=	71,
	FS_DIV_96KHZ	=	65
}FS_DIV_VAL;

static const FS_DIV_VAL fs2div_lookup[]	=	{
		[FS_8KHZ]	=	FS_DIV_8KHZ,
		[FS_32KHZ]	=	FS_DIV_32KHZ,
		[FS_44KHZ]	=	FS_DIV_44KHZ,
		[FS_48KHZ]	=	FS_DIV_48KHZ,
		[FS_88KHZ]	=	FS_DIV_88KHZ,
		[FS_96KHZ]	=	FS_DIV_96KHZ
};


//Utils
void disable_dac_drvr(alt_u32 base);
void enable_dac_drvr(alt_u32 base);
void disable_adc_drvr(alt_u32 base);
void enable_adc_drvr(alt_u32 base);
void configure_dac_drvr_bps(alt_u32 base, BPS_T val);
void enable_mclk(alt_u32 base);
void disable_mclk(alt_u32 base);
void update_mclk(alt_u32 base, FS_T val);
void update_fs_div(alt_u32 base, FS_T val);


#endif /* DAC_DRVR_H_ */
