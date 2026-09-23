# -*- coding: utf-8 -*-
"""
build.py - End-to-end Lua hot-update builder for Aniimo/worldx.

  client/*.lua  --(recompile via game xlua.dll)-->  build/bc/*.lua (game-format bytecode)
                --(repack, original .xdf format)-->  build/LuaScripts.xdf
                --(regenerate matching manifest)-->  build/LuaScripts.xdt

Project-relative; no paths outside the project except the (fixed) deploy target in deploy.py.

Facts baked in (verified against the shipped client):
  * .xdf is a standard ZIP. .lua entries are STORED (uncompressed); the 67 non-lua entries
    (pmdata.bin / Compress_*.bin / *.proto / conf*.json / *.meta) are DEFLATE.
  * The game does NOT parse the ZIP at runtime: it uses .xdt as the index and seeks by CEOffset.
  * .xdt CEMD5 = md5 of the entry's DECOMPRESSED content. CMDataMD5 = md5 of the whole .xdf.
  * Entry ORDER must match the original manifest; header fields (CMSign/CMVersion/CMToolVer/
    CMCompress) are carried from the original .xdt. CMSign==0 => integrity is MD5 only (no signature).

Usage:  python3 build.py            # full build (recompile + repack + xdt)
        python3 build.py --repack   # skip recompile, reuse build/bc (fast repack only)
"""
import os, sys, re, time, json, io, struct, zipfile, hashlib, subprocess, collections

HERE   = os.path.dirname(os.path.abspath(__file__))          # .../Aniimo/tool
ROOT   = os.path.dirname(HERE)                               # .../Aniimo
CLIENT = os.path.join(ROOT, "client")
BUILD  = os.path.join(ROOT, "build")
BCOUT  = os.path.join(BUILD, "bc")
RECOMP = os.path.join(HERE, "recompiler.exe")
XLUA   = os.path.join(HERE, "xlua.dll")
REF_XDF = os.path.join(HERE, "reference", "LuaScripts.orig.xdf")   # template: order + non-lua
REF_XDT = os.path.join(HERE, "reference", "LuaScripts.orig.xdt")   # template: order + header
OUT_XDF = os.path.join(BUILD, "LuaScripts.xdf")
OUT_XDT = os.path.join(BUILD, "LuaScripts.xdt")
MANIFEST = os.path.join(BUILD, "_recompile_manifest.txt")

# ---- entry name in archive is the client-relative path, forward slashes ----
def arc_name(src):    # E:/.../client/xfs/luascripts/... -> xfs/luascripts/...
    return os.path.relpath(src, CLIENT).replace("\\", "/")

def recompile():
    files = [os.path.join(dp, f) for dp, _, fn in os.walk(CLIENT) for f in fn if f.endswith(".lua")]
    files.sort()
    print("  source .lua:", len(files))
    os.makedirs(BCOUT, exist_ok=True)
    with open(MANIFEST, "w", encoding="utf-8") as m:
        for src in files:
            rel = arc_name(src)
            out = os.path.join(BCOUT, rel.replace("/", os.sep))
            os.makedirs(os.path.dirname(out), exist_ok=True)
            chunk = "@" + rel                              # default chunkname
            try:                                            # prefer embedded "-- chunkname: @..."
                first = open(src, encoding="utf-8", errors="replace").readline()
                mm = re.search(r"chunkname:\s*(@[^\r\n]+)", first)
                if mm: chunk = mm.group(1).replace("\\\\", "\\")
            except Exception:
                pass
            m.write("%s\t%s\t%s\n" % (src, out, chunk))
    print("  recompiling via game xlua.dll ...")
    t0 = time.time()
    r = subprocess.run([RECOMP, XLUA, "-batch", MANIFEST], capture_output=True, text=True)
    errs = [l for l in (r.stderr or "").splitlines() if l.startswith("COMPILE_ERROR")]
    tail = (r.stderr or "").splitlines()[-1] if r.stderr else ""
    print("  ", tail, "| compile failures:", len(errs))
    for l in errs[:10]: print("     ", l[:160])
    bc = [os.path.join(dp, f) for dp, _, fn in os.walk(BCOUT) for f in fn if f.endswith(".lua")]
    print("  recompiled bytecode:", len(bc), "in %.1fs" % (time.time() - t0))
    if errs:
        print("  WARNING: %d files failed to compile (see above)." % len(errs))
    return len(bc)

def build_xdf():
    j = json.loads(open(REF_XDT, "rb").read().decode("utf-8"))
    order = [e["CEName"] for e in j["CMList"]]
    cont  = {e["CEName"]: e.get("CEContainer", 0) for e in j["CMList"]}
    header = {k: j[k] for k in j if k != "CMList"}
    zin = zipfile.ZipFile(REF_XDF, "r")
    orig_ct = {i.filename: i.compress_type for i in zin.infolist()}
    used_bc = fallback = passthrough = 0
    os.makedirs(BUILD, exist_ok=True)
    with zipfile.ZipFile(OUT_XDF, "w", allowZip64=False) as z:
        for name in order:
            bc = os.path.join(BCOUT, name.replace("/", os.sep))
            if name.lower().endswith(".lua") and os.path.isfile(bc):
                data, ct = open(bc, "rb").read(), zipfile.ZIP_STORED          # lua = STORE
                used_bc += 1
            else:
                data, ct = zin.read(name), orig_ct.get(name, zipfile.ZIP_DEFLATED)
                if name.lower().endswith(".lua"): fallback += 1
                else: passthrough += 1
            zi = zipfile.ZipInfo(filename=name); zi.compress_type = ct
            zi.date_time = (1980, 1, 1, 0, 0, 0); zi.external_attr = 0
            z.writestr(zi, data)
    zin.close()
    print("  .xdf: lua_bytecode=%d fallback_orig=%d non_lua=%d total=%d"
          % (used_bc, fallback, passthrough, used_bc + fallback + passthrough))
    if fallback: print("  WARNING: %d lua entries missing bytecode -> original carried." % fallback)
    return header, cont

def _data_off(fp, header_offset):
    fp.seek(header_offset); lh = fp.read(30)
    assert lh[:4] == b"PK\x03\x04"
    return header_offset + 30 + struct.unpack("<H", lh[26:28])[0] + struct.unpack("<H", lh[28:30])[0]

def regen_xdt(header, cont):
    whole = open(OUT_XDF, "rb").read(); fp = io.BytesIO(whole)
    z = zipfile.ZipFile(OUT_XDF, "r"); cmlist = []
    for idx, zi in enumerate(z.infolist()):
        off = _data_off(fp, zi.header_offset)
        content = z.read(zi.filename)                    # decompressed
        cmlist.append(collections.OrderedDict([
            ("CEName", zi.filename), ("CEMD5", hashlib.md5(content).hexdigest()),
            ("CESize", zi.file_size), ("CEIndex", idx), ("CEOffset", off),
            ("CECSize", zi.compress_size), ("CEContainer", cont.get(zi.filename, 0))]))
    z.close()
    out = collections.OrderedDict()
    for k in ("CMSign", "CMVersion", "CMToolVer", "CMCompress"): out[k] = header.get(k, 0)
    out["CMDataLen"] = len(whole); out["CMDataMD5"] = hashlib.md5(whole).hexdigest()
    out["CMEntryNum"] = len(cmlist); out["CMList"] = cmlist
    open(OUT_XDT, "w", encoding="utf-8", newline="\n").write(
        json.dumps(out, indent=4, ensure_ascii=False))
    return out

def verify(out):
    whole = open(OUT_XDF, "rb").read(); fp = io.BytesIO(whole)
    assert out["CMDataLen"] == len(whole) and out["CMDataMD5"] == hashlib.md5(whole).hexdigest()
    z = zipfile.ZipFile(OUT_XDF, "r"); bad = 0
    for e in out["CMList"]:
        content = z.read(e["CEName"])
        if (hashlib.md5(content).hexdigest() != e["CEMD5"] or len(content) != e["CESize"]
                or _data_off(fp, z.getinfo(e["CEName"]).header_offset) != e["CEOffset"]):
            bad += 1
            if bad <= 5: print("     MISMATCH:", e["CEName"])
    z.close()
    e0 = next(e for e in out["CMList"] if e["CEName"].lower().endswith(".lua"))
    magic = whole[e0["CEOffset"]:e0["CEOffset"]+3]
    print("  verify: entries=%d md5_mismatch=%d first_lua_magic=%s xdf=%d bytes"
          % (len(out["CMList"]), bad, "OK(1bLJ)" if magic == b"\x1bLJ" else "BAD:"+magic.hex(), len(whole)))
    return bad == 0

def main():
    repack_only = "--repack" in sys.argv
    for p in (RECOMP, XLUA, REF_XDF, REF_XDT):
        if not os.path.isfile(p): print("MISSING:", p); return 2
    print("[1] recompile client -> build/bc" + (" (SKIPPED, --repack)" if repack_only else ""))
    if not repack_only: recompile()
    elif not os.path.isdir(BCOUT): print("  no build/bc; run without --repack first"); return 2
    print("[2] repack build/LuaScripts.xdf (STORE lua, original order)"); header, cont = build_xdf()
    print("[3] regenerate build/LuaScripts.xdt (matching manifest)"); out = regen_xdt(header, cont)
    print("[4] verify"); ok = verify(out)
    print("=" * 58)
    print("XDF:", OUT_XDF, "(%d bytes)" % os.path.getsize(OUT_XDF))
    print("XDT:", OUT_XDT, "  CMDataMD5:", out["CMDataMD5"])
    print("RESULT:", "OK - ready. Deploy with: python3 deploy.py" if ok else "FAILED")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
