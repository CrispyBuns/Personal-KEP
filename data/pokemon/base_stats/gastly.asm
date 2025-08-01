	db DEX_GASTLY ; pokedex id

	db  30,  35,  35,  80, 100
	;   hp  atk  def  spd  spc

	db GHOST, POISON ; type
	db 255 ; catch rate
	db 96 ; base exp

	INCBIN "gfx/pokemon/front/gastly.pic", 0, 1 ; sprite dimensions
	dw GastlyPicFront, GastlyPicBack

	db LICK, CONFUSE_RAY, NIGHT_SHADE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        RAGE,         MEGA_DRAIN,   THUNDERBOLT,  THUNDER,      \
	     PSYCHIC_M,    MIMIC,        DOUBLE_TEAM,  BIDE,         SELFDESTRUCT, \
	     DREAM_EATER,  REST,         PSYWAVE,      EXPLOSION,    SUBSTITUTE
	; end

	db BANK(GastlyPicFront)
	assert BANK(GastlyPicFront) == BANK(GastlyPicBack)
