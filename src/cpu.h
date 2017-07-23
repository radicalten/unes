#ifndef UNES_CPU_H_
#define UNES_CPU_H_

#define CPU_FREQ ((int_fast32_t)1789773)

extern void resetcpu(void);
extern void handle_irq(void);
extern void handle_nmi(void);
extern void stepcpu(void);


#endif
