/*
 * i2c.c
 *
 *  Created on: Sep 9, 2012
 *      Author: Gregory
 */
#include "i2c_drvr.h"
#include "alt_types.h"
#include "ch.h"
#include "sys/alt_stdio.h"


I2C_RES	get_i2c_status(alt_u32 base){
	alt_u16	reg	=	IORD_I2C_STATUS(base);

	if(reg	&	I2C_DRIVER_STATUS_NACK_MSK){
		return I2C_NACK_DETECTED;
	}
	else if(reg	&	I2C_DRIVER_STATUS_BUSY_MSK){
		return I2C_BUSY;
	}

	return I2C_IDLE;
}


I2C_RES	is_busy(alt_u32 base){
	alt_u16	reg	=	IORD_I2C_STATUS(base);

	if(reg	&	I2C_DRIVER_STATUS_BUSY_MSK){
		return I2C_BUSY;
	}

	return I2C_IDLE;

}


I2C_RES	i2c_xtn_write16(alt_u32 base, alt_u8 addr, alt_u16 data){

	while(IORD_I2C_STATUS(base) & I2C_DRIVER_STATUS_BUSY_MSK){
		//alt_printf("Waiting for I2C driver to be free\n");
	    chThdSleepMilliseconds(1);	//wait for I2C driver to be free
	}
	//alt_printf("I2C driver is free\n");


	IOWR_I2C_DATA(base, data);
	IOWR_I2C_ADDR(base, addr	&	0xfe);	//forcing bit[0] to ground for write op

	IOWR_I2C_STATUS(base, 0x0);	//writing to Status register triggers I2C xtn

	while(IORD_I2C_STATUS(base) & I2C_DRIVER_STATUS_BUSY_MSK){
		//alt_printf("Waiting for I2C driver to be free\n");

		chThdSleepMilliseconds(1);	//wait for I2C driver to be free
	}

	//alt_printf("I2C driver is free\n");
	//alt_printf("I2C status 0x%x\n",IORD_I2C_STATUS(base));


	if(IORD_I2C_STATUS(base)	&	I2C_DRIVER_STATUS_NACK_MSK){

		return I2C_NACK_DETECTED;
	}

	return I2C_OK;
}


void configure_i2c_clk(alt_u32 base, alt_u8 clk_val){
	IOWR_I2C_CLK_DIV(base, clk_val);

	return;
}


alt_u8 	get_i2c_clk(alt_u32 base){
	return IORD_I2C_CLK_DIV(base);
}
