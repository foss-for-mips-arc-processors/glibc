GLIBC_PROVIDES dnl See aclocal.m4 in the top level source directory.
# Local configure fragment for sysdeps/arc.

libc_cv_have_sdata_section=no

# For ARC, historically ; was used for comments and not newline
# Later # also got added to comment list, but ; couldn't be switched to
# canonical newline as there's lots of code out there which will break
libc_cv_asm_line_sep='`'
AC_DEFINE_UNQUOTED(ASM_LINE_SEP, $libc_cv_asm_line_sep)

# For ARC64 generate a symbol for selecting right dynamic linker
AC_CACHE_CHECK([for arc64],
  [libc_cv_arc64],
  [AC_EGREP_CPP(yes,[#ifdef __ARC64__
                      yes
                     #endif
  ], libc_cv_arc64=yes, libc_cv_arc64=no)])
if test $libc_cv_arc64 = yes; then
  # For shlib-versions.
  AC_DEFINE(HAVE_ARC64)
  LIBC_CONFIG_VAR([default-abi], [arc64le])

else

# For big endian ABI, generate a symbol for selecting right dynamic linker
AC_CACHE_CHECK([for big endian],
  [libc_cv_arc_be],
  [AC_EGREP_CPP(yes,[#ifdef __BIG_ENDIAN__
                      yes
                     #endif
  ], libc_cv_arc_be=yes, libc_cv_arc_be=no)])
if test $libc_cv_arc_be = yes; then
  # For shlib-versions.
  AC_DEFINE(HAVE_ARC_BE)
  LIBC_CONFIG_VAR([default-abi], [arcbe])
else
  LIBC_CONFIG_VAR([default-abi], [arcle])
fi

fi
