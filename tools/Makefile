.PHONY: all clean

CC := gcc
CFLAGS := -mavx2 -O2 -march=native -flto -std=c11 -Wall -Wextra -pedantic

tools := \
	gfx \
	make_patch \
	pkmncompress \
	scan_includes

all: $(tools)
	@:

clean:
	$(RM) $(tools)

gfx: common.h
scan_includes: common.h

%: %.c
	$(CC) $(CFLAGS) -o $@ $<
