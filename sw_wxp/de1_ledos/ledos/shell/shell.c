/*
    ChibiOS/RT - Copyright (C) 2006,2007,2008,2009,2010,
                 2011,2012 Giovanni Di Sirio.

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
 * @file    shell.c
 * @brief   Simple CLI shell code.
 *
 * @addtogroup SHELL
 * @{
 */

#include <string.h>
#include <stdio.h>

#include "ch.h"
#include "shell.h"

#include "sys/alt_stdio.h"
#include "altera_avalon_performance_counter.h"


/**
 * @brief   Shell termination event source.
 */
EventSource shell_terminated;

static char *_strtok(char *str, const char *delim, char **saveptr) {
  char *token;
  if (str)
    *saveptr = str;
  token = *saveptr;

  if (!token)
    return NULL;

  token += strspn(token, delim);
  *saveptr = strpbrk(token, delim);
  if (*saveptr)
    *(*saveptr)++ = '\0';

  return *token ? token : NULL;
}

static void usage(char *p) {

	alt_printf("Usage: %s\r\n", p);
}

static void list_commands(const ShellCommand *scp) {

  while (scp->sc_name != NULL) {
	  alt_printf("\t%s\r\n", scp->sc_name);
    scp++;
  }
}

static void cmd_info(int argc, char *argv[]) {

  (void)argv;
  if (argc > 0) {
    usage("info");
    return;
  }

  alt_printf("Kernel:       %s\r\n", CH_KERNEL_VERSION);
#ifdef CH_COMPILER_NAME
  alt_printf("Compiler:     %s\r\n", CH_COMPILER_NAME);
#endif
  alt_printf("Architecture: %s\r\n", CH_ARCHITECTURE_NAME);
#ifdef CH_CORE_VARIANT_NAME
  alt_printf("Core Variant: %s\r\n", CH_CORE_VARIANT_NAME);
#endif
#ifdef CH_PORT_INFO
  alt_printf("Port Info:    %s\r\n", CH_PORT_INFO);
#endif
#ifdef PLATFORM_NAME
  alt_printf("Platform:     %s\r\n", PLATFORM_NAME);
#endif
#ifdef BOARD_NAME
  alt_printf("Board:        %s\r\n", BOARD_NAME);
#endif
#ifdef __DATE__
#ifdef __TIME__
  alt_printf("Build time:   %s%s%s\r\n", __DATE__, " - ", __TIME__);
#endif
#endif
  printf("CPU Clock:    %uHz\r\n", alt_get_cpu_freq());

}

static void cmd_systime(int argc, char *argv[]) {

  (void)argv;
  if (argc > 0) {
    usage("systime");
    return;
  }
  printf("%lu\r\n", (unsigned long)chTimeNow());
}

/**
 * @brief   Array of the default commands.
 */
static ShellCommand local_commands[] = {
  {"info", cmd_info},
  {"systime", cmd_systime},
  {NULL, NULL}
};

static bool_t cmdexec(const ShellCommand *scp, char *name, int argc, char *argv[]) {

  while (scp->sc_name != NULL) {
    if (strcasecmp(scp->sc_name, name) == 0) {
      scp->sc_function(argc, argv);
      return FALSE;
    }
    scp++;
  }
  return TRUE;
}

/**
 * @brief   Shell thread function.
 *
 * @return              Termination reason.
 * @retval RDY_OK       terminated by command.
 * @retval RDY_RESET    terminated by reset condition on the I/O channel.
 */
static msg_t shell_thread(void *p) {
  int n;
  msg_t msg = RDY_OK;
  const ShellCommand *scp = ((ShellConfig *)p)->sc_commands;
  char *lp, *cmd, *tokp, line[SHELL_MAX_LINE_LENGTH];
  char *args[SHELL_MAX_ARGUMENTS + 1];

  chRegSetThreadName("LEDOS Shell");
  alt_printf("\r\nChibiOS/RT - LEDOS Shell\r\n");

  while (TRUE) {
	  alt_printf(SHELL_PROMPT);

	  if (shellGetLine(line, sizeof(line))) {	//read complete line
		  alt_printf("\r\nlogout");
	  }

	  lp = _strtok(line, " \009", &tokp);
	  cmd = lp;
	  n = 0;

	  while ((lp = _strtok(NULL, " \009", &tokp)) != NULL) {
		  if (n >= SHELL_MAX_ARGUMENTS) {
			  alt_printf("Too many arguments\r\n");
			  cmd = NULL;
			  break;
		  }
		  args[n++] = lp;
	  }

	  args[n] = NULL;

	  if (cmd != NULL) {
		  if (strcasecmp(cmd, "exit") == 0) {
			  if (n > 0) {
				  usage("exit");
				  continue;
			  }
			  //break;
		  }
		  else if (strcasecmp(cmd, "help") == 0) {
			  if (n > 0) {
				  usage("help");
				  continue;
			  }

			  alt_printf("Commands:\r\n\thelp\r\n\texit\r\n");
			  list_commands(local_commands);
			  if (scp != NULL)
				  list_commands(scp);

			  alt_printf("\r\n");
		  }
		  else if (cmdexec(local_commands, cmd, n, args) &&
			  ((scp == NULL) || cmdexec(scp, cmd, n, args))) {
			  alt_printf("%s", cmd);
			  alt_printf(" ???\r\n");
		  }
		}

		chThdSleepMilliseconds(100);

	  }

	  /* Atomically broadcasting the event source and terminating the thread,
		 there is not a chSysUnlock() because the thread terminates upon return.*/
	  chSysLock();
	  chEvtBroadcastI(&shell_terminated);
	  //chThdExitS(msg);
	  return 0; /* Never executed.*/
}

/**
 * @brief   Shell manager initialization.
 */
void shellInit(void) {

  chEvtInit(&shell_terminated);
}

/**
 * @brief   Spawns a new shell.
 * @pre     @p CH_USE_MALLOC_HEAP and @p CH_USE_DYNAMIC must be enabled.
 *
 * @param[in] scp       pointer to a @p ShellConfig object
 * @param[in] size      size of the shell working area to be allocated
 * @param[in] prio      priority level for the new shell
 * @return              A pointer to the shell thread.
 * @retval NULL         thread creation failed because memory allocation.
 */
#if CH_USE_HEAP && CH_USE_DYNAMIC
Thread *shellCreate(const ShellConfig *scp, size_t size, tprio_t prio) {

  return chThdCreateFromHeap(NULL, size, prio, shell_thread, (void *)scp);
}
#endif

/**
 * @brief   Create statically allocated shell thread.
 *
 * @param[in] scp       pointer to a @p ShellConfig object
 * @param[in] wsp       pointer to a working area dedicated to the shell thread stack
 * @param[in] size      size of the shell working area
 * @param[in] prio      priority level for the new shell
 * @return              A pointer to the shell thread.
 */
Thread *shellCreateStatic(const ShellConfig *scp, void *wsp,
                          size_t size, tprio_t prio) {

  return chThdCreateStatic(wsp, size, prio, shell_thread, (void *)scp);
}

/**
 * @brief   Reads a whole line from the input channel.
 *
 * @param[in] line      pointer to the line buffer
 * @param[in] size      buffer maximum length
 * @return              The operation status.
 * @retval TRUE         the channel was reset or CTRL-D pressed.
 * @retval FALSE        operation successful.
 */
bool_t shellGetLine(char *line, unsigned size) {
  char *p = line;

  while (TRUE) {
    short c = (short)alt_getchar();	//read single character

    if (c < 0)
      return TRUE;
    if (c == 4) {
    	alt_printf("^D");
      return TRUE;
    }
    if (c == 8) {
      if (p != line) {
    	  alt_putchar((uint8_t)c);
    	  alt_putchar(0x20);
    	  alt_putchar((uint8_t)c);
    	  p--;
      }
      continue;
    }
    if (c == '\r') {
    	alt_printf("\r\n");
    	*p = 0;
    	return FALSE;
    }
    if (c < 0x20)
      continue;
    if (p < line + size - 1) {
    	alt_putchar((uint8_t)c);
    	*p++ = (char)c;
    }
  }
}

/** @} */
