/*
 * ledos.c
 *
 *  Created on: Jun 16, 2012
 *      Author: Gregory James
 */

#include "ledos.h"
#include "sys/alt_stdio.h"
#include "system.h"
#include "ch.h"
#include "shell/shell.h"
#include "shell/bash.h"

static WORKING_AREA(AcidStack, TASK_ACID_SIZE);
static WORKING_AREA(ShellStack, SHELL_WA_SIZE);

EventListener shell_tel;


void splash_ledos(void){
	alt_printf("\r\n");
	alt_printf("\r\n");
	alt_printf("            .,ad88888888baa,\r\n");
	alt_printf("        ,d8P\"\"\"        \"\"9888ba.\r\n");
	alt_printf("     .a8\"          ,ad88888888888a\r\n");
	alt_printf("    aP'          ,88888888888888888a\r\n");
	alt_printf("  ,8\"           ,88888888888888888888,\r\n");
	alt_printf(" ,8'            (888888888( )888888888,\r\n");
	alt_printf(",8'             `8888888888888888888888\r\n");
	alt_printf("8)               `888888888888888888888,\r\n");
	alt_printf("8                  \"8888888888888888888)\r\n");
	alt_printf("8                   `888888888888888888)\r\n");
	alt_printf("8)                    \"8888888888888888\r\n");
	alt_printf("(b                     \"88888888888888'\r\n");
	alt_printf("`8,        (8)          8888888888888)\r\n");
	alt_printf(" \"8a                   ,888888888888)\r\n");
	alt_printf("   V8,                 d88888888888\"\r\n");
	alt_printf("    `8b,             ,d8888888888P'\r\n");
	alt_printf("      `V8a,       ,ad8888888888P'\r\n");
	alt_printf("         \"\"88888888888888888P\"    Synesthesia by mammenx\r\n");
	alt_printf("              \"\"\"\"\"\"\"\"\"\"\"\"\r\n");
	alt_printf("\r\n");


}

void init_ledos(FS_T fs, BPS_T bps){

	//HW Init
	cortex_init(CORTEX_MM_SL_BASE, fs, bps);

	codec_init(bps, fs);

	init_bash();

	/*
	 * Shell manager initialization.
	*/
	shellInit();

	chEvtRegister(&shell_terminated, &shell_tel, 0);


	/*	SW Stuff	*/
	alt_printf("Updating default acid to <sunshine>\r\n");

	update_acid(get_acid_box(), "sunshine");	//set default acid/plugin

	/*	Start Acid Thread	*/
	alt_printf("Starting acid_thread\r\n");
	acidThreadCreateStatic(AcidStack, sizeof(AcidStack), TASK_ACID_PRIORITY);

	//Welcome logo
	splash_ledos();

	/*
	 * Start Shell Thread
	*/
	alt_printf("Starting Shell\r\n");
	shellCreateStatic(get_usr_bash_config(), ShellStack,sizeof(ShellStack), SHELL_PRIORITY);


	return;
}


void update_aud_bytes_read(void *p){
	aud_bytes_read	+=	*((alt_u32 *)p);
}

void byte_swap16(alt_u16 *data){
	*data	=	(((*data) & 0xff00) >> 8) + (((*data) & 0xff) << 8);
	return;
}

void byte_swap32(alt_u32 *data){
	*data	=	(((*data) & 0xff000000) >> 24) + (((*data) & 0xff0000) >> 8) + (((*data) & 0xff00) << 8) + (((*data) & 0xff) << 24);
}

void printf_wave_hdr(WavHdrType *hdr){
	alt_printf("ChunkID\t-\t%s\r\n",         (char *)&(hdr->ChunkID));
	alt_printf("ChunkSize\t-\t%s\r\n",       (char *)&(hdr->ChunkSize));
	alt_printf("Format\t-\t%s\r\n",          (char *)&(hdr->Format));
	alt_printf("Subchunk1ID\t-\t%s\r\n",     (char *)&(hdr->Subchunk1ID));
	alt_printf("Subchunk1Size\t-\t%s\r\n",   (char *)&(hdr->Subchunk1Size));
	alt_printf("AudioFormat\t-\t%s\r\n",     (char *)&(hdr->AudioFormat));
	alt_printf("NumChannels\t-\t%s\r\n",     (char *)&(hdr->NumChannels));
	alt_printf("SampleRate\t-\t%s\r\n",      (char *)&(hdr->SampleRate));
	alt_printf("ByteRate\t-\t%s\r\n",        (char *)&(hdr->ByteRate));
	alt_printf("BlockAlign\t-\t%s\r\n",      (char *)&(hdr->BlockAlign));
	alt_printf("BitsPerSample\t-\t%s\r\n",   (char *)&(hdr->BitsPerSample));
	alt_printf("Extra\t-\t%s\r\n",           (char *)&(hdr->Extra));
	alt_printf("Subchunk2ID\t-\t%s\r\n",     (char *)&(hdr->Subchunk2ID));
	alt_printf("Subchunk2Size\t-\t%s\r\n",   (char *)&(hdr->Subchunk2Size));
	return;
}

alt_u32 chk_wav_hdr(WavHdrType *hdr){
	alt_u32	error =0;

	if(hdr->ChunkID		!= 0x52494646)	error = 1;
	if(hdr->Format		!= 0x57415645)	error = 1;
	if(hdr->Subchunk1ID	!= 0x666d7420)	error = 1;
	if((hdr->Subchunk1Size != 16) && (hdr->Subchunk1Size != 18))	error = 1;
	if(hdr->AudioFormat	!= 0x1)			error = 1;
	if((hdr->NumChannels   != 1)  && (hdr->NumChannels != 2))		error = 1;
	if((hdr->BitsPerSample != 16) && (hdr->BitsPerSample != 32))	error = 1;
	if(hdr->Subchunk2ID	!= 0x64617461)	error = 1;

	return error;
}

alt_u32 wave_parse(WavHdrType * hdr){

	get_wav_hdr_frm_prsr(CORTEX_MM_SL_BASE, (alt_u16 *)hdr);

	//correct endianess
	byte_swap32(&(hdr->ChunkSize));
	byte_swap32(&(hdr->Subchunk1Size));
	byte_swap16(&(hdr->AudioFormat));
	byte_swap16(&(hdr->NumChannels));
	byte_swap32(&(hdr->SampleRate));
	byte_swap32(&(hdr->ByteRate));
	byte_swap16(&(hdr->BlockAlign));
	byte_swap16(&(hdr->BitsPerSample));

	if(hdr->Subchunk2Size	==	0x10){ //re align
		hdr->Subchunk2Size	=	((hdr->Subchunk2Size & 0xffff0000) >> 16) + ((hdr->Subchunk2ID & 0xffff) << 16);
		hdr->Subchunk2ID	=	((hdr->Subchunk2ID & 0xffff0000) >> 16) + ((hdr->Extra & 0xffff) << 16);
	}

	byte_swap32(&(hdr->Subchunk2Size));

	printf_wave_hdr(hdr);

	return chk_wav_hdr(hdr);
}



/*	Function to configure acortex & fgyrus blocks based on parsed wavheader	*/
I2C_RES prep_cortex(WavHdrType * hdr){
	alt_u8 sr_val;

	if(codec_dsp_if_inactivate())	return I2C_NACK_DETECTED;
	if(codec_dac_inactivate())		return I2C_NACK_DETECTED;

	if(hdr->BitsPerSample == 16){
		if(codec_iwl_update(IWL_16))	return	I2C_NACK_DETECTED;
	}
	else{	//32b
		if(codec_iwl_update(IWL_32))	return	I2C_NACK_DETECTED;
	}

	//BOSR is always zero !

	//Select SR
	if(hdr->SampleRate	==	8000)		sr_val	=	FS_8KHZ;
	else if(hdr->SampleRate	==	32000)	sr_val	=	FS_32KHZ;
	else if(hdr->SampleRate	==	44100)	sr_val	=	FS_44KHZ;
	else if(hdr->SampleRate	==	48000)	sr_val	=	FS_48KHZ;
	else if(hdr->SampleRate	==	88200)	sr_val	=	FS_88KHZ;
	else 								sr_val	=	FS_96KHZ;	//default is 96KHz

	if(codec_config_reg(CODEC_SR_IDX, CODEC_SR_OFFST, CODEC_SR_MSK, sr_val))	return	I2C_NACK_DETECTED;

	//Update MCLK
	if((hdr->SampleRate == 44100) || (hdr->SampleRate == 88200)){
		update_mclk(CORTEX_MM_SL_BASE, CLK_11MHZ);
	}
	else{
		update_mclk(CORTEX_MM_SL_BASE, CLK_12MHZ);
	}

	enable_fgyrus(CORTEX_MM_SL_BASE,(FGYRUS_TYPE)0);	//by default
	if(hdr->NumChannels > 1)	enable_fgyrus(CORTEX_MM_SL_BASE,(FGYRUS_TYPE)1);

	enable_dac_drvr(CORTEX_MM_SL_BASE);




	return I2C_OK;
}

