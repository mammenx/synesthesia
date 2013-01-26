/*
    ChibiOS/RT - Copyright (C) 2006,2007,2008,2009,2010,2011 Giovanni Di Sirio.

    This file is part of ChibiOS/RT.

    ChibiOS/RT is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    ChibiOS/RT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

                                      ---

    A special exception to the GPL can be applied should you wish to distribute
    a combined work that includes ChibiOS/RT, without being obliged to provide
    the source code for any proprietary components. See the file exception.txt
    for full details of how and when the exception can be applied.
*/

/**
 * @file    NIOSII/chcore.h
 * @brief   NIOSII architecture port macros and structures.
 *
 * @addtogroup NIOSII_CORE
 * @{
 */

#ifndef _CHCORE_H_
#define _CHCORE_H_

#include <system.h>
#include <sys/alt_irq.h>

/*===========================================================================*/
/* Port constants.                                                           */
/*===========================================================================*/

/*===========================================================================*/
/* Port macros.                                                              */
/*===========================================================================*/

/*===========================================================================*/
/* Port configurable parameters.                                             */
/*===========================================================================*/

/**
 * @brief   Stack size for the system idle thread.
 * @details This size depends on the idle thread implementation, usually
 *          the idle thread should take no more space than those reserved
 *          by @p PORT_INT_REQUIRED_STACK.
 */
#ifndef PORT_IDLE_THREAD_STACK_SIZE
#define PORT_IDLE_THREAD_STACK_SIZE     128
#endif

/**
 * @brief   Per-thread stack overhead for interrupts servicing.
 * @details This constant is used in the calculation of the correct working
 *          area size.
 *          This value can be zero on those architecture where there is a
 *          separate interrupt stack and the stack space between @p intctx and
 *          @p extctx is known to be zero.
 */
#ifndef PORT_INT_REQUIRED_STACK
#define PORT_INT_REQUIRED_STACK         128
#endif

/**
 * @brief   Enables the use of a wait state in the idle thread loop.
 */
#ifndef ENABLE_WFI_IDLE
#define ENABLE_WFI_IDLE       0
#endif

/*===========================================================================*/
/* Port derived parameters.                                                  */
/*===========================================================================*/

/*===========================================================================*/
/* Port exported info.                                                       */
/*===========================================================================*/

/**
 * @brief   Macro defining the NIOSII architecture.
 */
#define CH_ARCHITECTURE_NIOSII

/**
 * @brief   Name of the implemented architecture.
 */
#define CH_ARCHITECTURE_NAME  "Nios II"

/**
 * @brief   Name of the architecture variant (optional).
 */
#define CH_CORE_VARIANT_NAME  ALT_CPU_CPU_IMPLEMENTATION

/**
 * @brief   Name of the compiler supported by this port.
 */
#define CH_COMPILER_NAME                "GCC"

/**
 * @brief   Port-specific information string.
 */
#define CH_PORT_INFO                    ""

/*===========================================================================*/
/* Port implementation part.                                                 */
/*===========================================================================*/

/**
 * @brief   Base type for stack and memory alignment.
 */
typedef uint32_t stkalign_t;

/**
 * @brief   Generic NIOSII register.
 */
typedef uint32_t regniosii_t;

/**
 * @brief   Interrupt saved context.
 * @details This structure represents the stack frame saved during a
 *          preemption-capable interrupt handler.
 */
struct extctx {      /* 19 registers = 76 bytes */
  regniosii_t  ra;
  
  /*
   * Leave a gap in the stack frame at 4(sp) for the muldiv handler to
   * store zero into.
   */
  regniosii_t  gap;

  regniosii_t  r1;
  regniosii_t  r2;
  regniosii_t  r3;
  regniosii_t  r4;
  regniosii_t  r5;
  regniosii_t  r6;
  regniosii_t  r7;
  regniosii_t  r8;
  regniosii_t  r9;
  regniosii_t  r10;
  regniosii_t  r11;
  regniosii_t  r12;
  regniosii_t  r13;
  regniosii_t  r14;
  regniosii_t  r15;
  
  regniosii_t  etatus;
  regniosii_t  ea;
  
};

/**
 * @brief   System saved context.
 * @details This structure represents the inner stack frame during a context
 *          switching.
 */
struct intctx {      /* 11 register = 44 bytes */
  regniosii_t  ra;
  regniosii_t  fp;

  regniosii_t  r16;
  regniosii_t  r17;
  regniosii_t  r18;
  regniosii_t  r19;
  regniosii_t  r20;
  regniosii_t  r21;
  regniosii_t  r22;
  regniosii_t  r23;
  
  regniosii_t  status;
};

/**
 * @brief   Platform dependent part of the @p Thread structure.
 * @details This structure usually contains just the saved stack pointer
 *          defined as a pointer to a @p intctx structure.
 */
struct context {
  struct intctx *sp;
};

/**
 * @brief   Platform dependent part of the @p chThdInit() API.
 * @details This code usually setup the context switching frame represented
 *          by an @p intctx structure.
 */
#define SETUP_CONTEXT(workspace, wsize, pf, arg) {          \
  tp->p_ctx.sp = (struct intctx *)((uint8_t *)workspace +   \
                                   wsize -                  \
                                   sizeof(struct intctx));  \
                                                            \
  tp->p_ctx.sp->r16    = (regniosii_t)pf;                   \
  tp->p_ctx.sp->r17    = (regniosii_t)arg;                  \
  tp->p_ctx.sp->r18    = 0x18181818;                        \
  tp->p_ctx.sp->r19    = 0x19191919;                        \
  tp->p_ctx.sp->r20    = 0x20202020;                        \
  tp->p_ctx.sp->r21    = 0x21212121;                        \
  tp->p_ctx.sp->r22    = 0x22222222;                        \
  tp->p_ctx.sp->r23    = 0x23232323;                        \
  tp->p_ctx.sp->status = NIOS2_STATUS_PIE_MSK;              \
  tp->p_ctx.sp->fp     = 0x28282828;                        \
  tp->p_ctx.sp->ra     = (regniosii_t)_port_thread_start;   \
                                                            \
}

/**
 * @brief   Enforces a correct alignment for a stack area size value.
 */
#define STACK_ALIGN(n) ((((n) - 1) | (sizeof(stkalign_t) - 1)) + 1)

/**
 * @brief   Computes the thread working area global size.
 */
#define THD_WA_SIZE(n) STACK_ALIGN(sizeof(Thread) +                     \
                                   sizeof(struct intctx) +              \
                                   sizeof(struct extctx) +              \
                                   (n) + (PORT_INT_REQUIRED_STACK))

/**
 * @brief   Static working area allocation.
 * @details This macro is used to allocate a static thread working area
 *          aligned as both position and size.
 */
#define WORKING_AREA(s, n) stkalign_t s[THD_WA_SIZE(n) / sizeof(stkalign_t)]

/**
 * @brief   IRQ prologue code.
 * @details This macro must be inserted at the start of all IRQ handlers
 *          enabled to invoke system APIs.
 * @note    This function is empty in this port. 
 */
#define PORT_IRQ_PROLOGUE()

/**
 * @brief   IRQ epilogue code.
 * @details This macro must be inserted at the end of all IRQ handlers
 *          enabled to invoke system APIs.
 * @note    This function is empty in this port. 
 */
#define PORT_IRQ_EPILOGUE()

/**
 * @brief   IRQ handler function declaration.
 * @note    @p id can be a function name or a vector number depending on the
 *          port implementation.
 */
#define PORT_IRQ_HANDLER(id) void id(void)

/**
 * @brief   Port-related initialization code.
 * @note    This function is empty in this port.
 */
#define port_init()

/**
 * @brief   Kernel-lock action.
 * @details Usually this function just disables interrupts but may perform more
 *          actions.
 * @note    Implemented as global interrupt disable.
 */
#define port_lock()     alt_irq_disable_all()

/**
 * @brief   Kernel-unlock action.
 * @details Usually this function just enables interrupts but may perform more
 *          actions.
 * @note    Implemented as global interrupt enable.
 */
#define port_unlock()   alt_irq_enable_all(NIOS2_STATUS_PIE_MSK)

/**
 * @brief   Kernel-lock action from an interrupt handler.
 * @details This function is invoked before invoking I-class APIs from
 *          interrupt handlers. The implementation is architecture dependent,
 *          in its simplest form it is void.
 * @note    This function is empty in this port.
 */
#define port_lock_from_isr()

/**
 * @brief   Kernel-unlock action from an interrupt handler.
 * @details This function is invoked after invoking I-class APIs from interrupt
 *          handlers. The implementation is architecture dependent, in its
 *          simplest form it is void.
 * @note    This function is empty in this port.
 */
#define port_unlock_from_isr()

/**
 * @brief   Disables all the interrupt sources.
 * @note    Of course non maskable interrupt sources are not included.
 * @note    Implemented as global interrupt disable.
 */
#define port_disable()  alt_irq_disable_all()

/**
 * @brief   Disables the interrupt sources below kernel-level priority.
 * @note    Interrupt sources above kernel level remains enabled.
 * @note    Same as @p port_disable() in this port, there is no difference
 *          between the two states.
 */
#define port_suspend()  alt_irq_disable_all()

/**
 * @brief   Enables all the interrupt sources.
 * @note    Implemented as global interrupt enable.
 */
#define port_enable()   alt_irq_enable_all(NIOS2_STATUS_PIE_MSK)

/**
 * @brief   Enters an architecture-dependent IRQ-waiting mode.
 * @details The function is meant to return when an interrupt becomes pending.
 *          The simplest implementation is an empty function or macro but this
 *          would not take advantage of architecture-specific power saving
 *          modes.
 * @note    This port function is implemented as inlined code for performance
 *          reasons.
 * @note    The port code does not define a low power mode, this macro has to
 *          be defined externally. The default implementation is a "nop", not
 *          a real low power mode.
 */
#if ENABLE_WFI_IDLE != 0
#ifndef port_wait_for_interrupt
#define port_wait_for_interrupt() {    \
  asm volatile ("nop");                \
}
#endif
#else
#define port_wait_for_interrupt() {    \
  asm volatile ("nop");                \
}
#endif

/**
 * @brief   __alt_heap_start and __alt_heap_limit is defined by Nios II SBT, 
 * but ChibiOS use __heap_base__and __heap_end__.
 */
#define __heap_base__      __alt_heap_start
#define __heap_end__       __alt_heap_limit


#ifdef __cplusplus
extern "C" {
#endif
  void port_switch(Thread *ntp, Thread *otp);
  void port_halt(void);
  void _port_thread_start(void);
  void port_time_tick (void);
#ifdef __cplusplus
}
#endif

#endif /* _CHCORE_H_ */

/** @} */
