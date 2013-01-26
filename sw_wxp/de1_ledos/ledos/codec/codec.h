/*
 * codec.h
 *
 *  Created on: Oct 24, 2012
 *      Author: Gregory
 */
#include <io.h>
#include "alt_types.h"
#include "../cortex/acortex/i2c/i2c_drvr.h"
#include "../ledos_types.h"

#ifndef CODEC_H_
#define CODEC_H_

#define	CODEC_I2C_READ_ADDR			0x35	//Never to be used !
#define	CODEC_I2C_WRITE_ADDR		0x34

#define	NO_OF_CODEC_REGS			11

//Shadow register to hold the current config of the codec; initialized to POR values as per data sheet
static	alt_u16	codec_shadow_reg[NO_OF_CODEC_REGS];

//Register Indexes
#define	CODEC_LEFT_LINE_IN_REG_IDX		0
#define	CODEC_RIGHT_LINE_IN_REG_IDX		1
#define	CODEC_LEFT_HP_OUT_REG_IDX		2
#define	CODEC_RIGHT_HP_OUT_REG_IDX		3
#define	CODEC_ANALOG_AUD_PATH_REG_IDX	4
#define	CODEC_DIGITAL_AUD_PATH_REG_IDX	5
#define	CODEC_POWER_DOWN_REG_IDX		6
#define	CODEC_DIGITAL_AUD_IF_FMT_REG_IDX	7
#define	CODEC_SAMPLING_CTRL_REG_IDX		8
#define	CODEC_ACTIVE_CTRL_REG_IDX		9
#define	CODEC_RESET_REG_IDX				10


//IDX[0] Fields
#define	CODEC_LINVOL_MSK			0x1f
#define	CODEC_LINVOL_OFFST			0
#define	CODEC_LINVOL_IDX			0

#define	CODEC_LIN_MUTE_MSK			0x1
#define	CODEC_LIN_MUTE_OFFST		7
#define	CODEC_LIN_MUTE_IDX			0

#define	CODEC_LRIN_BOTH_MSK			0x1
#define	CODEC_LRIN_BOTH_OFFST		8
#define	CODEC_LRIN_BOTH_IDX			0

//IDX[1] Fields
#define	CODEC_RINVOL_MSK			0x1f
#define	CODEC_RINVOL_OFFST			0
#define	CODEC_RINVOL_IDX			1

#define	CODEC_RIN_MUTE_MSK			0x1
#define	CODEC_RIN_MUTE_OFFST		7
#define	CODEC_RIN_MUTE_IDX			1

#define	CODEC_RLIN_BOTH_MSK			0x1
#define	CODEC_RLIN_BOTH_OFFST		8
#define	CODEC_RLIN_BOTH_IDX			1

//IDX[2] Fields
#define	CODEC_LHPVOL_MSK			0x7f
#define	CODEC_LHPVOL_OFFST			0
#define	CODEC_LHPVOL_IDX			2

#define	CODEC_LZCEN_MSK				0x1
#define	CODEC_LZCEN_OFFST			7
#define	CODEC_LZCEN_IDX				2

#define	CODEC_LRHP_BOTH_MSK			0x1
#define	CODEC_LRHP_BOTH_OFFST		8
#define	CODEC_LRHP_BOTH_IDX			2

//IDX[3] Fields
#define	CODEC_RHPVOL_MSK			0x7f
#define	CODEC_RHPVOL_OFFST			0
#define	CODEC_RHPVOL_IDX			3

#define	CODEC_RZCEN_MSK				0x1
#define	CODEC_RZCEN_OFFST			7
#define	CODEC_RZCEN_IDX				3

#define	CODEC_RLHP_BOTH_MSK			0x1
#define	CODEC_RLHP_BOTH_OFFST		8
#define	CODEC_RLHP_BOTH_IDX			3

//IDX[4] Fields
#define	CODEC_MIC_BOOST_MSK			0x1
#define	CODEC_MIC_BOOST_OFFST		0
#define	CODEC_MIC_BOOST_IDX			4

#define	CODEC_MUTE_MIC_MSK			0x1
#define	CODEC_MUTE_MIC_OFFST		1
#define	CODEC_MUTE_MIC_IDX			4

#define	CODEC_INSEL_MSK			    0x1
#define	CODEC_INSEL_OFFST		    2
#define	CODEC_INSEL_IDX			    4

#define	CODEC_BYPASS_MSK			0x1
#define	CODEC_BYPASS_OFFST		  	3
#define	CODEC_BYPASS_IDX			4

#define	CODEC_DAC_SEL_MSK			0x1
#define	CODEC_DAC_SEL_OFFST		  	4
#define	CODEC_DAC_SEL_IDX			4

#define	CODEC_SIDE_TONE_MSK			0x1
#define	CODEC_SIDE_TONE_OFFST		5
#define	CODEC_SIDE_TONE_IDX			4

#define	CODEC_SIDE_ATT_MSK			0x3
#define	CODEC_SIDE_ATT_OFFST		6
#define	CODEC_SIDE_ATT_IDX			4

//IDX[5] Fields
#define	CODEC_ADC_HPD_MSK			0x1
#define	CODEC_ADC_HPD_OFFST		 	0
#define	CODEC_ADC_HPD_IDX			5

#define	CODEC_DEEMPH_MSK			0x3
#define	CODEC_DEEMPH_OFFST		 	1
#define	CODEC_DEEMPH_IDX			5

#define	CODEC_DAC_MU_MSK			0x1
#define	CODEC_DAC_MU_OFFST		 	3
#define	CODEC_DAC_MU_IDX			5

#define	CODEC_HPOR_MSK			  	0x1
#define	CODEC_HPOR_OFFST		  	4
#define	CODEC_HPOR_IDX			  	5

//IDX[6] Fields
#define	CODEC_LINEINPD_MSK			0x1
#define	CODEC_LINEINPD_OFFST		0
#define	CODEC_LINEINPD_IDX			6

#define	CODEC_MICPD_MSK		    	0x1
#define	CODEC_MICPD_OFFST	    	1
#define	CODEC_MICPD_IDX		    	6

#define	CODEC_ADCPD_MSK		    	0x1
#define	CODEC_ADCPD_OFFST	    	2
#define	CODEC_ADCPD_IDX		    	6

#define	CODEC_DACPD_MSK		    	0x1
#define	CODEC_DACPD_OFFST	    	3
#define	CODEC_DACPD_IDX		    	6

#define	CODEC_OUTPD_MSK		    	0x1
#define	CODEC_OUTPD_OFFST	    	4
#define	CODEC_OUTPD_IDX		    	6

#define	CODEC_OSCPD_MSK		    	0x1
#define	CODEC_OSCPD_OFFST	    	5
#define	CODEC_OSCPD_IDX		    	6

#define	CODEC_CLKOUTPD_MSK			0x1
#define	CODEC_CLKOUTPD_OFFST		6
#define	CODEC_CLKOUTPD_IDX			6

#define	CODEC_PWROFF_MSK		  	0x1
#define	CODEC_PWROFF_OFFST	  		7
#define	CODEC_PWROFF_IDX		  	6

//IDX[7] Fields
#define	CODEC_FORMAT_MSK		  	0x3
#define	CODEC_FORMAT_OFFST	  		0
#define	CODEC_FORMAT_IDX		  	7

#define	CODEC_IWL_MSK		      	0x3
#define	CODEC_IWL_OFFST	      		2
#define	CODEC_IWL_IDX		      	7

#define	CODEC_LRP_MSK		      	0x1
#define	CODEC_LRP_OFFST	      		4
#define	CODEC_LRP_IDX		      	7

#define	CODEC_LRSWAP_MSK		  	0x1
#define	CODEC_LRSWAP_OFFST	  		5
#define	CODEC_LRSWAP_IDX		  	7

#define	CODEC_MS_MSK		      	0x1
#define	CODEC_MS_OFFST	      		6
#define	CODEC_MS_IDX		      	7

#define	CODEC_BCLK_INV_MSK			0x1
#define	CODEC_BCLK_INV_OFFST		7
#define	CODEC_BCLK_INV_IDX			7

//IDX[8] Fields
#define	CODEC_USB_NORM_MSK			0x1
#define	CODEC_USB_NORM_OFFST		0
#define	CODEC_USB_NORM_IDX			8

#define	CODEC_BOSR_MSK		    	0x1
#define	CODEC_BOSR_OFFST	    	1
#define	CODEC_BOSR_IDX		    	8

#define	CODEC_SR_MSK		      	0xf
#define	CODEC_SR_OFFST	      		2
#define	CODEC_SR_IDX		      	8

#define	CODEC_CLKI_DIV2_MSK			0x1
#define	CODEC_CLKI_DIV2_OFFST		6
#define	CODEC_CLKI_DIV2_IDX			8

#define	CODEC_CLKO_DIV2_MSK			0x1
#define	CODEC_CLKO_DIV2_OFFST		7
#define	CODEC_CLKO_DIV2_IDX			8

//IDX[9] Fields
#define	CODEC_ACTIVE_MSK		  	0x1
#define	CODEC_ACTIVE_OFFST	  		0
#define	CODEC_ACTIVE_IDX		  	9

//Reset Address IDX[10]
#define	CODEC_RESET_IDX				10

//Function to reset CODEC
I2C_RES	codec_reset();

//Function to write a register in CODEC
I2C_RES	codec_config_reg(alt_u8 idx, alt_u8 offst, alt_u8 msk, alt_u8 val);

typedef	enum	{
	RIGHT_JUST	=	0x0,
	LEFT_JUST	=	0x1,
	I2S			=	0x2,
	DSP			=	0x3
}CODEC_DAC_FMT;

typedef	enum	{
	IWL_16		=	0x0,
	IWL_20		=	0x1,
	IWL_24		=	0x2,
	IWL_32		=	0x3
}CODEC_IWL;

static const CODEC_IWL bps2iwl_lookup[]	=	{
		[BPS_32]	=	IWL_32,
		[BPS_16]	=	IWL_16
};

typedef enum	{
	FS_8KHZ_SR		=	0x3,
	FS_32KHZ_SR		=	0x6,
	FS_44KHZ_SR		=	0x8,
	FS_48KHZ_SR		=	0x0,
	FS_88KHZ_SR		=	0xf,
	FS_96KHZ_SR		=	0x7
}SR_SEL;

static const SR_SEL fs2sr_lookup[]	=	{
		[FS_8KHZ]	=	FS_8KHZ_SR,
		[FS_32KHZ]	=	FS_32KHZ_SR,
		[FS_44KHZ]	=	FS_44KHZ_SR,
		[FS_48KHZ]	=	FS_48KHZ_SR,
		[FS_88KHZ]	=	FS_88KHZ_SR,
		[FS_96KHZ]	=	FS_96KHZ_SR
};


typedef enum	{
	ON			=	0x0,
	OFF			=	0x1	//Or power down ...

}CODEC_PWR_ON_OFF;

//Function to initialize the CODEC
I2C_RES codec_init(BPS_T bps, FS_T fs);

//Function to activate DSP Interface
I2C_RES codec_dsp_if_activate();

//Function to inactivate DSP Interface
I2C_RES codec_dsp_if_inactivate();

//Function to enable DAC
I2C_RES codec_dac_activate();

//Function to disable DAC
I2C_RES codec_dac_inactivate();

//Function to Power Off/On the Audio Codec
I2C_RES codec_pwr_off_n_on(CODEC_PWR_ON_OFF val);

//Function to Power Down the Audio Codec
I2C_RES codec_linein_pwr_dwn_n_up(CODEC_PWR_ON_OFF val);	//1-> power down

//Function to Power Down the Audio Codec Output
I2C_RES codec_lineout_pwr_dwn_n_up(CODEC_PWR_ON_OFF val);	//1-> power down

//Function to Enable/Disable the ADC HPF
I2C_RES codec_adc_hpf_enable(CODEC_PWR_ON_OFF val);	//1-> power down

//Function to Power Up/Down the ADC
I2C_RES codec_adc_pwr_dwn_n_up(CODEC_PWR_ON_OFF val);	//1-> power down

//Function to update the Sample Rate
I2C_RES codec_sr_update(SR_SEL val);

//Function to update the IWL
I2C_RES codec_iwl_update(CODEC_IWL val);


//Dump Current value of regisers
void codec_dump_regs();

#endif /* CODEC_H_ */
