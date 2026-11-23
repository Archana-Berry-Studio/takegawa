# takegawa — TGPM, the MochiBerry package manager

`takegawa` is the package manager for [MochiBerry](../mochiberry) (mbjs), the
C99/QuickJS-NG JavaScript engine. It is a **separate tool from the engine** that
runs on top of it — the engine stays small and takegawa lives outside it.

TGPM keeps packages in a **single global, content-addressed store**: every
package tree is hashed (SHA-256) and stored once, and projects reference the
stored copy through a link (symlink, or directory junction on Windows). The
same package in many projects therefore consumes store space *once* instead of
being duplicated into every `node_modules`.

A copy mode is available for tools that insist on a real `node_modules`
directory, and an existing `node_modules` tree is also understood when
resolving dependencies.

## Layout

```
takegawa.c      native launcher — embeds the engine, registers the system
                modules (mbjs:std, mbjs:os, mbjs:bjson), locates takegawa.js
                and evaluates it with the CLI args forwarded.
takegawa.js     the actual TGPM implementation, a module that runs on the
                engine (ESM). Exports the public API for tests/embedding.
takegawa.man    roff man page (takegawa(1)).
tests/          tests/test_takegawa.js — run with `mbjs -m tests/test_takegawa.js`.
examples/       example manifest (takegawa.json).
include/        MochiBerry public API headers needed to build the launcher.
```

## Building

Requires a MochiBerry engine build (`libmbjs.a` + the public headers). Point
`MOCHIBERRY_DIR` at a checkout with a completed `build_manual/`:

```sh
export MOCHIBERRY_DIR=/path/to/mochiberry   # contains build_manual/libmbjs.a
./build.sh            # produces ./takegawa.exe (or ./takegawa)
```

or with make:

```sh
make MOCHIBERRY_DIR=/path/to/mochiberry
```

The launcher resolves `takegawa.js` in this order (same as the engine's own
lookup): `$TAKEGAWA_SRC`, `$TAKEGAWA_HOME/takegawa.js`,
`<exe-dir>/takegawa.js`, `<exe-dir>/../takegawa.js`,
`<exe-dir>/../share/takegawa/takegawa.js`, `$PWD/takegawa.js`.

## Usage

```
takegawa <command> [options]

  install [pkg]      install dependencies (or add pkg)
  add <pkg>[@range]  add a dependency and install
  fetch <url|tgz>    download/extract a package into the cache
  init               create a takegawa.json in the current directory
  exec <cmd...>      run a command with package bin directories on PATH
  remove <pkg>       remove a dependency and its link
  update             re-resolve against the newest allowed versions
  resolve            print the resolved dependency tree
  outdated           list dependencies with newer allowed versions
  info <pkg>         show resolved package metadata
  verify             verify the lockfile against the global store
  gc                 remove unreferenced entries from the global store
  link               link the current package into the store
  pack               pack the current package (tgpm tarball)
  run <script>       run a script from the manifest
```

The manifest is `takegawa.json` (or `package.json`). See
`examples/takegawa.json` for the shape (name, version, type, exports,
dependencies, devDependencies, scripts, and the `tgpm` block for
`linkMode`/`registry`).

## Testing

```sh
mbjs -m tests/test_takegawa.js
```

## License

MIT. The MochiBerry engine is MIT (QuickJS-NG heritage, Fabrice Bellard,
Charlie Gordon, Ben Noordhuis and contributors); see the MochiBerry repo for
the full engine license.
