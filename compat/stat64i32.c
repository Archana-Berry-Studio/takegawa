/*
 * compat/stat64i32.c — link shim for prebuilt MochiBerry engine objects.
 *
 * Old mingw-w64 builds named the large-file stat variant `stat64i32`; the
 * object files shipped in a prebuilt libmbjs.a (mbjs-libc.o) still reference
 * it. Newer mingw-w64 (>= 12, used here with gcc 15) removed the name and
 * merged it into `stat`, so the symbol is undefined at link time.
 *
 * `stat64i32` was always the 64-bit stat with a 32-bit st_nlink, which on
 * x86_64 mingw-w64 has exactly the same layout as `struct stat` (88 bytes),
 * so forwarding straight to `stat` is ABI-compatible.
 *
 * If your toolchain still ships its own `stat64i32`, this file will fail the
 * link with a multiple-definition error — that failure is loud, not silent.
 */
#include <sys/stat.h>
#include <sys/types.h>

int stat64i32(const char *pathname, struct stat *statbuf)
{
    return stat(pathname, statbuf);
}
