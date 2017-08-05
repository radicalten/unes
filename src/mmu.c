#include <stdio.h>
#include <assert.h>
#include "rom.h"
#include "mmu.h"
#include "apu.h"
#include "ppu.h"


#ifdef DEBUG
#define BAD_ACCESS(addr) \
  assert(fprintf(stderr, "BAD ACCESS: %s:%d $%.4lx\n", __FILE__, __LINE__, addr) && false)
#else
#define BAD_ACCESS(addr) ((void)addr)
#endif


static uint8_t ram[0x800]; // zeropage,stack,ram


static void iowrite(const uint_fast8_t val, const uint_fast16_t addr)
{
	if (addr >= 0x4000 && addr <= 0x4017) {
		if (addr == 0x4014)
			ppuwrite(val, addr);
		else
			apuwrite(val, addr);
	} else if (addr >= 0x2000 && addr < 0x4000) {
		ppuwrite(val, addr);
	} else {
		BAD_ACCESS(addr);
	}
}

static uint_fast8_t ioread(const uint_fast16_t addr)
{
	if (addr >= 0x4000 && addr <= 0x4016) {
		if (addr == 0x4014)
			return ppuread(addr);
		else
			return apuread(addr);
	} else if (addr >= 0x4016 && addr <= 0x4017) {
		// read from $4016 - $4017 is joypad's
	} else if (addr >= 0x2000 && addr <= 0x4000) {
		return ppuread(addr);
	} else {
		BAD_ACCESS(addr);
	}

	return 0x00;
}


uint_fast8_t mmuread(const uint_fast16_t addr)
{
	if (addr < ADDR_IOREGS1)
		return ram[addr&0x7FF];
	else if (addr >= ADDR_SRAM)
		return romread(addr);
	else if (addr < ADDR_EXPROM)
		return ioread(addr);
	else
		BAD_ACCESS(addr);

	return 0x00;
}


void mmuwrite(const uint_fast8_t val, const uint_fast16_t addr)
{
	if (addr < ADDR_IOREGS1)
		ram[addr&0x7FF] = val;
	else if (addr < ADDR_EXPROM)
		iowrite(val, addr);
	else if (addr >= ADDR_SRAM)
		romwrite(val, addr);
	else
		BAD_ACCESS(addr);
}

