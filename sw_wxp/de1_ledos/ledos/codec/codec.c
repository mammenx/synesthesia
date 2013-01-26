/*
 * codec.c
 *
 *  Created on: Oct 24, 2012
 *      Author: Gregory
 */
#include "codec.h"
#include "alt_types.h"
#include "system.h"
#include "sys/alt_stdio.h"
#include "ch.h"

I2C_RES	codec_reset(){
	alt_u8 i;
/*
	codec_shadow_reg[0]	  =	0x97;
	codec_shadow_reg[1]   = 0x297;
	//codec_shadow_reg[0]	  =	0x17;
	//codec_shadow_reg[1]   = 0x217;
	//codec_shadow_reg[0]	  =	0x1f;
	//codec_shadow_reg[1]   = 0x21f;
	//codec_shadow_reg[2]   = 0x4e5;	//different from default
	//codec_shadow_reg[3]   = 0x6e5;	//different from default
	codec_shadow_reg[2]   = 0x4f9;
	codec_shadow_reg[3]   = 0x6f9;
	codec_shadow_reg[4]   = 0x80a;
	codec_shadow_reg[5]   = 0xa00;
	codec_shadow_reg[6]   = 0xcff;
	//codec_shadow_reg[7]   = 0xe0a;
	codec_shadow_reg[7]   = 0xe0f;	//different from default
	codec_shadow_reg[8]   = 0x1000;
	codec_shadow_reg[9]   = 0x1200;
	codec_shadow_reg[10]  = 0x1e00;
*/

	//All the below values are default values given in spec
	codec_shadow_reg[0]	  =	0x97;
	codec_shadow_reg[1]   = 0x297;
	codec_shadow_reg[2]   = 0x479;
	codec_shadow_reg[3]   = 0x679;
	codec_shadow_reg[4]   = 0x80a;
	codec_shadow_reg[5]   = 0xa08;
	codec_shadow_reg[6]   = 0xc9f;
	codec_shadow_reg[7]   = 0xe0a;
	codec_shadow_reg[8]   = 0x1000;
	codec_shadow_reg[9]   = 0x1200;
	codec_shadow_reg[10]  = 0x1e00;

	return	i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_RESET_IDX]);

	/*
	for(i=0; i<NO_OF_CODEC_REGS-1; i++){
		if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[i])){
			return I2C_NACK_DETECTED;
		}
	}
	*/

	return I2C_OK;

}

I2C_RES	codec_config_reg(alt_u8 idx, alt_u8 offst, alt_u8 msk, alt_u8 val){
	codec_shadow_reg[idx]	&=	~(alt_u16)(msk	<<	offst);
	codec_shadow_reg[idx]	|=	(alt_u16)((val & msk)	<<	offst);

	return	i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[idx]);
}

I2C_RES codec_init(BPS_T bps, FS_T fs){

	if(codec_reset())	return I2C_NACK_DETECTED;

	chThdSleepMilliseconds(100);

	//Read Power On Sequence spec

	codec_shadow_reg[CODEC_POWER_DOWN_REG_IDX]	=	0xc10;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_POWER_DOWN_REG_IDX]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_LEFT_LINE_IN_REG_IDX]=	0x17;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_LEFT_LINE_IN_REG_IDX]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_RIGHT_LINE_IN_REG_IDX]=	0x217;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_RIGHT_LINE_IN_REG_IDX]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_LEFT_HP_OUT_REG_IDX]=	0x4f9;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_LEFT_HP_OUT_REG_IDX]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_RIGHT_HP_OUT_REG_IDX]=	0x6f9;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_RIGHT_HP_OUT_REG_IDX]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_DIGITAL_AUD_PATH_REG_IDX]=	0xa00;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_DIGITAL_AUD_PATH_REG_IDX]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_DIGITAL_AUD_IF_FMT_REG_IDX]=	0xe0f;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_DIGITAL_AUD_IF_FMT_REG_IDX]))	return I2C_NACK_DETECTED;


	//Misc
	if(codec_iwl_update(bps2iwl_lookup[bps]))	return I2C_NACK_DETECTED;

	if(codec_sr_update(fs2sr_lookup[fs]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_ACTIVE_CTRL_REG_IDX]=	0x1201;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_ACTIVE_CTRL_REG_IDX]))	return I2C_NACK_DETECTED;


	codec_shadow_reg[CODEC_POWER_DOWN_REG_IDX]	=	0xc00;
	if(i2c_xtn_write16(CORTEX_MM_SL_BASE, CODEC_I2C_WRITE_ADDR, codec_shadow_reg[CODEC_POWER_DOWN_REG_IDX]))	return I2C_NACK_DETECTED;

	//Debug ...
	codec_dump_regs();

	alt_printf("[codec_init] Success\r\n");

	return I2C_OK;
}

I2C_RES codec_dsp_if_activate(){
	return codec_config_reg(CODEC_ACTIVE_IDX, CODEC_ACTIVE_OFFST, CODEC_ACTIVE_MSK, 0x1);
}

I2C_RES codec_dsp_if_inactivate(){
	return codec_config_reg(CODEC_ACTIVE_IDX, CODEC_ACTIVE_OFFST, CODEC_ACTIVE_MSK, 0x0);
}

I2C_RES codec_dac_activate(){
	//Referpg44 of WM8731 datasheet
	if(codec_config_reg(CODEC_DACPD_IDX, CODEC_DACPD_OFFST, CODEC_DACPD_MSK, 0x0))	return	I2C_NACK_DETECTED;

	//Refer pg26 of WM8731 datasheet
	if(codec_config_reg(CODEC_DAC_SEL_IDX, CODEC_DAC_SEL_OFFST, CODEC_DAC_SEL_MSK, 0x1))	return	I2C_NACK_DETECTED;

	if(codec_config_reg(CODEC_DAC_MU_IDX, CODEC_DAC_MU_OFFST, CODEC_DAC_MU_MSK, 0x0))	return	I2C_NACK_DETECTED;

	return I2C_OK;
}

I2C_RES codec_dac_inactivate(){

	if(codec_config_reg(CODEC_DAC_MU_IDX, CODEC_DAC_MU_OFFST, CODEC_DAC_MU_MSK, 0x1))	return	I2C_NACK_DETECTED;

	//Refer pg26 of WM8731 datasheet
	if(codec_config_reg(CODEC_DAC_SEL_IDX, CODEC_DAC_SEL_OFFST, CODEC_DAC_SEL_MSK, 0x0))	return	I2C_NACK_DETECTED;

	//Referpg44 of WM8731 datasheet
	if(codec_config_reg(CODEC_DACPD_IDX, CODEC_DACPD_OFFST, CODEC_DACPD_MSK, 0x1))	return	I2C_NACK_DETECTED;

	return I2C_OK;

}

I2C_RES codec_pwr_off_n_on(CODEC_PWR_ON_OFF val){	//0->Power up, 1->Power Down
	return codec_config_reg(CODEC_PWROFF_IDX, CODEC_PWROFF_OFFST, CODEC_PWROFF_MSK, val);
}

I2C_RES codec_linein_pwr_dwn_n_up(CODEC_PWR_ON_OFF val){	//0->Power up, 1->Power Down
	return codec_config_reg(CODEC_LINEINPD_IDX, CODEC_LINEINPD_OFFST, CODEC_LINEINPD_MSK, val);
}

I2C_RES codec_lineout_pwr_dwn_n_up(CODEC_PWR_ON_OFF val){
	return codec_config_reg(CODEC_OUTPD_IDX, CODEC_OUTPD_OFFST, CODEC_OUTPD_MSK, val);
}

I2C_RES codec_adc_hpf_enable(CODEC_PWR_ON_OFF val){
	return codec_config_reg(CODEC_ADC_HPD_IDX, CODEC_ADC_HPD_OFFST, CODEC_ADC_HPD_MSK, val);
}

I2C_RES codec_adc_pwr_dwn_n_up(CODEC_PWR_ON_OFF val){
	return codec_config_reg(CODEC_ADCPD_IDX, CODEC_ADCPD_OFFST, CODEC_ADCPD_MSK, val);
}

I2C_RES codec_sr_update(SR_SEL val){
	return codec_config_reg(CODEC_SR_IDX, CODEC_SR_OFFST, CODEC_SR_MSK, val);
}

I2C_RES codec_iwl_update(CODEC_IWL val){
	return codec_config_reg(CODEC_IWL_IDX, CODEC_IWL_OFFST, CODEC_IWL_MSK, val);
}

void codec_dump_regs(){
	alt_u8 i;

	alt_printf("CODEC Regs - \r\n");

	for(i=0; i<NO_OF_CODEC_REGS; i++){
		alt_printf("REG[0x%x] - 0x%x\r\n",i,codec_shadow_reg[i]);
	}

	return;
}
