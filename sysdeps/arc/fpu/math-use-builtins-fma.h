#if defined __ARC_FPU_DP_DIV__
# define USE_SQRT_BUILTIN 1
#else
# define USE_SQRT_BUILTIN 0
#endif

#if defined __ARC_FPU_SP_DIV__
# define USE_SQRTF_BUILTIN 1
#else
# define USE_SQRTF_BUILTIN 0
#endif

#define USE_FMAL_BUILTIN 0
#define USE_FMAF128_BUILTIN 0
