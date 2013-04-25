/////////////////////////
// Christopher Brandt
// CSCI 255
// Lab 9
//
// http://www.c4micros.com/c4micros_009.htm // ref
//
// values for 1/20th of a second: 0.05 * 921583 = 46079, 65536 - 46079 = 19457 (4C01h)
//
/////////////////////////
// Includes

#include "8051.h"

/////////////////////////

unsigned int tickCount = 0;

main()
{
	// Timer 0 / Global interrupt enable
	IE = (IE | 0x082);

	TL0  = 0x01;
	TH0  = 0x04C;

	// Set timer 0 to 16-bit mode
	TMOD = (TMOD | 0x01);

	// Clear overflow bit
	TCON = (TCON & 0x0DF);

	// Start timer 0
	TCON = (TCON | 0x010);

	while(1)
	{
		unsigned char c;
		
		for (c = 0; c < 255; c++)
		{
			wait_Second();
			P0 = ~((~c) + 1);
		}
	}	
}


void timer0_Overflow_Handler() interrupt 1
{
	// Reset timer
	TL0  = 0x01;
	TH0  = 0x04C;

	// Clear overflow bit
	TCON = (TCON & 0x0DF);

	// Start timer 0
	TCON = (TCON | 0x010);

	tickCount++;
}

void wait_Second()
{
	while (tickCount < 20) {}

	tickCount = 0;
}