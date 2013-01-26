/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'cpu' in SOPC Builder design 'limbus_sys'
 * SOPC Builder design path: ../../dgn/syn/limbus_sys.sopcinfo
 *
 * Generated: Sun Dec 16 01:20:22 IST 2012
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_qsys"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x1101820
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x19
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x800020
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x19
#define ALT_CPU_NAME "cpu"
#define ALT_CPU_RESET_ADDR 0x800000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x1101820
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x19
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x800020
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x19
#define NIOS2_RESET_ADDR 0x800000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_FIFO
#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_PERFORMANCE_COUNTER
#define __ALTERA_AVALON_SPI
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_TIMER
#define __ALTERA_AVALON_UART
#define __ALTERA_NIOS2_QSYS
#define __CORTEX_MM_SL
#define __FFT_CACHE_MM_SL


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone II"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x11020c0
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/uart_0"
#define ALT_STDIN_BASE 0x1102040
#define ALT_STDIN_DEV uart_0
#define ALT_STDIN_IS_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_uart"
#define ALT_STDOUT "/dev/uart_0"
#define ALT_STDOUT_BASE 0x1102040
#define ALT_STDOUT_DEV uart_0
#define ALT_STDOUT_IS_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_uart"
#define ALT_SYSTEM_NAME "limbus_sys"


/*
 * acortex_dc_fifo configuration
 *
 */

#define ACORTEX_DC_FIFO_AVALONMM_AVALONMM_DATA_WIDTH 32
#define ACORTEX_DC_FIFO_AVALONMM_AVALONST_DATA_WIDTH 32
#define ACORTEX_DC_FIFO_BASE 0x11020d0
#define ACORTEX_DC_FIFO_BITS_PER_SYMBOL 8
#define ACORTEX_DC_FIFO_CHANNEL_WIDTH 0
#define ACORTEX_DC_FIFO_ERROR_WIDTH 0
#define ACORTEX_DC_FIFO_FIFO_DEPTH 128
#define ACORTEX_DC_FIFO_IRQ -1
#define ACORTEX_DC_FIFO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ACORTEX_DC_FIFO_NAME "/dev/acortex_dc_fifo"
#define ACORTEX_DC_FIFO_SINGLE_CLOCK_MODE 0
#define ACORTEX_DC_FIFO_SPAN 8
#define ACORTEX_DC_FIFO_SYMBOLS_PER_BEAT 4
#define ACORTEX_DC_FIFO_TYPE "altera_avalon_fifo"
#define ACORTEX_DC_FIFO_USE_AVALONMM_READ_SLAVE 0
#define ACORTEX_DC_FIFO_USE_AVALONMM_WRITE_SLAVE 1
#define ACORTEX_DC_FIFO_USE_AVALONST_SINK 0
#define ACORTEX_DC_FIFO_USE_AVALONST_SOURCE 1
#define ACORTEX_DC_FIFO_USE_BACKPRESSURE 1
#define ACORTEX_DC_FIFO_USE_IRQ 1
#define ACORTEX_DC_FIFO_USE_PACKET 0
#define ACORTEX_DC_FIFO_USE_READ_CONTROL 0
#define ACORTEX_DC_FIFO_USE_REGISTER 0
#define ACORTEX_DC_FIFO_USE_WRITE_CONTROL 0
#define ALT_MODULE_CLASS_acortex_dc_fifo altera_avalon_fifo


/*
 * chibios_v240 configuration
 *
 */

#define CH_DBG_ENABLE_ASSERTS 0
#define CH_DBG_ENABLE_CHECKS 0
#define CH_DBG_ENABLE_STACK_CHECK 0
#define CH_DBG_ENABLE_TRACE 0
#define CH_DBG_FILL_THREADS 0
#define CH_DBG_SYSTEM_STATE_CHECK 0
#define CH_DBG_THREADS_PROFILING 1
#define CH_FREQUENCY TIMER_0_TICKS_PER_SEC
#define CH_MEMCORE_SIZE 0
#define CH_NO_IDLE_THREAD 0
#define CH_OPTIMIZE_SPEED 1
#define CH_TIME_QUANTUM 20
#define CH_USE_CONDVARS 1
#define CH_USE_CONDVARS_TIMEOUT 1
#define CH_USE_DYNAMIC 1
#define CH_USE_EVENTS 1
#define CH_USE_EVENTS_TIMEOUT 1
#define CH_USE_HEAP 1
#define CH_USE_MAILBOXES 1
#define CH_USE_MALLOC_HEAP 0
#define CH_USE_MEMCORE 1
#define CH_USE_MEMPOOLS 1
#define CH_USE_MESSAGES 1
#define CH_USE_MESSAGES_PRIORITY 0
#define CH_USE_MUTEXES 1
#define CH_USE_QUEUES 1
#define CH_USE_REGISTRY 1
#define CH_USE_SEMAPHORES 1
#define CH_USE_SEMAPHORES_PRIORITY 0
#define CH_USE_SEMSW 1
#define CH_USE_WAITEXIT 1


/*
 * cortex_mm_sl configuration
 *
 */

#define ALT_MODULE_CLASS_cortex_mm_sl cortex_mm_sl
#define CORTEX_MM_SL_BASE 0x1000000
#define CORTEX_MM_SL_IRQ 5
#define CORTEX_MM_SL_IRQ_INTERRUPT_CONTROLLER_ID 0
#define CORTEX_MM_SL_NAME "/dev/cortex_mm_sl"
#define CORTEX_MM_SL_SPAN 1048576
#define CORTEX_MM_SL_TYPE "cortex_mm_sl"


/*
 * fft_cache_mm_sl configuration
 *
 */

#define ALT_MODULE_CLASS_fft_cache_mm_sl fft_cache_mm_sl
#define FFT_CACHE_MM_SL_BASE 0x1100000
#define FFT_CACHE_MM_SL_IRQ -1
#define FFT_CACHE_MM_SL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define FFT_CACHE_MM_SL_NAME "/dev/fft_cache_mm_sl"
#define FFT_CACHE_MM_SL_SPAN 4096
#define FFT_CACHE_MM_SL_TYPE "fft_cache_mm_sl"


/*
 * hal configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK TIMER_0
#define ALT_TIMESTAMP_CLK none


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x11020c0
#define JTAG_UART_IRQ 0
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * perf_cntr configuration
 *
 */

#define ALT_MODULE_CLASS_perf_cntr altera_avalon_performance_counter
#define PERF_CNTR_BASE 0x1102000
#define PERF_CNTR_HOW_MANY_SECTIONS 3
#define PERF_CNTR_IRQ -1
#define PERF_CNTR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PERF_CNTR_NAME "/dev/perf_cntr"
#define PERF_CNTR_SPAN 64
#define PERF_CNTR_TYPE "altera_avalon_performance_counter"


/*
 * sdcard_spi configuration
 *
 */

#define ALT_MODULE_CLASS_sdcard_spi altera_avalon_spi
#define SDCARD_SPI_BASE 0x1102080
#define SDCARD_SPI_CLOCKMULT 1
#define SDCARD_SPI_CLOCKPHASE 0
#define SDCARD_SPI_CLOCKPOLARITY 0
#define SDCARD_SPI_CLOCKUNITS "Hz"
#define SDCARD_SPI_DATABITS 8
#define SDCARD_SPI_DATAWIDTH 16
#define SDCARD_SPI_DELAYMULT "1.0E-9"
#define SDCARD_SPI_DELAYUNITS "ns"
#define SDCARD_SPI_EXTRADELAY 0
#define SDCARD_SPI_INSERT_SYNC 0
#define SDCARD_SPI_IRQ 3
#define SDCARD_SPI_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SDCARD_SPI_ISMASTER 1
#define SDCARD_SPI_LSBFIRST 0
#define SDCARD_SPI_NAME "/dev/sdcard_spi"
#define SDCARD_SPI_NUMSLAVES 1
#define SDCARD_SPI_PREFIX "spi_"
#define SDCARD_SPI_SPAN 32
#define SDCARD_SPI_SYNC_REG_DEPTH 2
#define SDCARD_SPI_TARGETCLOCK 1000000u
#define SDCARD_SPI_TARGETSSDELAY "0.0"
#define SDCARD_SPI_TYPE "altera_avalon_spi"


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x800000
#define SDRAM_CAS_LATENCY 3
#define SDRAM_CONTENTS_INFO ""
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 2
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 100.0
#define SDRAM_REFRESH_PERIOD 15.625
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x16
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 8
#define SDRAM_SDRAM_DATA_WIDTH 16
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 12
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 0
#define SDRAM_SPAN 8388608
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 5.5
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 20.0
#define SDRAM_T_RFC 70.0
#define SDRAM_T_RP 20.0
#define SDRAM_T_WR 14.0


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid_qsys
#define SYSID_BASE 0x11020c8
#define SYSID_ID 666
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1354828801
#define SYSID_TYPE "altera_avalon_sysid_qsys"


/*
 * timer_0 configuration
 *
 */

#define ALT_MODULE_CLASS_timer_0 altera_avalon_timer
#define TIMER_0_ALWAYS_RUN 0
#define TIMER_0_BASE 0x1102060
#define TIMER_0_COUNTER_SIZE 32
#define TIMER_0_FIXED_PERIOD 0
#define TIMER_0_FREQ 100000000u
#define TIMER_0_IRQ 2
#define TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_0_LOAD_VALUE 99999ull
#define TIMER_0_MULT 0.0010
#define TIMER_0_NAME "/dev/timer_0"
#define TIMER_0_PERIOD 1
#define TIMER_0_PERIOD_UNITS "ms"
#define TIMER_0_RESET_OUTPUT 0
#define TIMER_0_SNAPSHOT 1
#define TIMER_0_SPAN 32
#define TIMER_0_TICKS_PER_SEC 1000u
#define TIMER_0_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_0_TYPE "altera_avalon_timer"


/*
 * timer_1us configuration
 *
 */

#define ALT_MODULE_CLASS_timer_1us altera_avalon_timer
#define TIMER_1US_ALWAYS_RUN 0
#define TIMER_1US_BASE 0x11020a0
#define TIMER_1US_COUNTER_SIZE 32
#define TIMER_1US_FIXED_PERIOD 1
#define TIMER_1US_FREQ 100000000u
#define TIMER_1US_IRQ 4
#define TIMER_1US_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_1US_LOAD_VALUE 99ull
#define TIMER_1US_MULT 1.0E-6
#define TIMER_1US_NAME "/dev/timer_1us"
#define TIMER_1US_PERIOD 1
#define TIMER_1US_PERIOD_UNITS "us"
#define TIMER_1US_RESET_OUTPUT 0
#define TIMER_1US_SNAPSHOT 1
#define TIMER_1US_SPAN 32
#define TIMER_1US_TICKS_PER_SEC 1000000u
#define TIMER_1US_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_1US_TYPE "altera_avalon_timer"


/*
 * uart_0 configuration
 *
 */

#define ALT_MODULE_CLASS_uart_0 altera_avalon_uart
#define UART_0_BASE 0x1102040
#define UART_0_BAUD 115200
#define UART_0_DATA_BITS 8
#define UART_0_FIXED_BAUD 1
#define UART_0_FREQ 100000000u
#define UART_0_IRQ 1
#define UART_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define UART_0_NAME "/dev/uart_0"
#define UART_0_PARITY 'N'
#define UART_0_SIM_CHAR_STREAM ""
#define UART_0_SIM_TRUE_BAUD 0
#define UART_0_SPAN 32
#define UART_0_STOP_BITS 1
#define UART_0_SYNC_REG_DEPTH 2
#define UART_0_TYPE "altera_avalon_uart"
#define UART_0_USE_CTS_RTS 0
#define UART_0_USE_EOP_REGISTER 0

#endif /* __SYSTEM_H_ */
