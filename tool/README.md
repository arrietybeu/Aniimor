# tool/ — build & deploy

| file | purpose |
|------|---------|
| `build.py` | `client/*.lua` → `build/LuaScripts.xdf` + `.xdt`. Recompiles via `xlua.dll`, repacks in the original archive format (STORE `.lua`, original order), regenerates the matching `.xdt` manifest, then self-verifies. |
| `deploy.py` | Deploys `build/` into the live client (both copies), refreshes `LuaCacheVer.txt` + `md5list.txt`. `--restore` = undo from `reference/`; `--verify` = show on-disk state. |
| `recompiler.exe` | Loads `xlua.dll`, `luaL_loadbufferx` + `lua_dump`: source → game bytecode. Batch mode: `recompiler.exe xlua.dll -batch manifest.txt` (lines `in⇥out⇥chunkname`). |
| `xlua.dll` | The client's own LuaJIT (custom opcode table). Copy of `<client>/BuildTest_Internal_Data/Plugins/x86_64/xlua.dll`. |
| `reference/` | Pristine originals: `LuaScripts.orig.xdf/.xdt`, `md5list.orig.txt`, `LuaCacheVer.orig.txt`. Build input (order/header/non-lua passthrough) **and** restore source. |
| `decompiler/` | Re-derive `client/` from raw bytecode: patched `luajit-decompiler-v2`, `xlua_bcdump_driver.exe` (opcode recovery), `remap.py`, `OPCODE_MAP.txt`. |

## Commands

```bash
python3 build.py             # full build
python3 build.py --repack    # reuse build/bc, repack + manifest only (fast)
python3 deploy.py            # deploy into client (close the game first)
python3 deploy.py --restore  # restore originals
python3 deploy.py --verify   # status only
```

## Deploy target (fixed in deploy.py)

```
D:/Stream/steamapps/common/Aniimo
  Aniimo_Data/StreamingAssets/cvs/res/lua/   (source of truth, listed in md5list.txt)
  Aniimo_Data/cvs/res/lua/                   (runtime cache: xdf/xdt + LuaCacheVer.txt + 14 loose bins)
  md5list.txt                                (launcher/repair manifest)
```
Edit the `GAME` constant in `deploy.py` if the install path differs.

## Rebuilding the binaries

- `recompiler.exe` ← `decompiler/…`/`recompiler.c`, MSVC: `cl /O2 recompiler.c`.
- `xlua.dll` ← copy from the client's `Plugins/x86_64/xlua.dll` (do not commit).
- decompiler ← patched `luajit-decompiler-v2` (TGETR/TSETR support + headless robustness), `cl /J /EHa /O2`.
