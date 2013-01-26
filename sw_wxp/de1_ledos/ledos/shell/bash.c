/*
 * bash.c
 *
 *  Created on: Jun 16, 2012
 *      Author: Gregory James
 */

#include <stdio.h>
#include <string.h>


#include "ch.h"
#include "shell.h"
#include "bash.h"
#include "sys/alt_stdio.h"
#include "altera_avalon_performance_counter.h"
#include "../fatfs/ff.h"
#include "system.h"
#include "../lsd/lsd.h"
#include "../cortex/cortex.h"
#include "../fft_cache/fft_cache.h"


FATFS bash_Fatfs;		/* File system object */
FIL bash_Fil;			/* File object */
//BYTE bash_Buff[128];	/* File read buffer */
BYTE bash_Buff[65536];	/* File read buffer */
FRESULT bash_rc;		/* Result code */
DIR bash_dir;			/* Directory object */
FILINFO bash_fno;		/* File information object */
static acid_t	current_acid;	/* Holds information on present plugin	*/
static char*	current_acid_str;	/* Holds name of present plugin	*/
static Thread *acid_tp=NULL;	/*	Pointer to running plugin thread	*/
static Thread *bash_tp=NULL;	/*	Pointer to running bash thread	*/

/*---------------------------------------------------------*/
// User Function	:	cmd_mem
// 		-	Display Memory Utilisation
/*---------------------------------------------------------*/
static void cmd_mem(int argc, char *argv[]) {
  size_t n, size;

  (void)argv;
  if (argc > 0) {
	  alt_printf("Usage: mem\r\n");
    return;
  }

  n = chHeapStatus(NULL, &size);

  printf("core free memory : %u bytes\r\n", chCoreStatus());
  printf("heap fragments   : %u\r\n", n);
  printf("heap free total  : %u bytes\r\n", size);
}


/*---------------------------------------------------------*/
// User Function	:	cmd_touch
// 		-	Create empty file in current directory
/*---------------------------------------------------------*/
static void cmd_touch(int argc, char *argv[]) {

  (void)argv;
  if ((argc != 1)	||	(strcasecmp(argv[0],"--help") == 0)) {
	  alt_printf("Usage: touch <filename>\r\n");
    return;
  }

  bash_rc = f_open(&bash_Fil, argv[0], FA_CREATE_NEW);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  bash_rc = f_close(&bash_Fil);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  return;
}

/*---------------------------------------------------------*/
// User Function	:	cmd_mv
// 		-	Rename file
/*---------------------------------------------------------*/
static void cmd_mv(int argc, char *argv[]) {

  (void)argv;
  if ((argc != 2)	||	(strcasecmp(argv[0],"--help") == 0)) {
	  alt_printf("Usage: mv <existing_filename> <new_filename>\r\n");
    return;
  }

  bash_rc = f_rename(argv[0], argv[1]);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  return;
}


/*---------------------------------------------------------*/
// User Function	:	cmd_cd
// 		-	Change Directory
/*---------------------------------------------------------*/
static void cmd_cd(int argc, char *argv[]) {

  (void)argv;
  if ((argc != 1)	||	(strcasecmp(argv[0],"--help") == 0)) {
	  alt_printf("Usage: cd <destination_dir>\r\n");
    return;
  }

  bash_rc = f_chdir(argv[0]);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  return;
}

/*---------------------------------------------------------*/
// User Function	:	cmd_pwd
// 		-	Get Present Working Directory
/*---------------------------------------------------------*/
static void cmd_pwd(int argc, char *argv[]) {

  (void)argv;
  if (argc > 0) {
	  alt_printf("Usage: pwd\r\n");
    return;
  }

  bash_rc = f_getcwd((TCHAR*)bash_Buff,sizeof(bash_Buff));
  if(bash_rc){
	  alt_printf("%s\r\n",decode_fres(bash_rc));
  }
  else{
	  alt_printf("%s\r\n",bash_Buff);
  }

  return;
}

/*---------------------------------------------------------*/
// User Function	:	cmd_ll
// 		-	List folder entries under pwd
/*---------------------------------------------------------*/
static void cmd_ll(int argc, char *argv[]) {

  (void)argv;
  if (argc > 0) {
	  alt_printf("Usage: ll\r\n");
    return;
  }

  bash_rc = f_getcwd((TCHAR*)bash_Buff,sizeof(bash_Buff)); //read pwd into buffer
  if(bash_rc){
	  alt_printf("Could not get pwd - %s\r\n",decode_fres(bash_rc));
	  return;
  }

  bash_rc = f_opendir(&bash_dir, (TCHAR*)bash_Buff);
  if(bash_rc)	alt_printf("Could not open pwd - %s\r\n",decode_fres(bash_rc));

  for (;;) {
	  bash_rc = f_readdir(&bash_dir, &bash_fno);		// Read a directory item
	if (bash_rc || !bash_fno.fname[0]) break;	// Error or end of dir
	if (bash_fno.fattrib & AM_DIR)
		alt_printf("   <dir>  %s\r\n", bash_fno.fname);
	else
		printf("%8lu  %s\r\n", bash_fno.fsize, bash_fno.fname);
  }
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  return;
}

/*---------------------------------------------------------*/
// User Function	:	cmd_cat
// 		-	Display file contents (preferably text files)
/*---------------------------------------------------------*/
static void cmd_cat(int argc, char *argv[]) {
	UINT br,i;

  (void)argv;
  if ((argc != 1)	||	(strcasecmp(argv[0],"--help") == 0)) {
	  alt_printf("Usage: cat <filename>\r\n");
    return;
  }

  bash_rc = f_open(&bash_Fil, argv[0], FA_READ);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  for (;;) {
	  bash_rc = f_read(&bash_Fil, bash_Buff, sizeof(bash_Buff), &br);	// Read a chunk of file
	if (bash_rc || !br) break;			// Error or end of file
	for (i = 0; i < br; i++)		// Type the data
		alt_putchar(bash_Buff[i]);
  }
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  bash_rc = f_close(&bash_Fil);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  return;
}


/*---------------------------------------------------------*/
// User Function	:	cmd_cath
// 		-	Display file contents in hex form
/*---------------------------------------------------------*/
static void cmd_cath(int argc, char *argv[]) {
	UINT br,i;

  (void)argv;
  if ((argc != 1)	||	(strcasecmp(argv[0],"--help") == 0)) {
	  alt_printf("Usage: cath <filename>\r\n");
    return;
  }

  bash_rc = f_open(&bash_Fil, argv[0], FA_READ);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  for (;;) {
	  bash_rc = f_read(&bash_Fil, bash_Buff, sizeof(bash_Buff), &br);	// Read a chunk of file
	if (bash_rc || !br) break;			// Error or end of file
	for (i = 0; i < br; i++){		// Type the data
		if((i%16) == 0){
			alt_printf("\r\n");
		}
		alt_printf("%x ",bash_Buff[i]);
	}
  }

  alt_printf("\r\n");

  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  bash_rc = f_close(&bash_Fil);
  if(bash_rc)	alt_printf("%s\r\n",decode_fres(bash_rc));

  return;
}

/*---------------------------------------------------------*/
// User Function	:	cmd_perf
// 		-	Runs the performance test for reading given file
//			from SDCARD
//		-	Input file must be at least 4KB in size
/*---------------------------------------------------------*/
static void cmd_perf(int argc, char *argv[]) {
	UINT br,i,size;

	(void)argv;

	if ((argc != 1)	||	(strcasecmp(argv[0],"--help") == 0)) {
		alt_printf("Usage: perf <filename>\r\n");
		return;
	}

	alt_printf("Reseting Performance Counter ...\r\n");
	PERF_RESET(PERF_CNTR_BASE);

    chThdSleepMilliseconds(3000);

	alt_printf("Starting Performance Counter ...\r\n");
	PERF_START_MEASURING(PERF_CNTR_BASE);

	for(i=1,size=sizeof(bash_Buff)>>2;i<=3;i++,size=size<<1){
	      chThdSleepMilliseconds(1000);

		  printf("Starting Test[%d] - Read %dB from SDCARD\r\n",i,size);

		  bash_rc = f_open(&bash_Fil, argv[0], FA_READ);
		  if(bash_rc)	break;

		  PERF_BEGIN(PERF_CNTR_BASE,i);
		  bash_rc = f_read(&bash_Fil, bash_Buff, size, &br);	// Read a chunk of file
		  PERF_END(PERF_CNTR_BASE,i);

		  if(bash_rc || !br) break;			// Error or end of file

		  bash_rc = f_close(&bash_Fil);

		  if(bash_rc) break;			// Error or end of file
	}

    chThdSleepMilliseconds(1000);

	alt_printf("Stopping Performance Counter ...\r\n");
	PERF_STOP_MEASURING(PERF_CNTR_BASE);

    chThdSleepMilliseconds(3000);

	if(bash_rc){
		alt_printf("%s\r\n",decode_fres(bash_rc));
	}
	else{
		perf_print_formatted_report(PERF_CNTR_BASE,
									alt_get_cpu_freq(),
									3,
									"16KB_read",
									"32KB_read",
									"64KB_read"
									);
	}

	return;
}


bool_t	update_acid(const Acid *ad, char *name){
	while (ad->acid_name != NULL) {
		if (strcasecmp(ad->acid_name, name) == 0) {
		  current_acid		=	ad->acid_function;
		  current_acid_str	=	ad->acid_name;
		  return FALSE;
		}
		ad++;
	}

	return TRUE;
}

void acid_thread(void *p){
	alt_u16 pwm_bffr[VCORTEX_PWM_CHNNLS];
	alt_u32	lfft_bffr[FFT_NUM_SAMPLES],rfft_bffr[FFT_NUM_SAMPLES];

	acid_tp	=	chThdSelf();	//make a copy of this thread

	while(1){
		chMsgWait();	//Suspend this thread & wait for go signal
						//This thread starts in suspended state

		chMsgRelease(bash_tp, (msg_t)0);	//Send dummy response/ack to bash

		while(!chMsgIsPendingI(acid_tp)){	//As long as there is no msg/signal from bash
			read_fft_cache(lfft_bffr, rfft_bffr, FFT_NUM_SAMPLES);	//read from FFT cache

			current_acid(0,lfft_bffr,rfft_bffr,pwm_bffr);

			pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);
			chThdSleepMilliseconds(1);
		}

		chMsgWait();						//Suspend this thread & pop dummy message from its fifo
		chMsgRelease(bash_tp, (msg_t)0);	//Send dummy response/ack to bash
	}

}

/*---------------------------------------------------------*/
// User Function	:	cmd_drop_acid
// 		-	Starts the visualization thread with the
//			selected plugin.
//		-	If no plugin name is specified, the present
//			value of plugin is used.
/*---------------------------------------------------------*/
static void cmd_drop_acid(int argc, char *argv[]) {
	short c;

	(void)argv;

	bash_tp	=	chThdSelf();	//make a copy of this thread


	if ((argc > 1) || (strcasecmp(argv[0],"--help") == 0)) {
		alt_printf("Usage: drop_acid <plugin_name>\r\n");
		return;
	}

	if(argc){
		if(update_acid(get_acid_box(), argv[0])){
			printf("Plugin <%s> not found ... Bummer man :-(\r\n",argv[0]);
			return;
		}
	}


	alt_printf("Starting Cortex engines \r\n");

	enable_fgyrus(CORTEX_MM_SL_BASE, LCHNL);
	enable_fgyrus(CORTEX_MM_SL_BASE, RCHNL);
	enable_adc_drvr(CORTEX_MM_SL_BASE);


	if(acid_tp == NULL){
		alt_printf("acid_thread not started\r\nExiting ...\r\n");
		return;
	}


	printf("Starting plugin : %s\r\nPress 'q' to stop ...\r\n",current_acid_str);

	chMsgSend(acid_tp, (msg_t)1);	//Send dummy message to acid_thread to start it.
									//This thread is stopped until chMsgWait() is executed
									//from acid_thread.

	while(1){
		c = (short)alt_getchar();	//read single character

		if(c == 'q'){
			break;
		}
		else{
			chThdSleepMilliseconds(100);
		}
	}

	alt_printf("Stopping plugin ...\r\n");

	chMsgSend(acid_tp, (msg_t)1);	//Send dummy message to acid_thread to stop it.
									//This thread is stopped until chMsgWait() is executed
									//from acid_thread.

	alt_printf("Shutting down Cortex engines\r\n");

	disable_fgyrus(CORTEX_MM_SL_BASE, LCHNL);
	disable_fgyrus(CORTEX_MM_SL_BASE, RCHNL);
	disable_adc_drvr(CORTEX_MM_SL_BASE);


	alt_printf("End of Trip ...\r\n");

	return;
}

Thread *acidThreadCreateStatic(void *wsp, size_t size, tprio_t prio) {

  return chThdCreateStatic(wsp, size, prio, acid_thread, NULL);
}

static const ShellCommand commands[] = {
  {"mem", cmd_mem},
  {"touch", cmd_touch},
  {"mv", cmd_mv},
  {"cd", cmd_cd},
  {"pwd", cmd_pwd},
  {"ll", cmd_ll},
  {"cat", cmd_cat},
  {"cath", cmd_cath},
  {"perf", cmd_perf},
  {"drop_acid", cmd_drop_acid},
  {NULL, NULL}
};

static const ShellConfig shell_cfg1 = {
  commands
};


ShellConfig * get_usr_bash_config(void){
	return (ShellConfig  *)(&shell_cfg1);
}


void init_bash(void){
	f_mount(0, &bash_Fatfs);		/* Register volume work area (never fails) */
	alt_printf("Registered Bash-FATFs - fmount() done\r\n");

	PERF_RESET(PERF_CNTR_BASE);
	alt_printf("Reset Performance Counter [0x%x]\r\n",PERF_CNTR_BASE);

	return;
}
