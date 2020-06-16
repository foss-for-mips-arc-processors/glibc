ifeq ($(subdir),stdlib)
gen-as-const-headers += ucontext_i.sym
endif

ifeq ($(subdir),signal)
sysdep_routines += sigrestorer
endif

ifeq ($(subdir),misc)
# MIPS/Tile-style cacheflush routine
sysdep_headers += sys/cachectl.h
sysdep_routines += cacheflush
endif

abi-variants := arcle arcbe arc64le

ifeq (,$(filter $(default-abi),$(abi-variants)))
$(error Unknown ABI $(default-abi), must be one of $(abi-variants))
endif

abi-arcle-condition   := !defined __ARC64__ && !defined __BIG_ENDIAN__
abi-arcbe-condition   := !defined __ARC64__ &&  defined __BIG_ENDIAN__
abi-arc64le-condition :=  defined __ARC64__ && !defined __BIG_ENDIAN__
