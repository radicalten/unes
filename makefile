CFLAGS=-std=c11 -pedantic-errors -Wall -Wextra -Wshadow -I $(SRC_DIR)
CFLAGS_DEBUG=-g -O0 -fsanitize=address -DDEBUG
CFLAGS_RELEASE=-Werror -O3 -march=native -ffast-math -fstrict-aliasing \
	       -ffunction-sections -fdata-sections -fno-unwind-tables  \
	       -fno-asynchronous-unwind-tables -DNDEBUG
CFLAGS_PERF=$(CFLAGS_RELEASE) -g -fno-omit-frame-pointer

LDFLAGS=
LDFLAGS_DEBUG=
LDFLAGS_RELEASE=-s -Wl,--gc-sections
LDFLAGS_PERF=

BUILD_DIR=./build
OBJS_DIR=./objs
ASM_DIR=./asm
SRC_DIR=./src
PLATFORM_OBJS_DIR=$(OBJS_DIR)/$(PLATFORM)
PLATFORM_SRC_DIR=$(SRC_DIR)/$(PLATFORM)
PLATFORM_ASM_DIR=$(ASM_DIR)/$(PLATFORM)

SRC=$(SRC_DIR)/%.c
PLATFORM_SRC=$(PLATFORM_DIR)/%.c

OBJS=$(patsubst $(SRC_DIR)/%.c, $(OBJS_DIR)/%.o, $(wildcard $(SRC_DIR)/*.c))
ASM=$(patsubst $(SRC_DIR)/%.c, $(ASM_DIR)/%.asm, $(wildcard $(SRC_DIR)/*.c))
PLATFORM_OBJS=$(patsubst $(PLATFORM_SRC_DIR)/%.c, $(PLATFORM_OBJS_DIR)/%.o, $(wildcard $(PLATFORM_SRC_DIR)/*.c))
PLATFORM_ASM=$(patsubst $(PLATFORM_SRC_DIR)/%.c, $(PLATFORM_ASM_DIR)/%.asm, $(wildcard $(PLATFORM_SRC_DIR)/*.c))

ifeq ($(CC),)
	CC:=gcc
endif

ifeq ($(PLATFORM),)
	PLATFORM:=SDL2
endif

ifeq ($(PLATFORM),SDL2)
	CFLAGS += $(shell sdl2-config --cflags) -DPLATFORM_$(PLATFORM) -I$(PLATFORM_SRC_DIR)/
	LDFLAGS += $(shell sdl2-config --libs)
endif

ifeq ($(BUILD_TYPE),Release)
	CFLAGS += $(CFLAGS_RELEASE)
	LDFLAGS += $(LDFLAGS_RELEASE)
else ifeq ($(BUILD_TYPE),Perf)
	CFLAGS += $(CFLAGS_PERF)
	LDFLAGS += $(LDFLAGS_PERF)
else
	CFLAGS += $(CFLAGS_DEBUG)
	LDFLAGS += $(LDFLAGS_DEBUG)
endif

ifeq ($(ENABLE_LTO),ON)
	CFLAGS += -flto
endif


.PHONY: all clean asm


all: $(BUILD_DIR)/unes
asm: $(ASM) ${PLATFORM_ASM}


$(BUILD_DIR)/unes: $(OBJS) $(PLATFORM_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(OBJS_DIR)/%.o: $(SRC)
	@mkdir -p $(PLATFORM_OBJS_DIR)
	$(CC) $(CFLAGS) -MP -MD -c $< -o $@

$(ASM_DIR)/%.asm: $(SRC)
	@mkdir -p $(PLATFORM_ASM_DIR)
	$(CC) $(CFLAGS) -S $< -o $@


-include $(shell ls $(OBJS_DIR)/*.d 2>/dev/null)


clean:
	rm -rf $(ASM_DIR)/
	rm -rf $(OBJS_DIR)/

