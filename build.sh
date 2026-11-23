#!/usr/bin/env bash
# Build the takegawa launcher against a MochiBerry engine build.
#   MOCHIBERRY_DIR must contain build_manual/libmbjs.a (and the headers are
#   vendored in ./include). Set it or pass it: MOCHIBERRY_DIR=/path ./build.sh
set -eu

ROOT=$(cd "$(dirname "$0")" && pwd)
cd "$ROOT"

if [ -z "${MOCHIBERRY_DIR:-}" ]; then
  echo "error: MOCHIBERRY_DIR not set (must point at a MochiBerry checkout with build_manual/libmbjs.a)" >&2
  exit 1
fi
LIB="$MOCHIBERRY_DIR/build_manual/libmbjs.a"
if [ ! -f "$LIB" ]; then
  echo "error: $LIB not found — build the MochiBerry engine first (scripts/build_manual.sh)" >&2
  exit 1
fi

CC="${CC:-gcc}"
CFLAGS="-O2 -g -std=gnu11 -D_GNU_SOURCE -Iinclude -I$MOCHIBERRY_DIR"
OUT=takegawa
case "$(uname -s)" in MINGW*|MSYS*) OUT=takegawa.exe ;; esac

# Native Windows toolchains need Windows-style paths, not MSYS mount paths.
if command -v cygpath >/dev/null 2>&1; then
  LIB=$(cygpath -w "$LIB")
  MB_INC=$(cygpath -w "$MOCHIBERRY_DIR")
  CFLAGS="-O2 -g -std=gnu11 -D_GNU_SOURCE -Iinclude -I$MB_INC"
fi

echo "== compile $OUT from takegawa.c"
$CC $CFLAGS -o "$OUT" takegawa.c compat/stat64i32.c "$LIB" -lm -lpthread
echo "== built ./$OUT"
echo "== run tests: $MOCHIBERRY_DIR/build_manual/mbjs.exe -m tests/test_takegawa.js"
