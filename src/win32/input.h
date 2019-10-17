#ifndef UNES_INPUT_H_
#define UNES_INPUT_H_
#include "cpu.h"


static inline uint8_t get_pad_state(const joypad_t pad)
{
	extern uint8_t unes_pad_states[2];
	return unes_pad_states[pad];
}



#endif
