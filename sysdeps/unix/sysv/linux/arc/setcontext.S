/* Set current context for ARC.
   Copyright (C) 2020-2025 Free Software Foundation, Inc.
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

#include "ucontext-macros.h"

/* int setcontext (const ucontext_t *ucp)
     - Restores the machine context in @ucp and resumes execution
       (doesn't return to caller).  */

ENTRY (__setcontext)

	MOVR  r9, r0	/* Stash @ucp across syscall.  */

	/* rt_sigprocmask (SIG_SETMASK, &ucp->uc_sigmask, NULL, _NSIG8).  */
	mov  r3, _NSIG8
	mov  r2, 0
	ADDR  r1, r0, UCONTEXT_SIGMASK
	mov  r0, SIG_SETMASK
	mov  r8, __NR_rt_sigprocmask
	ARC_TRAP_INSN
	BRRhi r0, -1024, L (call_syscall_err)

	/* Restore scratch/arg regs for makecontext case.  */
	add r9, r9, UCONTEXT_MCONTEXT
	LDR.as r0,    r9, 22
	LDR.as r1,    r9, 21
	LDR.as r2,    r9, 20
	LDR.as r3,    r9, 19
	LDR.as r4,    r9, 18
	LDR.as r5,    r9, 17
	LDR.as r6,    r9, 16
	LDR.as r7,    r9, 15

	/* Restore callee saved registers.  */
	LDR.as r13,   r9, 37
	LDR.as r14,   r9, 36
	LDR.as r15,   r9, 35
	LDR.as r16,   r9, 34
	LDR.as r17,   r9, 33
	LDR.as r18,   r9, 32
	LDR.as r19,   r9, 31
	LDR.as r20,   r9, 30
	LDR.as r21,   r9, 29
	LDR.as r22,   r9, 28
	LDR.as r23,   r9, 27
	LDR.as r24,   r9, 26

	LDR.as blink, r9,  7
	LDR.as fp,    r9,  8
	LDR.as gp,    r9,  9
	LDR.as sp,    r9, 23

#if defined (__ARC_FLOAT_ABI_HARD__)
	FLDR.as	f0,   r9, 43
	FLDR.as	f1,   r9, 44
	FLDR.as	f2,   r9, 45
	FLDR.as	f3,   r9, 46
	FLDR.as	f4,   r9, 47
	FLDR.as	f5,   r9, 48
	FLDR.as	f6,   r9, 49
	FLDR.as	f7,   r9, 50

	FLDR.as	f16,  r9, 51
	FLDR.as	f17,  r9, 52
	FLDR.as	f18,  r9, 53
	FLDR.as	f19,  r9, 54
	FLDR.as	f20,  r9, 55
	FLDR.as	f21,  r9, 56
	FLDR.as	f22,  r9, 57
	FLDR.as	f23,  r9, 58
	FLDR.as	f24,  r9, 59
	FLDR.as	f25,  r9, 60
	FLDR.as	f26,  r9, 61
	FLDR.as	f27,  r9, 62
	FLDR.as	f28,  r9, 63
	FLDR.as	f29,  r9, 64
	FLDR.as	f30,  r9, 66
	FLDR.as	f31,  r9, 68
#endif

	j    [blink]

PSEUDO_END (__setcontext)
weak_alias (__setcontext, setcontext)


/* Helper for activating makecontext created context
     - r14 has @func, r15 has uc_link.  */

ENTRY (__startcontext)

	.cfi_label .Ldummy
	cfi_undefined (blink)

	/* Call user @func, loaded in r14 by setcontext.  */
	jl   [r14]

	/* If uc_link (r15) call setcontext with that.  */
	MOVR  r0, r15
	BRReq r0, 0, 1f

	bl   __setcontext
1:
	/* Exit with status 0.  */
	b    HIDDEN_JUMPTARGET(exit)
END (__startcontext)
