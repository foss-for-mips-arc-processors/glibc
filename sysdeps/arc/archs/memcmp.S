/* Optimized memcmp for ARC HS.
   Copyright (C) 2022 Free Software Foundation, Inc.

   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <https://www.gnu.org/licenses/>.  */

#include <sysdep.h>

/* ARC HS, BE/LE, no assumption about alignment.  */

#ifdef __LITTLE_ENDIAN__
# define WORD2 r2
# define SHIFT r3
#else /* BIG ENDIAN */
# define WORD2 r3
# define SHIFT r2
#endif

ENTRY (memcmp)
	or	r12,r0,r1
	asl_s	r12,r12,30
	sub	r3,r2,1
	brls	r2,r12,.Lbytewise
	ld	r4,[r0,0]
	ld	r5,[r1,0]

	lsr.f	lp_count,r3,3
	lpne	.Loop_end
	/* Loop body.  */
	ld_s	WORD2,[r0,4]
	ld_s	r12,[r1,4]
	brne	r4,r5,.Leven
	ld.a	r4,[r0,8]
	ld.a	r5,[r1,8]
	brne	WORD2,r12,.Lodd
	/* A branch can't be the last instruction in a zero overhead loop.  */
	nop
.Loop_end:

	asl_s	SHIFT,SHIFT,3
	bhs_s	.Last_cmp
	brne	r4,r5,.Leven
	ld	r4,[r0,4]
	ld	r5,[r1,4]
#ifdef __LITTLE_ENDIAN__
	nop_s
	/* One more load latency cycle.  */
.Last_cmp:
	xor	r0,r4,r5
	bset	r0,r0,SHIFT
	sub_s	r1,r0,1
	bic_s	r1,r1,r0
	norm	r1,r1
	b.d	.Leven_cmp
	and	r1,r1,24
.Leven:
	xor	r0,r4,r5
	sub_s	r1,r0,1
	bic_s	r1,r1,r0
	norm	r1,r1
	/* Slow track insn.  */
	and	r1,r1,24
.Leven_cmp:
	asl	r2,r4,r1
	asl	r12,r5,r1
	lsr_s	r2,r2,1
	lsr_s	r12,r12,1
	j_s.d	[blink]
	sub	r0,r2,r12
	.balign	4
.Lodd:
	xor	r0,WORD2,r12
	sub_s	r1,r0,1
	bic_s	r1,r1,r0
	norm	r1,r1
	/* Slow track insn.  */
	and	r1,r1,24
	asl_s	r2,r2,r1
	asl_s	r12,r12,r1
	lsr_s	r2,r2,1
	lsr_s	r12,r12,1
	j_s.d	[blink]
	sub	r0,r2,r12
#else /* BIG ENDIAN */
.Last_cmp:
	neg_s	SHIFT,SHIFT
	lsr	r4,r4,SHIFT
	lsr	r5,r5,SHIFT
	/* Slow track insn.  */
.Leven:
	sub.f	r0,r4,r5
	mov.ne	r0,1
	j_s.d	[blink]
	bset.cs	r0,r0,31
.Lodd:
	cmp_s	WORD2,r12
	mov_s	r0,1
	j_s.d	[blink]
	bset.cs	r0,r0,31
#endif /* BIG ENDIAN */

	.balign	4
.Lbytewise:
	breq	r2,0,.Lnil
	ldb	r4,[r0,0]
	ldb	r5,[r1,0]

	lsr.f	lp_count,r3
	lpne	.Lbyte_end
	/* Loop body.  */
	ldb_s	r3,[r0,1]
	ldb	r12,[r1,1]
	brne	r4,r5,.Lbyte_even
	ldb.a	r4,[r0,2]
	ldb.a	r5,[r1,2]
	brne	r3,r12,.Lbyte_odd
	nop
.Lbyte_end:

	bcc	.Lbyte_even
	brne	r4,r5,.Lbyte_even
	ldb_s	r3,[r0,1]
	ldb_s	r12,[r1,1]
.Lbyte_odd:
	j_s.d	[blink]
	sub	r0,r3,r12
.Lbyte_even:
	j_s.d	[blink]
	sub	r0,r4,r5
.Lnil:
	j_s.d	[blink]
	mov	r0,0
END (memcmp)
weak_alias (memcmp, bcmp)
strong_alias (memcmp, __memcmpeq)
libc_hidden_builtin_def (memcmp)
libc_hidden_def (__memcmpeq)
