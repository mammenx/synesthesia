/****************************************************************************
*  Copyright (c) 2011 by Michael Fischer. All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without 
*  modification, are permitted provided that the following conditions 
*  are met:
*  
*  1. Redistributions of source code must retain the above copyright 
*     notice, this list of conditions and the following disclaimer.
*  2. Redistributions in binary form must reproduce the above copyright
*     notice, this list of conditions and the following disclaimer in the 
*     documentation and/or other materials provided with the distribution.
*  3. Neither the name of the author nor the names of its contributors may 
*     be used to endorse or promote products derived from this software 
*     without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
*  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
*  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
*  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
*  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
*  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
*  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
*  SUCH DAMAGE.
*
*****************************************************************************
*  History:
*
*  30.10.2011  mifi  First Version, tested with an Altera DE1 board.
****************************************************************************/


#include "system.h"

      .text

      .global _port_thread_start
      .global port_switch
      
/***************************************************************************/
/*  void _port_thread_start(void)                                          */
/*                                                                         */
/*  Copy the tread argument from r17 and the thread pointer from r16 which */
/*  was was stored by SETUP_CONTEXT.                                       */
/*                                                                         */
/*  Start a thread by invoking its work function.                          */
/***************************************************************************/
_port_thread_start:

      mov   r4, r17        /* r4 = Register Arguments (First 32 bits) */
      mov   r5, r16        /* Store thread pointer for the callr,     */
      callr r5             /* and call the thread */
      call  chThdExit      /* This is the thread exit function. */
      
_port_thread_start_loop:      
      br    _port_thread_start_loop
      

            
/***************************************************************************/
/*  void port_switch(Thread *ntp, Thread *otp)                             */
/*                                                                         */
/*  Performs a context switch between two threads.                         */
/*                                                                         */
/*  This is the most critical code in any port, this function is           */
/*  responsible for the context switch between 2 threads.                  */
/*                                                                         */
/*  Note:                                                                  */
/*       The implementation of this code affects directly the context      */
/*       switch performance so optimize here as much as you can.           */
/*  Parameters:                                                            */
/*       [in]  ntp  the thread to be switched in                           */
/*       [in]  otp  the thread to be switched out                          */
/***************************************************************************/
port_switch:

      /* r4 = ntp, r5 = otp */

      addi  sp, sp, -44    /* Size of the intctx structure */
      
      stw   ra,   0(sp)
      stw   fp,   4(sp)
      stw   r16,  8(sp)
      stw   r17, 12(sp)
      stw   r18, 16(sp)
      stw   r19, 20(sp)
      stw   r20, 24(sp)
      stw   r21, 28(sp)
      stw   r22, 32(sp)
      stw   r23, 36(sp)
      
      rdctl r23, status    /* r23 is not more needed and can */
      stw   r23, 40(sp)    /* be used here to store the status */
      
      stw   sp, 12(r5)     /* Save old stack: otp->p_ctx.sp = sp */
      
      ldw   sp, 12(r4)     /* Get new stack: sp = ntp->p_ctx.sp */
      
      ldw   ra,   0(sp)
      ldw   fp,   4(sp)
      ldw   r16,  8(sp)
      ldw   r17, 12(sp)
      ldw   r18, 16(sp)
      ldw   r19, 20(sp)
      ldw   r20, 24(sp)
      ldw   r21, 28(sp)
      ldw   r22, 32(sp)
      ldw   r23, 36(sp)
      
      ldw   r4,  40(sp)    /* r4 is not more needed and can */
      wrctl status, r4     /* be used here to store the status */
      
      addi  sp, sp, 44     /* Size of the intctx structure */
      
      ret
   
      nop


/*** EOF ***/
