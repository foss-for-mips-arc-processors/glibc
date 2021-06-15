/* PLT trampolines.  ARC version.
   Copyright (C) 2020-2024 Free Software Foundation, Inc.
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
#include <libc-symbols.h>

#include <sysdep.h>
#include <sys/syscall.h>

/* resolver has atypical calling ABI (r11 and r12)
        PLTn which lands us here, sets up
	r11 = Module info (tpnt pointer as expected by resolver)
	r12 = PC of the PLTn itself - needed by resolver to find
	      corresponding .rela.plt entry.  */

ENTRY (_dl_runtime_resolve)

	/* save args to func being resolved before entering resolver.  */
	PUSHR	r0
	PUSHR	r1
	PUSHR	r2
	PUSHR	r3
	PUSHR	r4
	PUSHR	r5
	PUSHR	r6
	PUSHR	r7
	PUSHR	r8
	PUSHR	r9

#if defined (__ARC_FLOAT_ABI_HARD__)
	FPUSHR	f0
	FPUSHR	f1
	FPUSHR	f2
	FPUSHR	f3
	FPUSHR	f4
	FPUSHR	f5
	FPUSHR	f6
	FPUSHR	f7
	cfi_adjust_cfa_offset (18*REGSZ)
#else
	cfi_adjust_cfa_offset (10*REGSZ)
#endif

	PUSHR	blink
	cfi_adjust_cfa_offset (REGSZ)
	cfi_rel_offset (blink, 0)

	MOVR 	r1, r12
	bl.d  	_dl_fixup
	MOVR   	r0, r11

	/* restore regs back.  */
	POPR	blink
	cfi_adjust_cfa_offset (-REGSZ)
	cfi_restore (blink)

#if defined (__ARC_FLOAT_ABI_HARD__)
	FPOPR	f7
	FPOPR	f6
	FPOPR	f5
	FPOPR	f4
	FPOPR	f3
	FPOPR	f2
	FPOPR	f1
	FPOPR	f0
#endif
	POPR    r9
	POPR    r8
	POPR    r7
	POPR    r6
	POPR    r5
	POPR    r4
	POPR    r3
	POPR    r2
	POPR    r1
#if defined (__ARC_FLOAT_ABI_HARD__)
	cfi_adjust_cfa_offset (-17*REGSZ)
#else
	cfi_adjust_cfa_offset (-9*REGSZ)
#endif

	j.d   [r0]    /* r0 has resolved function addr.  */
	POPR    r0      /* restore first arg to resolved call.  */
	cfi_adjust_cfa_offset (-REGSZ)
	cfi_restore (r0)
END (_dl_runtime_resolve)
