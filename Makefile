roms := \
	kep.gbc \
	kep_debug.gbc
patches := \
	kep.patch

rom_obj := \
	audio.o \
	home.o \
	main.o \
	maps.o \
	ram.o \
	text.o \
	gfx/pics.o \
	gfx/sprites.o \
	gfx/tilesets.o

kep_obj        := $(rom_obj:.o=_kep.o)
kep_debug_obj  := $(rom_obj:.o=_kep_debug.o)

### Build tools

ifeq (,$(shell which sha1sum))
SHA1 := shasum
else
SHA1 := sha1sum
endif

ifneq ($(wildcard rgbds/.*),)
RGBDS := rgbds/
else
RGBDS :=
endif

RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink


### Build targets

.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:
.PHONY: all red blue blue_debug clean tidy compare tools

all: $(roms)
kep:        kep.gbc
kep_debug:  kep_debug.gbc

clean: tidy
	find gfx \
	     \( -iname '*.1bpp' \
	        -o -iname '*.2bpp' \
	        -o -iname '*.pic' \) \
	     -delete

tidy:
	$(RM) $(roms) \
	      $(roms:.gbc=.sym) \
	      $(roms:.gbc=.map) \
	      $(patches) \
	      $(patches:.patch=_vc.gbc) \
	      $(patches:.patch=_vc.sym) \
	      $(patches:.patch=_vc.map) \
	      $(patches:%.patch=vc/%.constants.sym) \
	      $(kep_obj) \
		  $(kep_debug_obj) \
	      rgbdscheck.o
	$(MAKE) clean -C tools/

compare: $(roms) $(patches)
	@$(SHA1) -c roms.sha1

tools:
	$(MAKE) -C tools/


RGBASMFLAGS = -hL -Q8 -P includes.asm -Weverything -Wnumeric-string=2 -Wtruncation=1
# Create a sym/map for debug purposes if `make` run with `DEBUG=1`
ifeq ($(DEBUG),1)
RGBASMFLAGS += -E
endif

$(kep_obj):        RGBASMFLAGS += -D _KEP
$(kep_debug_obj):  RGBASMFLAGS += -D _KEP -D _DEBUG

%.patch: vc/%.constants.sym %_vc.gbc %.gbc vc/%.patch.template
	tools/make_patch $*_vc.sym $^ $@

rgbdscheck.o: rgbdscheck.asm
	$(RGBASM) -o $@ $<

# Build tools when building the rom.
# This has to happen before the rules are processed, since that's when scan_includes is run.
ifeq (,$(filter clean tidy tools,$(MAKECMDGOALS)))

$(info $(shell $(MAKE) -C tools))

# The dep rules have to be explicit or else missing files won't be reported.
# As a side effect, they're evaluated immediately instead of when the rule is invoked.
# It doesn't look like $(shell) can be deferred so there might not be a better way.
preinclude_deps := includes.asm $(shell tools/scan_includes includes.asm)
define DEP
$1: $2 $$(shell tools/scan_includes $2) $(preinclude_deps) | rgbdscheck.o
	$$(RGBASM) $$(RGBASMFLAGS) -o $$@ $$<
endef

# Dependencies for objects (drop _red and _blue from asm file basenames)
$(foreach obj, $(kep_obj), $(eval $(call DEP,$(obj),$(obj:_kep.o=.asm))))
$(foreach obj, $(kep_debug_obj), $(eval $(call DEP,$(obj),$(obj:_kep_debug.o=.asm))))

# Dependencies for VC files that need to run scan_includes
%.constants.sym: %.constants.asm $(shell tools/scan_includes %.constants.asm) $(preinclude_deps) | rgbdscheck.o
	$(RGBASM) $(RGBASMFLAGS) $< > $@

endif


%.asm: ;


kep_pad        = 0xff
kep_debug_pad  = 0xff

kep_opt        = -jsv -n 0 -k 01 -l 0x33 -m 0x13 -r 03 -t "PKMN: PERSONAL"
kep_debug_opt  = -jsv -n 0 -k 01 -l 0x33 -m 0x13 -r 03 -t "PKMN: EXPN. PAK"

%.gbc: $$(%_obj) layout.link
	$(RGBLINK) -p $($*_pad) -d -m $*.map -n $*.sym -l layout.link -o $@ $(filter %.o,$^)
	$(RGBFIX) -p $($*_pad) $($*_opt) $@


### Misc file-specific graphics rules

gfx/battle/move_anim_0.2bpp: tools/gfx += --trim-whitespace
gfx/battle/move_anim_1.2bpp: tools/gfx += --trim-whitespace

gfx/intro/red_nidorino_1.2bpp: rgbgfx += -Z
gfx/intro/red_nidorino_2.2bpp: rgbgfx += -Z
gfx/intro/red_nidorino_3.2bpp: rgbgfx += -Z
gfx/intro/gengar.2bpp: rgbgfx += -Z
gfx/intro/gengar.2bpp: tools/gfx += --remove-duplicates --preserve=0x19,0x76

gfx/credits/the_end.2bpp: tools/gfx += --interleave --png=$<

gfx/slots/slots_1.2bpp: tools/gfx += --trim-whitespace

gfx/tilesets/%.2bpp: tools/gfx += --trim-whitespace
gfx/tilesets/reds_house.2bpp: tools/gfx += --preserve=0x48

gfx/trade/game_boy.2bpp: tools/gfx += --remove-duplicates


### Catch-all graphics rules

%.png: ;

%.2bpp: %.png
	$(RGBGFX) $(rgbgfx) -o $@ $<
	$(if $(tools/gfx),\
		tools/gfx $(tools/gfx) -o $@ $@)

%.1bpp: %.png
	$(RGBGFX) $(rgbgfx) -d1 -o $@ $<
	$(if $(tools/gfx),\
		tools/gfx $(tools/gfx) -d1 -o $@ $@)

%.pic: %.2bpp
	tools/pkmncompress $< $@
