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
	cfi_adjust_cfa_offset (10*REGSZ)
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
	POPR    r9
	POPR    r8
	POPR    r7
	POPR    r6
	POPR    r5
	POPR    r4
	POPR    r3
	POPR    r2
	POPR    r1
	cfi_adjust_cfa_offset (-9*REGSZ)

	j.d   [r0]    /* r0 has resolved function addr.  */
	POPR    r0      /* restore first arg to resolved call.  */
	cfi_adjust_cfa_offset (-REGSZ)
	cfi_restore (r0)
END (_dl_runtime_resolve)
