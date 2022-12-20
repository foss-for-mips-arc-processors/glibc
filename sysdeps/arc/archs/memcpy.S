/* Optimized memcpy for ARC HS.
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

#ifdef __LITTLE_ENDIAN__
# define SHIFT_1(RX,RY,IMM)	asl	RX, RY, IMM	; <<
# define SHIFT_2(RX,RY,IMM)	lsr	RX, RY, IMM	; >>
# define MERGE_1(RX,RY,IMM)	asl	RX, RY, IMM
# define MERGE_2(RX,RY,IMM)
# define EXTRACT_1(RX,RY,IMM)	and	RX, RY, 0xFFFF
# define EXTRACT_2(RX,RY,IMM)	lsr	RX, RY, IMM
#else
# define SHIFT_1(RX,RY,IMM)	lsr	RX, RY, IMM	; >>
# define SHIFT_2(RX,RY,IMM)	asl	RX, RY, IMM	; <<
# define MERGE_1(RX,RY,IMM)	asl	RX, RY, IMM	; <<
# define MERGE_2(RX,RY,IMM)	asl	RX, RY, IMM	; <<
# define EXTRACT_1(RX,RY,IMM)	lsr	RX, RY, IMM
# define EXTRACT_2(RX,RY,IMM)	lsr	RX, RY, 0x08
#endif

#ifdef __ARC_LL64__
# define PREFETCH_READ(RX)	prefetch	[RX, 56]
# define PREFETCH_WRITE(RX)	prefetchw	[RX, 64]
# define LOADX(DST,RX)		ldd.ab	DST, [RX, 8]
# define STOREX(SRC,RX)		std.ab	SRC, [RX, 8]
# define ZOLSHFT		5
# define ZOLAND			0x1F
#else
# define PREFETCH_READ(RX)	prefetch	[RX, 28]
# define PREFETCH_WRITE(RX)	prefetchw	[RX, 32]
# define LOADX(DST,RX)		ld.ab	DST, [RX, 4]
# define STOREX(SRC,RX)		st.ab	SRC, [RX, 4]
# define ZOLSHFT		4
# define ZOLAND			0xF
#endif


ENTRY (memcpy)
	/* Prefetch the read and write locations.  */
	prefetch [r1]
	prefetchw [r0]

	/* If size is zero.  */
	mov.f	0, r2
	jz.d	[blink]
	mov	r3, r0

	/* If size <= 8.  */
	cmp	r2, 8
	bls.d	@.Lsmallchunk
	mov.f	lp_count, r2

	/* Check the alignment of the destination and align it.  */
	and.f	r4, r0, 0x03
	rsub	lp_count, r4, 4
	lpnz	@.Laligndestination
	/* Loop body.  */
	ldb.ab	r5, [r1,1]
	sub	r2, r2, 1
	stb.ab	r5, [r3,1]
.Laligndestination:

	/* Check the alignment of the source  */
	and.f	r4, r1, 0x03
	bnz.d	@.Lsourceunaligned

	/* CASE 0: Both source and destination are 32bit aligned.
	   Convert len to Dwords, unfold x4.  */
	lsr.f	lp_count, r2, ZOLSHFT
	lpnz	@.Lcopy32_64bytes
	/* Loop body.  */
	LOADX (r6, r1)
	PREFETCH_READ (r1)
	PREFETCH_WRITE (r3)
	LOADX (r8, r1)
	LOADX (r10, r1)
	LOADX (r4, r1)
	STOREX (r6, r3)
	STOREX (r8, r3)
	STOREX (r10, r3)
	STOREX (r4, r3)
.Lcopy32_64bytes:

	/* Last remaining 31 bytes.  */
	and.f	lp_count, r2, ZOLAND
.Lsmallchunk:
	lpnz	@.Lcopyremainingbytes
	/* Loop body  */
	ldb.ab	r5, [r1,1]
	stb.ab	r5, [r3,1]
.Lcopyremainingbytes:

	j	[blink]
	/* End of CASE0 and exit. */

.Lsourceunaligned:
	cmp	r4, 2
	beq.d	@.LunalignedOffby2
	sub	r2, r2, 1

	bhi.d	@.LunalignedOffby3
	ldb.ab	r5, [r1, 1]

	/* CASE 1: The source is unaligned, off by 1.
	  Hence I need to read 1 byte for a 16bit alignment
	  and 2bytes to reach 32bit alignment.  */
	ldh.ab	r6, [r1, 2]
	sub	r2, r2, 2
	/* Convert to words, unfold x2.  */
	lsr.f	lp_count, r2, 3
	MERGE_1 (r6, r6, 8)
	MERGE_2 (r5, r5, 24)
	or	r5, r5, r6

	/* Both src and dst are aligned.  */
	lpnz	@.Lcopy8bytes_1
	/* Loop body  */
	ld.ab	r6, [r1, 4]
	prefetch [r1, 28]	/* Prefetch the next read location.  */
	ld.ab	r8, [r1,4]
	prefetchw [r3, 32]	/* Prefetch the next write location.  */

	SHIFT_1	(r7, r6, 24)
	or	r7, r7, r5
	SHIFT_2	(r5, r6, 8)

	SHIFT_1	(r9, r8, 24)
	or	r9, r9, r5
	SHIFT_2	(r5, r8, 8)

	st.ab	r7, [r3, 4]
	st.ab	r9, [r3, 4]
.Lcopy8bytes_1:

	/* Write back the remaining 16bits.  */
	EXTRACT_1 (r6, r5, 16)
	sth.ab	r6, [r3, 2]
	/* Write back the remaining 8bits.  */
	EXTRACT_2 (r5, r5, 16)
	stb.ab	r5, [r3, 1]

	/* Last 8bytes.  */
	and.f	lp_count, r2, 0x07 
	lpnz	@.Lcopybytewise_1
	/* Loop body.  */
	ldb.ab	r6, [r1,1]
	stb.ab	r6, [r3,1]
.Lcopybytewise_1:

	j	[blink]
	/* End of CASE1 and exit. */

.LunalignedOffby2:
	/* CASE 2: The source is unaligned, off by 2.  */
	ldh.ab	r5, [r1, 2]
	sub	r2, r2, 1

	/* Both src and dst are aligned. Convert to words, unfold x2.  */
	lsr.f	lp_count, r2, 3
#ifdef __BIG_ENDIAN__
	asl.nz	r5, r5, 16
#endif
	lpnz	@.Lcopy8bytes_2
	/* Loop body.  */
	ld.ab	r6, [r1, 4]
	prefetch [r1, 28]	/* Prefetch the next read location.  */
	ld.ab	r8, [r1,4]
	prefetchw [r3, 32]	/* Prefetch the next write location.  */

	SHIFT_1	(r7, r6, 16)
	or	r7, r7, r5
	SHIFT_2	(r5, r6, 16)

	SHIFT_1	(r9, r8, 16)
	or	r9, r9, r5
	SHIFT_2	(r5, r8, 16)

	st.ab	r7, [r3, 4]
	st.ab	r9, [r3, 4]
.Lcopy8bytes_2:

#ifdef __BIG_ENDIAN__
	lsr.nz	r5, r5, 16
#endif
	sth.ab	r5, [r3, 2]

	/* Last 8bytes.  */
	and.f	lp_count, r2, 0x07
	lpnz	@.Lcopybytewise_2
	/* Loop body.  */
	ldb.ab	r6, [r1,1]
	stb.ab	r6, [r3,1]
.Lcopybytewise_2:

	j	[blink]
	/* End of CASE2 and exit. */

.LunalignedOffby3:
	/* CASE 3: The source is unaligned, off by 3.
	   Hence, I need to read 1byte for achieve the 32bit alignment.  */

	/* Both src and dst are aligned. Convert to words, unfold x2.  */
	lsr.f	lp_count, r2, 3
#ifdef __BIG_ENDIAN__
	asl.ne	r5, r5, 24
#endif
	lpnz	@.Lcopy8bytes_3
	/* Loop body.  */
	ld.ab	r6, [r1, 4]
	prefetch [r1, 28]	/* Prefetch the next read location.  */
	ld.ab	r8, [r1,4]
	prefetchw [r3, 32]	/* Prefetch the next write location.  */

	SHIFT_1	(r7, r6, 8)
	or	r7, r7, r5
	SHIFT_2	(r5, r6, 24)

	SHIFT_1	(r9, r8, 8)
	or	r9, r9, r5
	SHIFT_2	(r5, r8, 24)

	st.ab	r7, [r3, 4]
	st.ab	r9, [r3, 4]
.Lcopy8bytes_3:

#ifdef __BIG_ENDIAN__
	lsr.nz	r5, r5, 24
#endif
	stb.ab	r5, [r3, 1]
	
	/* Last 8bytes.  */
	and.f	lp_count, r2, 0x07
	lpnz	@.Lcopybytewise_3
	/* Loop body.  */
	ldb.ab	r6, [r1,1]
	stb.ab	r6, [r3,1]
.Lcopybytewise_3:

	j	[blink]
	/* End of CASE3 and exit. */
END (memcpy)
libc_hidden_builtin_def (memcpy)
