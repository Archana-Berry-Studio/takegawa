# takegawa (TGPM) — MochiBerry package manager
# Build: make MOCHIBERRY_DIR=/path/to/mochiberry
CC ?= gcc
CFLAGS := -O2 -g -std=gnu11 -D_GNU_SOURCE -Iinclude -I$(MOCHIBERRY_DIR)
LIB := $(MOCHIBERRY_DIR)/build_manual/libmbjs.a
OUT := takegawa
ifeq ($(OS),Windows_NT)
  OUT := takegawa.exe
endif

.PHONY: all clean test

all: $(OUT)

$(OUT): takegawa.c compat/stat64i32.c include/mbjs.h include/mbjs-libc.h
	@test -f "$(LIB)" || { echo "error: $(LIB) missing; set MOCHIBERRY_DIR"; exit 1; }
	$(CC) $(CFLAGS) -o $@ takegawa.c compat/stat64i32.c $(LIB) -lm -lpthread

test: $(OUT)
	$(MOCHIBERRY_DIR)/build_manual/mbjs.exe -m tests/test_takegawa.js

clean:
	rm -f $(OUT)
