/* memcpy implementation for MIPS riscv cores.
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

#include <stddef.h>
#include "mips-riscv-i8500.h"

#undef libc_hidden_builtin_def
#define libc_hidden_builtin_def(a)

/* The unroll-factor controls how many words at a time in the core loop.  */
#define BLOCK_SIZE 8

typedef unsigned long reg_t;

#define DO_BYTE(a, b, i)   \
  a[i] = b[i];     \
  len--;      \
  if (!len) return ret;  \

/* This code is called when aligning a pointer, there are remaining bytes
   after doing word compares, or architecture does not have some form
   of unaligned support.  */
static inline void * __attribute__ ((always_inline))
do_bytes (void *a, const void *b, unsigned long len, void *ret)
{
  unsigned char *x = (unsigned char *) a;
  unsigned char *y = (unsigned char *) b;
  unsigned long i;
  /* 'len' might be zero here, so preloading the first two values
     before the loop may access unallocated memory.  */
  for (i = 0; i < len; i++)
    {
      *x = *y;
      x++;
      y++;
    }
  return ret;
}

// src pointer 'b' is aligned to 8-bytes
static inline void * __attribute__ ((always_inline))
do_words (void *a, const void *b, unsigned long len, void *ret)
{
  reg_t *x = (reg_t *) a;
  reg_t *y = (reg_t *) b;
  unsigned long i;
  /* 'len' might be zero here, so preloading the first two values
    before the loop may access unallocated memory.  */
  for (i = 0; i < len; i++)
    {
      *x = *y;
      x++;
      y++;
    }

  return ret;
}

/* This code is called to copy only remaining bytes within word
 * or doubleword.  */
static inline void * __attribute__ ((always_inline))
do_bytes_remaining (void *a, const void *b, unsigned long len, void *ret)
{
  unsigned char *x = (unsigned char *) a;
  const unsigned char *y = (const unsigned char *) b;
  if (len > 0)
    {
      DO_BYTE (x, y, 0);
      DO_BYTE (x, y, 1);
      DO_BYTE (x, y, 2);
#if __riscv_xlen == 64
      DO_BYTE (x, y, 3);
      DO_BYTE (x, y, 4);
      DO_BYTE (x, y, 5);
      DO_BYTE (x, y, 6);
#endif  /* __riscv_xlen == 64.  */
    }
  return ret;
}

// copy remaining words when src pointer 'b' is unaligned
static inline void * __attribute__ ((always_inline))
do_words_remaining_src_unaligned (reg_t *a, const reg_t *b, unsigned long words,
		    unsigned long bytes, void *ret)
{
  int off = (BLOCK_SIZE - words);
  a -= off;
  b -= off;

  unsigned char *x = (unsigned char *) a;
  const unsigned char *y = (const unsigned char *) b;
  long t0, t1, t2, t3;
  switch (off)
    {
      case 1: UNALIGNED_WORD_COPY (x + 8, y + 8, 0);
      case 2: UNALIGNED_WORD_COPY (x + 16, y + 16, 0);
      case 3: UNALIGNED_WORD_COPY (x + 24, y + 24, 0);
      case 4: UNALIGNED_WORD_COPY (x + 32, y + 32, 0);
      case 5: UNALIGNED_WORD_COPY (x + 40, y + 40, 0);
      case 6: UNALIGNED_WORD_COPY (x + 48, y + 48, 0);
      case 7: UNALIGNED_WORD_COPY (x + 56, y + 56, 0);
    }

  return do_bytes_remaining (a + BLOCK_SIZE, b + BLOCK_SIZE, bytes, ret);
}

// copy remaining words when src pointer 'b' is aligned
static inline void * __attribute__ ((always_inline))
do_words_remaining_src_aligned (reg_t *a, const reg_t *b, unsigned long words,
		    unsigned long bytes, void *ret)
{
  int off = (BLOCK_SIZE - words);
  a -= off;
  b -= off;

  switch (off)
    {
      case 1: a[1] = b[1];
      case 2: a[2] = b[2];
      case 3: a[3] = b[3];
      case 4: a[4] = b[4];
      case 5: a[5] = b[5];
      case 6: a[6] = b[6];
      case 7: a[7] = b[7];
    }

  return do_bytes_remaining (a + BLOCK_SIZE, b + BLOCK_SIZE, bytes, ret);
}

/* both pointers are aligned, or first isn't and HW support for unaligned.  */
static void *
copyloop_src_unaligned (void * aa, const void * bb,
	       unsigned long words, unsigned long bytes, void *ret)
{
  reg_t *a = (reg_t *) aa;
  const reg_t *b = (const reg_t *) bb;
  unsigned long i, words_by_block, words_by_1;
  words_by_1 = words % BLOCK_SIZE;
  words_by_block = words / BLOCK_SIZE;

#ifdef __riscv_mips_i8500
  long t0, t1, t2, t3, t4, t5, t6, t7;
  long src_align = (reg_t)b & ALIGN_AT_64_BYTES_MASK;
  if ((src_align >= 0x01 && src_align <= 0x07)
      || (src_align >= 0x09 && src_align <= 0x0f))
  {
    for (; words_by_block > 0; words_by_block--)
    {
      UNALIGNED_COPY_LOOP_PREF (a, b, 0, 16, 32, 48);
    }
  } else if ((src_align >= 0x11 && src_align <= 0x17)
      || (src_align >= 0x19 && src_align <= 0x1f))
  {
    for (; words_by_block > 0; words_by_block--)
    {
      UNALIGNED_COPY_LOOP_PREF (a, b, 0, 16, 48, 32);
    }
  } else if ((src_align >= 0x21 && src_align <= 0x27)
      || (src_align >= 0x29 && src_align <= 0x2f))
  {
    for (; words_by_block > 0; words_by_block--)
    {
      UNALIGNED_COPY_LOOP_PREF (a, b, 0, 32, 48, 16);
    }
  } else if ((src_align >= 0x31 && src_align <= 0x37)
      || (src_align >= 0x39 && src_align <= 0x3f))
  {
    for (; words_by_block > 0; words_by_block--)
    {
      UNALIGNED_COPY_LOOP_PREF (a, b, 16, 32, 48, 0);
    }
  }
#endif

  /* mop up any remaining bytes.  */
  return do_words_remaining_src_unaligned (a, b, words_by_1, bytes, ret);
}

static void *
copyloop_src_aligned (void * aa, const void * bb,
	       unsigned long words, unsigned long bytes, void *ret)
{
  reg_t *a = (reg_t *) aa;
  const reg_t *b = (const reg_t *) bb;
  unsigned long i, words_by_block, words_by_1;
  words_by_1 = words % BLOCK_SIZE;
  words_by_block = words / BLOCK_SIZE;

#ifdef __riscv_mips_i8500
  long t0, t1, t2, t3, t4, t5, t6, t7;

  for (; words_by_block > 0; words_by_block--)
  {
  #ifdef __riscv_zicboz
    ALIGNED_COPY_LOOP_PREF_CBO (a, b);
  #else
    ALIGNED_COPY_LOOP_PREF (a, b);
  #endif
  }
#endif

  /* mop up any remaining bytes.  */
  return do_words_remaining_src_aligned (a, b, words_by_1, bytes, ret);
}

/* memcpy version when src ptr is aligned to word boundary.  */
static void*
memcpy_src_aligned (void *a, const void *b, size_t len, void *ret)
{
  unsigned long bytes, words;

  if (len >= 64)
  {   // we need to make sure we have atleast 64 bytes to copy
#ifdef __riscv_zicboz
    /* Align the dest pointer to 64 bytes alignment for cbo.zero.  */
    bytes = ((unsigned long) a) % 64;
    if (bytes)
    {
      bytes = 64 - bytes;
      do_words (a, b, bytes / sizeof (reg_t), ret);
      len -= bytes;
      a = (void *) (((unsigned char *) a) + bytes);
      b = (void *) (((unsigned char *) b) + bytes);
    }
#else
    /* Align the first pointer to 16 bytes alignment for prefetch.  */
    bytes = ((unsigned long) a) % 16;
    if (bytes)
    {
      bytes = 16 - bytes;
      do_words (a, b, bytes / sizeof (reg_t), ret);
      len -= bytes;
      a = (void *) (((unsigned char *) a) + bytes);
      b = (void *) (((unsigned char *) b) + bytes);
    }
#endif	// __riscv_zicboz
  }

  words = len / sizeof (reg_t);
  bytes = len % sizeof (reg_t);

  return copyloop_src_aligned (a, b, words, bytes, ret);
}

/* memcpy version when src ptr is unaligned to word boundary.  */
static void*
memcpy_src_unaligned (void *a, const void *b, size_t len, void *ret)
{
  unsigned long bytes, words;

  if (len >= 64)
  {
    /* Align the first pointer to 16 bytes alignment for prefetch.  */
	  bytes = ((unsigned long) a) % 16;
    if (bytes)
	  {
		  bytes = 16 - bytes;
      do_bytes (a, b, bytes, ret);
      len -= bytes;
		  a = (void *) (((unsigned char *) a) + bytes);
      b = (void *) (((unsigned char *) b) + bytes);
	  }
  }

  words = len / sizeof (reg_t);
  bytes = len % sizeof (reg_t);

  return copyloop_src_unaligned (a, b, words, bytes, ret);
}

void *
__memcpy_mips_riscv (void *a, const void *b, size_t len)
{
  unsigned long bytes, words, i;
  void *ret = a;
  /* shouldn't hit that often.  */
  if (len <= 8)
    return do_bytes (a, b, len, a);

  /* Align the dest pointer to word/dword alignment.  */
  bytes = ((unsigned long) a) % (sizeof (reg_t));
  if (bytes)
    {
      bytes = (sizeof (reg_t)) - bytes;
      do_bytes (a, b, bytes, ret);
      len -= bytes;
      a = (void *) (((unsigned char *) a) + bytes);
      b = (void *) (((unsigned char *) b) + bytes);
    }

  /* if the src pointer 'b' is unaligned, we call 2 versions of memcpy
   * one for unaligned src ptr and other one for aligned src ptr
   * this handles the case when src ptr is unaligned and cross 4k
   * page boundary.  */
  long src_align = (reg_t)b & ALIGN_AT_8_BYTES_MASK;
  if (src_align != 0)
    return memcpy_src_unaligned (a, b, len, ret);
  else
    return memcpy_src_aligned (a, b, len, ret);
}
libc_hidden_builtin_def (memcpy)
