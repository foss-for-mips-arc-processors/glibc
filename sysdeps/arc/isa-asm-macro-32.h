#  define REGSZ 4

.irp    aa,,.as
.macro LDR\aa d, s, off=0
	ld\aa  \d, [\s, \off]
.endm
.endr

.irp    aa,,.as
.macro STR\aa d, s, off=0
	st\aa \d, [\s, \off]
.endm
.endr

.macro PUSHR r
	push \r
.endm

.macro POPR r
	pop \r
.endm

.irp    cc,,.f
.macro MOVR\cc d, s
        mov\cc \d, \s
.endm
.endr

.irp    cc,,.nz
.macro ADDR\cc d, s, v
	add\cc \d, \s, \v
.endm
.endr

.macro ADD2R d, s, v
	add2   \d, \s, \v
.endm

.macro ADD3R d, s, v
	add3   \d, \s, \v
.endm

.macro SUBR d, s, v
	sub    \d, \s, \v
.endm

.macro ANDR d, s, v
	and    \d, \s, \v
.endm

.irp    cc,,eq,hi
.macro BRR\cc d, s, v
	br\cc  \d, \s, \v
.endm
.endr

.irp    cc,,.ne
.macro CMPR\cc d, s
	cmp\cc \d, \s
.endm
.endr
