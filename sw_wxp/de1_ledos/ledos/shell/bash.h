/*
 * bash.h
 *
 *  Created on: Jun 16, 2012
 *      Author: Gregory James
 */

#include "alt_types.h"
#include "ch.h"
#include "../lsd/lsd.h"

#ifndef BASH_H_
#define BASH_H_

/*
void cmd_mem(int argc, char *argv[]);
void cmd_touch(int argc, char *argv[]);
void cmd_mv(int argc, char *argv[]);
void cmd_cd(int argc, char *argv[]);
void cmd_pwd(int argc, char *argv[]);
void cmd_ll(int argc, char *argv[]);
void cmd_cat(int argc, char *argv[]);
void cmd_cath(int argc, char *argv[]);
void cmd_perf(int argc, char *argv[]);
*/

ShellConfig * get_usr_bash_config(void);

bool_t	update_acid(const Acid *ad, char *name);

Thread *acidThreadCreateStatic(void *wsp, size_t size, tprio_t prio);

void init_bash(void);

#endif /* BASH_H_ */
