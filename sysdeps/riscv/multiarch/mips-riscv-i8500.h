/* MIPS i8500 memcpy helper macros.
   Copyright (C) 2025 Free Software Foundation, Inc.
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
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

#define ALIGN_AT_64_BYTES_MASK 0x3F
#define ALIGN_AT_16_BYTES_MASK 0x0F
#define ALIGN_AT_8_BYTES_MASK 0x07

#define UNALIGNED_WORD_COPY(dstp, srcp, OFFSET) \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t0):"r"(srcp),[offset_plus] "i" (OFFSET + 0):"memory");    \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t1):"r"(srcp),[offset_plus] "i" (OFFSET + 1):"memory");    \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t2):"r"(srcp),[offset_plus] "i" (OFFSET + 4):"memory");    \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t3):"r"(srcp),[offset_plus] "i" (OFFSET + 5):"memory");    \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t0),"r"(dstp),[offset_plus] "i" (OFFSET + 0):"memory"); \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t1),"r"(dstp),[offset_plus] "i" (OFFSET + 1):"memory"); \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t2),"r"(dstp),[offset_plus] "i" (OFFSET + 4):"memory"); \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t3),"r"(dstp),[offset_plus] "i" (OFFSET + 5):"memory"); \
        \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t0):"r"(srcp),[offset_plus] "i" (OFFSET + 2):"memory");    \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t1):"r"(srcp),[offset_plus] "i" (OFFSET + 3):"memory");    \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t2):"r"(srcp),[offset_plus] "i" (OFFSET + 6):"memory");    \
        asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t3):"r"(srcp),[offset_plus] "i" (OFFSET + 7):"memory");    \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t0),"r"(dstp),[offset_plus] "i" (OFFSET + 2):"memory"); \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t1),"r"(dstp),[offset_plus] "i" (OFFSET + 3):"memory"); \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t2),"r"(dstp),[offset_plus] "i" (OFFSET + 6):"memory"); \
        asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t3),"r"(dstp),[offset_plus] "i" (OFFSET + 7):"memory");

#define ALIGNED_COPY_LOOP_PREF(dstp, srcp)	\
		asm volatile ("ld\t%0,0(%1)":"=r"(t0):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,8(%1)":"=r"(t1):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,16(%1)":"=r"(t2):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,24(%1)":"=r"(t3):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,32(%1)":"=r"(t4):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,40(%1)":"=r"(t5):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,48(%1)":"=r"(t6):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,56(%1)":"=r"(t7):"r"(srcp):"memory");		\
		srcp += 8;	\
		asm volatile ("mips.sdp\t%0,%1,0(%2)"::"r"(t0),"r"(t1),"r"(dstp):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,16(%2)"::"r"(t2),"r"(t3),"r"(dstp):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,32(%2)"::"r"(t4),"r"(t5),"r"(dstp):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,48(%2)"::"r"(t6),"r"(t7),"r"(dstp):"memory");	\
		dstp += 8;	\
		asm volatile ("prefetch.r\t384(%0)"::"r"(srcp));

#define ALIGNED_COPY_LOOP_PREF_CBO(dstp, srcp)	\
		asm volatile ("ld\t%0,0(%1)":"=r"(t0):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,8(%1)":"=r"(t1):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,16(%1)":"=r"(t2):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,24(%1)":"=r"(t3):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,32(%1)":"=r"(t4):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,40(%1)":"=r"(t5):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,48(%1)":"=r"(t6):"r"(srcp):"memory");		\
		asm volatile ("ld\t%0,56(%1)":"=r"(t7):"r"(srcp):"memory");		\
		srcp += 8;	\
		asm ("cbo.zero\t(%0)"::"r"(dstp));	\
		asm volatile ("mips.sdp\t%0,%1,0(%2)"::"r"(t0),"r"(t1),"r"(dstp):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,16(%2)"::"r"(t2),"r"(t3),"r"(dstp):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,32(%2)"::"r"(t4),"r"(t5),"r"(dstp):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,48(%2)"::"r"(t6),"r"(t7),"r"(dstp):"memory");	\
		dstp += 8;	\
		asm volatile ("prefetch.r\t384(%0)"::"r"(srcp));

#define UNALIGNED_COPY_LOOP_PREF(dstp, srcp, LD_OFF1, LD_OFF2, LD_OFF3, OFFSET)	\
		asm volatile ("mips.ldp\t%0,%1,%c[offset_plus](%2)":"=r"(t0),"=r"(t1):"r"(srcp),[offset_plus] "i" (LD_OFF1):"memory");	\
		asm volatile ("mips.ldp\t%0,%1,%c[offset_plus](%2)":"=r"(t2),"=r"(t3):"r"(srcp),[offset_plus] "i" (LD_OFF2):"memory");	\
		asm volatile ("mips.ldp\t%0,%1,%c[offset_plus](%2)":"=r"(t4),"=r"(t5):"r"(srcp),[offset_plus] "i" (LD_OFF3):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,%c[offset_plus](%2)"::"r"(t0),"r"(t1),"r"(dstp),[offset_plus] "i" (LD_OFF1):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,%c[offset_plus](%2)"::"r"(t2),"r"(t3),"r"(dstp),[offset_plus] "i" (LD_OFF2):"memory");	\
		asm volatile ("mips.sdp\t%0,%1,%c[offset_plus](%2)"::"r"(t4),"r"(t5),"r"(dstp),[offset_plus] "i" (LD_OFF3):"memory");	\
		\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t0):"r"(srcp),[offset_plus] "i" (OFFSET + 0):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t1):"r"(srcp),[offset_plus] "i" (OFFSET + 1):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t2):"r"(srcp),[offset_plus] "i" (OFFSET + 8):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t3):"r"(srcp),[offset_plus] "i" (OFFSET + 9):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t0),"r"(dstp),[offset_plus] "i" (OFFSET + 0):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t1),"r"(dstp),[offset_plus] "i" (OFFSET + 1):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t2),"r"(dstp),[offset_plus] "i" (OFFSET + 8):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t3),"r"(dstp),[offset_plus] "i" (OFFSET + 9):"memory");	\
		\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t0):"r"(srcp),[offset_plus] "i" (OFFSET + 2):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t1):"r"(srcp),[offset_plus] "i" (OFFSET + 3):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t2):"r"(srcp),[offset_plus] "i" (OFFSET + 10):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t3):"r"(srcp),[offset_plus] "i" (OFFSET + 11):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t0),"r"(dstp),[offset_plus] "i" (OFFSET + 2):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t1),"r"(dstp),[offset_plus] "i" (OFFSET + 3):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t2),"r"(dstp),[offset_plus] "i" (OFFSET + 10):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t3),"r"(dstp),[offset_plus] "i" (OFFSET + 11):"memory");	\
		\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t0):"r"(srcp),[offset_plus] "i" (OFFSET + 4):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t1):"r"(srcp),[offset_plus] "i" (OFFSET + 5):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t2):"r"(srcp),[offset_plus] "i" (OFFSET + 12):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t3):"r"(srcp),[offset_plus] "i" (OFFSET + 13):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t0),"r"(dstp),[offset_plus] "i" (OFFSET + 4):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t1),"r"(dstp),[offset_plus] "i" (OFFSET + 5):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t2),"r"(dstp),[offset_plus] "i" (OFFSET + 12):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t3),"r"(dstp),[offset_plus] "i" (OFFSET + 13):"memory");	\
		\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t0):"r"(srcp),[offset_plus] "i" (OFFSET + 6):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t1):"r"(srcp),[offset_plus] "i" (OFFSET + 7):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t2):"r"(srcp),[offset_plus] "i" (OFFSET + 14):"memory");	\
		asm volatile ("lbu\t%0,%c[offset_plus](%1)":"=r"(t3):"r"(srcp),[offset_plus] "i" (OFFSET + 15):"memory");	\
		srcp += 8;	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t0),"r"(dstp),[offset_plus] "i" (OFFSET + 6):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t1),"r"(dstp),[offset_plus] "i" (OFFSET + 7):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t2),"r"(dstp),[offset_plus] "i" (OFFSET + 14):"memory");	\
		asm volatile ("sb\t%0,%c[offset_plus](%1)"::"r"(t3),"r"(dstp),[offset_plus] "i" (OFFSET + 15):"memory");	\
		dstp += 8;	\
		asm volatile ("prefetch.r\t384(%0)"::"r"(srcp));

