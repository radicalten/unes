#ifndef UNES_MEM_H_
#define UNES_MEM_H_
#include "types.h"


enum Addresses {
	ADDR_PRGROM   = 0x8000,
	ADDR_SRAM     = 0x6000,
	ADDR_EXPROM   = 0x4020,
	ADDR_IOREGS2  = 0x4000,
	ADDR_MIRROR2  = 0x2008,
	ADDR_IOREGS1  = 0x2000,
	ADDR_MIRROR1  = 0x0800,
	ADDR_RAM      = 0x0200,
	ADDR_STACK    = 0x0100,
	ADDR_ZEROPAGE = 0x0000
};


extern void initmem(const rom_t* rom);
extern uint_fast8_t memread(uint_fast16_t addr);


static inline uint_fast16_t memread16(const uint_fast16_t addr)
{
	return (memread(addr + 1)<<8)|memread(addr);
}


#endif
