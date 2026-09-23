# Aniimo / worldx — Lua hot-update project

Recovered Lua hot-update source for the Aniimo client, plus a toolchain to **edit → build →
deploy → test** it in the game. Produced during client-build security review (check #8): the Lua
protection (custom-remapped LuaJIT opcodes + `.xdf`/`.xdt` packaging + MD5 integrity) was fully
broken — 8623/8623 scripts decompiled, recompiled, repacked, and **verified running in the live
client** (connects to servers, passes integrity, reaches login handshake).

## Layout

```
Aniimo/
├─ client/                 Lua hot-update SOURCE (8623 .lua, editable — source of truth)
│  └─ xfs/luascripts/...   original package tree (Common, Core, Data, Manager, Utils, ...)
├─ tool/                   build & deploy scripts
│  ├─ build.py             client/*.lua  ->  build/LuaScripts.xdf + .xdt   (recompile+repack+manifest)
│  ├─ deploy.py            build/  ->  live client  (+ --restore / --verify)
│  ├─ recompiler.exe       compiles .lua -> game-format bytecode via xlua.dll
│  ├─ xlua.dll             the client's LuaJIT (custom opcode table) — from Plugins/x86_64
│  ├─ reference/           pristine original .xdf/.xdt/md5list/LuaCacheVer (build input + restore) [gitignored]
│  └─ decompiler/          decompile toolchain (re-derive source from bytecode)
├─ build/                  build output: LuaScripts.xdf, .xdt, bc/  [gitignored, regenerated]
└─ .gitignore
```

## Workflow

```bash
# 1. edit any file under client/  (normal Lua source)

# 2. build  (recompile all + repack .xdf + regenerate matching .xdt)
python3 tool/build.py            # full build
python3 tool/build.py --repack   # fast: reuse build/bc, only repack+manifest

# 3. deploy into the live client  (close the game first)
python3 tool/deploy.py           # -> StreamingAssets + cache, refresh LuaCacheVer + md5list
                                 #    (makes .bak backups on first run)

# 4. launch & test.  log: %USERPROFILE%\AppData\LocalLow\Aniimo\Aniimo\Player.log

# 5. undo anytime
python3 tool/deploy.py --restore # restore pristine originals from tool/reference/
```

## How it works (packaging & integrity)

- **`LuaScripts.xdf`** is a standard ZIP. `.lua` entries are **STORED** (uncompressed); the 67
  non-lua entries (`pmdata.bin`, `Compress_*.bin`, `*.proto`, `conf*.json`, `*.meta`) are DEFLATE.
- The game does **not** parse the ZIP at runtime — it uses **`LuaScripts.xdt`** (a JSON index) and
  seeks by byte offset. Per entry: `CEOffset` (data offset), `CECSize` (bytes to read), `CESize`
  (uncompressed size), `CEMD5` (**md5 of the decompressed content**), `CEContainer`. Top level:
  `CMDataMD5` (md5 of the whole `.xdf`), `CMDataLen`, `CMEntryNum`, and `CMSign` = **0** → integrity
  is MD5-only, no cryptographic signature.
- **`LuaCacheVer.txt`** = `1.0.<CMVersion>,<xdt_size>,<xdt_md5>` — the runtime cache key.
- **`md5list.txt`** (game root) = launcher/repair manifest `md5,size,path` (paths use the `worldx_Data`
  codename; the shipped folder is `Aniimo_Data`).
- `build.py` reproduces this exactly: recompile via `xlua.dll` (already emits game-format bytecode —
  **no opcode remap needed** on the way in), repack preserving the original entry **order** and
  STORE/DEFLATE per entry, then regenerate `.xdt` by parsing the produced archive's real layout.
  `deploy.py` writes both client copies and refreshes `LuaCacheVer.txt` + `md5list.txt`.

## Bytecode & the custom opcode table

The shipped bytecode is **LuaJIT 2.1 GC64/FR2 with a remapped opcode table** (anti-decompile).
`tool/decompiler/` holds the patched `luajit-decompiler-v2`, the `xlua.dll` opcode-recovery driver,
`remap.py`, and `OPCODE_MAP.txt` (game↔standard map) used to re-derive `client/` from raw bytecode.
Recompilation goes the other way through `xlua.dll`, so it needs no remap.

## Notes

- Recompiled bytecode is **not** byte-identical to the original (debug info / constant ordering
  differ) but is semantically equivalent — round-trip verified, and runtime line numbers match the
  source exactly.
- `tool/reference/` and `build/` are gitignored (proprietary game data / regenerated output).
  `xlua.dll` comes from `<client>/…/Plugins/x86_64/xlua.dll`.
- Scope: authorized internal security review. Keep within the review sandbox.
