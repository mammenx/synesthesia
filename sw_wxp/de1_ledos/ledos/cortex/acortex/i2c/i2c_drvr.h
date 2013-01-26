/*
 * i2c.h
 *
 *  Created on: Sep 9, 2012
 *      Author: Gregory
 */

#include <io.h>
#include "alt_types.h"
#include "../../../ledos_types.h"

#ifndef I2C_H_
#define I2C_H_

//I2C_DRIVER REG Addresses
#define I2C_DRIVER_STATUS_REG_ADDR        	0x20000
#define I2C_DRIVER_ADDR_REG_ADDR          	0x20010
#define I2C_DRIVER_DATA_REG_ADDR          	0x20020
#define I2C_DRIVER_CLK_DIV_REG_ADDR       	0x20030

//Field Masks
#define	I2C_DRIVER_STATUS_BUSY_MSK			0x0001
#define	I2C_DRIVER_STATUS_NACK_MSK			0x0002
#define	I2C_DRIVER_ADDR_MSK					0x00ff
#define	I2C_DRIVER_CLK_DIV_MSK				0x00ff


//Read I2C fields
#define	IORD_I2C_STATUS(base)			\
		IORD_32DIRECT(base, I2C_DRIVER_STATUS_REG_ADDR)

#define IORD_I2C_ADDR(base)				\
		IORD_32DIRECT(base, I2C_DRIVER_ADDR_REG_ADDR)

#define IORD_I2C_DATA(base)				\
		IORD_32DIRECT(base, I2C_DRIVER_DATA_REG_ADDR)

#define IORD_I2C_CLK_DIV(base)			\
		IORD_32DIRECT(base, I2C_DRIVER_CLK_DIV_REG_ADDR)


//Write I2C fields
#define	IOWR_I2C_STATUS(base, data)		\
		IOWR_32DIRECT(base, I2C_DRIVER_STATUS_REG_ADDR, data)

#define IOWR_I2C_ADDR(base, data)		\
		IOWR_32DIRECT(base, I2C_DRIVER_ADDR_REG_ADDR, data)

#define IOWR_I2C_DATA(base, data)		\
		IOWR_32DIRECT(base, I2C_DRIVER_DATA_REG_ADDR, data)

#define IOWR_I2C_CLK_DIV(base, data)	\
		IOWR_32DIRECT(base, I2C_DRIVER_CLK_DIV_REG_ADDR, data)


//Utils
typedef enum {
	I2C_OK	=	0,		/*	(0)	RD/WR Transaction success	*/
	I2C_NACK_DETECTED,	/*	(1)	Invalid I2C transaction		*/
	I2C_BUSY,			/*	(2)	I2C is busy in a transaction*/
	I2C_IDLE			/*	(3) I2C is ready for new transaction	*/

} I2C_RES;

I2C_RES	get_i2c_status(alt_u32 base);
I2C_RES	is_busy(alt_u32 base);
I2C_RES	i2c_xtn_write16(alt_u32 base, alt_u8 addr, alt_u16 data);
void 	configure_i2c_clk(alt_u32 base, alt_u8 clk_val);
alt_u8 	get_i2c_clk(alt_u32 base);

#endif /* I2C_H_ */
