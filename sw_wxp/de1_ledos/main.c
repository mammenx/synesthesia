/*
 * main.c
 *
 *  Created on: May 13, 2012
 *      Author: Gregory James
 */
#define __MAIN_C__

#include "sys/alt_stdio.h"

/*=========================================================================*/
/*  Includes                                                               */
/*=========================================================================*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "ch.h"
#include "ledos/shell/shell.h"
#include "ledos/shell/bash.h"
#include "ledos/fatfs/ff.h"
#include "ledos/ledos.h"



/*=========================================================================*/
/*  DEFINE: All Structures and Common Constants                            */
/*=========================================================================*/

/*
 * Priority and stack size of the task.
 */
#define TASK_HP_PRIORITY   (NORMALPRIO + 3)
#define TASK_LP_PRIORITY   (NORMALPRIO + 2)



#define TASK_HP_STK_SIZE   64
#define TASK_LP_STK_SIZE   64
#define TASK_PWM_STK_SIZE  1024



/*=========================================================================*/
/*  DEFINE: Definition of all local Data                                   */
/*=========================================================================*/

static WORKING_AREA(HPStack, TASK_HP_STK_SIZE);
static WORKING_AREA(LPStack, TASK_LP_STK_SIZE);
static WORKING_AREA(PWMStack, TASK_PWM_STK_SIZE);

/*=========================================================================*/
/*  DEFINE: Definition of all local Procedures                             */
/*=========================================================================*/

/***************************************************************************/
/*  HPTask                                                                 */
/*                                                                         */
/*  In    : task parameter                                                 */
/*  Out   : none                                                           */
/*  Return: never                                                          */
/***************************************************************************/
#define	PWM_SLEEP_TICKS	100

static msg_t PWMTask (void *p)
{
	alt_u32 i,j;
	alt_u16 pwm_bffr[VCORTEX_PWM_CHNNLS];

	for(i=0;i<VCORTEX_PWM_CHNNLS;i++){
		pwm_bffr[i] = 0x0;
	}

	pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);

    chThdSleepMilliseconds(PWM_SLEEP_TICKS);

	   pwm_bffr[0]	=	0xffff;

   while(1)
   {
	   //pwm_bffr[0]	=	0xffff;
	   //pwm_bffr[VCORTEX_PWM_CHNNLS-1]	=	0x0;
	   pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);
	   chThdSleepMilliseconds(PWM_SLEEP_TICKS);

	   for(i=0; i<VCORTEX_PWM_CHNNLS; i++){
		   pwm_bffr[VCORTEX_PWM_CHNNLS-1]	+=	pwm_bffr[VCORTEX_PWM_CHNNLS-2];

		   for(j=VCORTEX_PWM_CHNNLS-2; j>=2; j--){
			   pwm_bffr[j]	=	pwm_bffr[j-1];
		   }

		   pwm_bffr[0]	-=	1<<(VCORTEX_PWM_CHNNLS -1 - i);
		   pwm_bffr[1]	=	1<<(VCORTEX_PWM_CHNNLS -1 - i);

		   pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);
		   chThdSleepMilliseconds(PWM_SLEEP_TICKS);
	   }

	   pwm_bffr[0]	=	0;
	   pwm_bffr[1]	=	0;

	   for(i=0; i<VCORTEX_PWM_CHNNLS; i++){
		   pwm_bffr[VCORTEX_PWM_CHNNLS-1]	+=	pwm_bffr[VCORTEX_PWM_CHNNLS-2];

		   for(j=VCORTEX_PWM_CHNNLS-2; j>=2; j--){
			   pwm_bffr[j]	=	pwm_bffr[j-1];
		   }

		   pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);
		   chThdSleepMilliseconds(PWM_SLEEP_TICKS);
	   }

	   for(i=0; i<VCORTEX_PWM_CHNNLS; i++){
		   pwm_bffr[0]	+=	pwm_bffr[1];

		   for(j=1; j<VCORTEX_PWM_CHNNLS-2; j++){
			   pwm_bffr[j]	=	pwm_bffr[j+1];
		   }

		   pwm_bffr[VCORTEX_PWM_CHNNLS-1]	-=	1<<(VCORTEX_PWM_CHNNLS -1 - i);
		   pwm_bffr[VCORTEX_PWM_CHNNLS-2]	=	1<<(VCORTEX_PWM_CHNNLS -1 - i);

		   pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);
		   chThdSleepMilliseconds(PWM_SLEEP_TICKS);
	   }

	   pwm_bffr[VCORTEX_PWM_CHNNLS-1]	=	0;
	   pwm_bffr[VCORTEX_PWM_CHNNLS-2]	=	0;

	   for(i=0; i<VCORTEX_PWM_CHNNLS; i++){
		   pwm_bffr[0]	+=	pwm_bffr[1];

		   for(j=1; j<VCORTEX_PWM_CHNNLS-2; j++){
			   pwm_bffr[j]	=	pwm_bffr[j+1];
		   }

		   pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);
		   chThdSleepMilliseconds(PWM_SLEEP_TICKS);
	   }
   }

   return(0);

} /* HPTask */

static msg_t SynTask (void *p)
{
	alt_u8 i;
	alt_u16 pwm_bffr[VCORTEX_PWM_CHNNLS];
	alt_u32	lfft_bffr[FFT_NUM_SAMPLES],rfft_bffr[FFT_NUM_SAMPLES];

	while(1){
		read_fft_cache(lfft_bffr, rfft_bffr, 64);

		for(i=0; i<VCORTEX_PWM_CHNNLS; i++){
			//pwm_bffr[i]	=	(alt_u16)(lfft_bffr[i]	>>	16);
			//pwm_bffr[i]	=	pwm_bffr[i]	<<	12;

			pwm_bffr[i]	=	(alt_u16)(lfft_bffr[i]	<<	14);
		}

		pwm_paint(CORTEX_MM_SL_BASE, pwm_bffr);
		chThdSleepMilliseconds(1);
	}
}

/*=========================================================================*/
/*  DEFINE: All code exported                                              */
/*=========================================================================*/
/***************************************************************************/
/*  main                                                                   */
/*                                                                         */
/*  Note: ChibiOS/RT initialization.                                       */
/*        The ChibiOS/RT system was still init (chSysInit) before          */
/*        by the Nios system (ALT_OS_INIT). At this point all ChibiOS/RT   */
/*        function can be used.                                            */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: never                                                          */
/***************************************************************************/
int main (void)
{

	alt_printf("Hello from NIOS II ...\r\n");


	init_ledos(FS_32KHZ, BPS_16);



   /*
    * Normal main() thread activity.
    */
   while(1)
   {
      chThdSleepMilliseconds(500);
   }

   /*
    * This return here make no sense. But to prevent the compiler warning:
    * "return type of 'main' is not 'int'
    * An int as return is used :-)
    */
   return(0);
} /* main */
