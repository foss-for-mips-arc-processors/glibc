/* Optimized memset for ARC HS.
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

/* ARC HS, BE/LE, no assumption about alignment. This implementation is
   optimized for performance. Optimized by zero delay loops, prefetch
   instructions and eight byte store std instruction.  */

ENTRY (memset)
	/* Prefetch the write location.  */
	prefetchw	[r0]
	mov.f	0, r2

	/* If size is zero.  */
	jz.d	[blink]
	mov	r3, r0

	/* If length < 8.  */
	brls.d.nt	r2, 8, .Lsmallchunk
	mov.f	lp_count,r2

	and.f	r4, r0, 0x03
	rsub	lp_count, r4, 4
	lpnz	@.Laligndestination
	/* Loop body.  */
	stb.ab	r1, [r3,1]
	sub	r2, r2, 1
.Laligndestination:

	/* Destination is aligned.  */
	and	r1, r1, 0xFF
	asl	r4, r1, 8
	or	r4, r4, r1
	asl	r5, r4, 16
	or	r5, r5, r4
	mov	r4, r5

	sub3	lp_count, r2, 8
	cmp     r2, 64
	bmsk.hi	r2, r2, 5
	mov.ls	lp_count, 0
	add3.hi	r2, r2, 8

	/* Convert len to Dwords, unfold x8.  */
	lsr.f	lp_count, lp_count, 6
	lpnz	@.Lset64bytes
	/* Loop body.  */
	prefetchw [r3, 64]	/* Prefetch the next write location.  */
#ifdef __ARC_LL64__
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
#else
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
#endif
.Lset64bytes:
	/* Last remaining  max 124 bytes.  */
	lsr.f	lp_count, r2, 5
	lpnz	.Lset32bytes
	/* Loop body.  */
	prefetchw [r3, 32]	/* Prefetch the next write location.  */
#ifdef __ARC_LL64__
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
	std.ab	r4, [r3, 8]
#else
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
	st.ab	r4, [r3, 4]
#endif
.Lset32bytes:
	/* Last remaining 31 bytes.  */
	and.f	lp_count, r2, 0x1F
.Lsmallchunk:
	lpnz	.Lcopy3bytes
	/* Loop body.  */
	stb.ab	r1, [r3, 1]
.Lcopy3bytes:

	j	[blink]
END (memset)
libc_hidden_builtin_def (memset)
