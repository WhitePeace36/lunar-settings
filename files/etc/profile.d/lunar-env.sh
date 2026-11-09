# Lunar environment for login shells (TTY, SSH). Mirrors
# /usr/lib/environment.d/60-lunar.conf; already-set values are kept.

: "${LD_BIND_NOW:=1}"
: "${PAGER:=most}"
: "${EDITOR:=micro}"
: "${VISUAL:=micro}"
: "${MESA_SHADER_CACHE_MAX_SIZE:=30G}"
: "${__GL_SHADER_DISK_CACHE_SIZE:=12000000000}"
: "${__GL_SHADER_DISK_CACHE_SKIP_CLEANUP:=1}"

export LD_BIND_NOW PAGER EDITOR VISUAL MESA_SHADER_CACHE_MAX_SIZE \
       __GL_SHADER_DISK_CACHE_SIZE __GL_SHADER_DISK_CACHE_SKIP_CLEANUP
