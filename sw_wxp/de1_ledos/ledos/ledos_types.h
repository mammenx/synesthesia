/*
 * ledos_types.h
 *
 *  Created on: Dec 13, 2012
 *      Author: Gregory
 */

#ifndef LEDOS_TYPES_H_
#define LEDOS_TYPES_H_

typedef	enum	{
	FS_8KHZ,
	FS_32KHZ,
	FS_44KHZ,
	FS_48KHZ,
	FS_88KHZ,
	FS_96KHZ
}FS_T;

typedef	enum	{
	BPS_32	=	1,
	BPS_16	=	0
}BPS_T;

#endif /* LEDOS_TYPES_H_ */
