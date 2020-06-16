#  define REGSZ 8

.irp    aa,,.as
.macro LDR\aa d, s, off=0
	ldl\aa \d, [\s, \off]
.endm
.endr

.irp    aa,,.as
.macro STR\aa d, s, off=0
	stl\aa \d, [\s, \off]
.endm
.endr

.macro PUSHR r
	pushl \r
.endm

.macro POPR r
	popl \r
.endm

.irp    cc,,.f
.macro MOVR\cc d, s
        movl\cc \d, \s
.endm
.endr

.irp    cc,,.nz
.macro ADDR\cc d, s, v
	addl\cc \d, \s, \v
.endm
.endr

.macro ADD2R d, s, v
	add2l   \d, \s, \v
.endm

.macro ADD3R d, s, v
	add3l   \d, \s, \v
.endm

.macro SUBR d, s, v
	subl    \d, \s, \v
.endm

.macro ANDR d, s, v
	andl    \d, \s, \v
.endm

.irp    cc,eq,hi
.macro BRR\cc d, s, v
; arc64 gas doesn't support BRHIL pseudo-instruction
.ifeqs "\cc","hi"
	brlo\()l  \s, \d, \v
.else
	br\cc\()l \d, \s, \v
.endif
.endm
.endr

.irp    cc,,.ne
.macro CMPR\cc d, s
	cmpl\cc \d, \s
.endm
.endr

.irp    aa,,.as,.aw,.ab
.macro FLDR\aa d, s, off=0
	fld64\aa \d, [\s, \off]
.endm
.endr

.irp    aa,,.as,.aw,.ab
.macro FSTR\aa d, s, off=0
	fst64\aa \d, [\s, \off]
.endm
.endr

.macro FPUSHR r
	FSTR.aw  \r, sp, -REGSZ
.endm

.macro FPOPR r
	FLDR.ab  \r, sp, REGSZ
.endm
