/*
 * ledos.h
 *
 *  Created on: Jun 16, 2012
 *      Author: Gregory James
 */
#include "ch.h"
#include "codec/codec.h"
#include "cortex/cortex.h"
#include "fft_cache/fft_cache.h"
#include "fatfs/ff.h"
#include "system.h"
#include "ledos_types.h"
#include "lsd/lsd.h"


#ifndef LEDOS_H_
#define LEDOS_H_

#define SHELL_PRIORITY     (NORMALPRIO + 1)
#define SHELL_WA_SIZE      73728

#define TASK_ACID_PRIORITY 	(NORMALPRIO + 3)
#define TASK_ACID_SIZE  	1024


void init_ledos(FS_T fs, BPS_T bps);

//Size of stream block
#define	AUD_STREAM_BLK_SIZE			65536

//Size of working area
#define	AUD_STREAM_WRK_AREA_SIZE	((AUD_STREAM_BLK_SIZE*2) + 1024)

//Working area for Audio Streamer thread
static WORKING_AREA(AudStreamWorkingArea, AUD_STREAM_WRK_AREA_SIZE);

static alt_u32	aud_bytes_read;

typedef	struct	{
	FIL fil;			/* File object 	*/
	char * fname;		/*	File name	*/
}AudStreamType;

//Critical Audio Streamer thread
msg_t audio_streamer(void *p);

//Callback function for DMA xfrs
void update_aud_bytes_read(void *p);

typedef	struct	{
  alt_u32 ChunkID      ;
  alt_u32 ChunkSize    ;
  alt_u32 Format       ;


  alt_u32 Subchunk1ID  ;
  alt_u32 Subchunk1Size;
  alt_u16 AudioFormat  ;
  alt_u16 NumChannels  ;
  alt_u32 SampleRate   ;
  alt_u32 ByteRate     ;
  alt_u16 BlockAlign   ;
  alt_u16 BitsPerSample;
  alt_u16 Extra;

  alt_u32 Subchunk2ID  ;
  alt_u32 Subchunk2Size;

}WavHdrType;

//Wave parse function
alt_u32 wave_parse(WavHdrType * hdr);

//Display Wave Header function
void printf_wave_hdr(WavHdrType *hdr);

//Check if the Wave header is correct
alt_u32 chk_wav_hdr(WavHdrType *hdr);

//Byte swap functions
void byte_swap16(alt_u16 *data);
void byte_swap32(alt_u32 *data);

/*	Function to configure acortex & fgyrus blocks based on parsed wavheader	*/
I2C_RES prep_cortex(WavHdrType * hdr);


#endif /* LEDOS_H_ */
