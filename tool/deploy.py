# -*- coding: utf-8 -*-
"""
deploy.py - Deploy build/ artifacts into the live Aniimo client, or restore the originals.

  python3 deploy.py            deploy build/LuaScripts.xdf+.xdt into the client + refresh integrity
  python3 deploy.py --restore  restore pristine originals from tool/reference/ (undo)
  python3 deploy.py --verify   print on-disk md5/size vs build/ (no changes)

Deploys to BOTH the source-of-truth (StreamingAssets/cvs/res/lua) and the runtime cache
(Aniimo_Data/cvs/res/lua), rewrites LuaCacheVer.txt to the new .xdt md5/size, and patches the
two LuaScripts lines in md5list.txt. First run makes idempotent .bak backups next to each file.
"""
import os, sys, shutil, hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
BUILD = os.path.join(ROOT, "build")
SRC_XDF = os.path.join(BUILD, "LuaScripts.xdf")
SRC_XDT = os.path.join(BUILD, "LuaScripts.xdt")
REF = os.path.join(HERE, "reference")

# ---- fixed live-client target (Steam install) ----
GAME = "D:/Stream/steamapps/common/Aniimo"
SA   = GAME + "/Aniimo_Data/StreamingAssets/cvs/res/lua"   # source of truth (listed in md5list)
CA   = GAME + "/Aniimo_Data/cvs/res/lua"                   # runtime cache copy
MD5  = GAME + "/md5list.txt"

def md5f(p): return hashlib.md5(open(p, "rb").read()).hexdigest()
def _bak(p): return p + ".bak"

def backup(p):
    if os.path.exists(p) and not os.path.exists(_bak(p)):
        shutil.copy2(p, _bak(p)); print("   backup ->", os.path.basename(_bak(p)))

def patch_md5list(xdf_md5, xdf_sz, xdt_md5, xdt_sz):
    if not os.path.exists(MD5): return 0
    data = open(MD5, "rb").read(); nl = b"\r\n" if b"\r\n" in data else b"\n"
    lines = data.split(nl); cnt = 0
    for i, ln in enumerate(lines):
        s = ln.decode("utf-8", "replace")
        if s.count(",") >= 2 and s.endswith("/lua/LuaScripts.xdf"):
            lines[i] = ("%s,%d,%s" % (xdf_md5, xdf_sz, s.split(",", 2)[2])).encode(); cnt += 1
        elif s.count(",") >= 2 and s.endswith("/lua/LuaScripts.xdt"):
            lines[i] = ("%s,%d,%s" % (xdt_md5, xdt_sz, s.split(",", 2)[2])).encode(); cnt += 1
    open(MD5, "wb").write(nl.join(lines)); return cnt

def deploy():
    for p in (SRC_XDF, SRC_XDT):
        if not os.path.isfile(p): print("MISSING build artifact:", p, "\n-> run build.py first"); return 2
    xdf_md5, xdf_sz = md5f(SRC_XDF), os.path.getsize(SRC_XDF)
    xdt_md5, xdt_sz = md5f(SRC_XDT), os.path.getsize(SRC_XDT)
    print("build XDF md5=%s size=%d" % (xdf_md5, xdf_sz))
    print("build XDT md5=%s size=%d" % (xdt_md5, xdt_sz))
    print("[1] backups (idempotent)")
    for p in (SA+"/LuaScripts.xdf", SA+"/LuaScripts.xdt", CA+"/LuaScripts.xdf",
              CA+"/LuaScripts.xdt", CA+"/LuaCacheVer.txt", MD5): backup(p)
    print("[2] deploy -> StreamingAssets + cache")
    for d in (SA, CA):
        if os.path.isdir(d):
            shutil.copy2(SRC_XDF, d+"/LuaScripts.xdf"); shutil.copy2(SRC_XDT, d+"/LuaScripts.xdt")
            print("   %s  xdf=%s" % (d, md5f(d+"/LuaScripts.xdf")))
    print("[3] refresh LuaCacheVer.txt")
    lcv = CA+"/LuaCacheVer.txt"
    if os.path.exists(lcv):
        old = open(lcv, encoding="utf-8").read().strip(); ver = old.split(",")[0]
        new = "%s,%d,%s" % (ver, xdt_sz, xdt_md5)
        open(lcv, "w", encoding="utf-8", newline="").write(new)
        print("   ", old, "->", new)
    print("[4] patch md5list.txt:", patch_md5list(xdf_md5, xdf_sz, xdt_md5, xdt_sz), "line(s)")
    print("=" * 55); print("DEPLOYED. Launch the game. Undo: python3 deploy.py --restore")

def restore():
    m = [(REF+"/LuaScripts.orig.xdf",  [SA+"/LuaScripts.xdf",  CA+"/LuaScripts.xdf"]),
         (REF+"/LuaScripts.orig.xdt",  [SA+"/LuaScripts.xdt",  CA+"/LuaScripts.xdt"]),
         (REF+"/LuaCacheVer.orig.txt", [CA+"/LuaCacheVer.txt"]),
         (REF+"/md5list.orig.txt",     [MD5])]
    print("[restore] from tool/reference/ pristine originals")
    for src, dsts in m:
        if not os.path.isfile(src): print("   MISSING ref:", src); continue
        for d in dsts:
            if os.path.isdir(os.path.dirname(d)):
                shutil.copy2(src, d); print("   restored:", d, md5f(d))
    print("RESTORED to original.")

def verify():
    for label, p in (("build XDF", SRC_XDF), ("build XDT", SRC_XDT)):
        if os.path.exists(p): print("%s md5=%s size=%d" % (label, md5f(p), os.path.getsize(p)))
    for p in (SA+"/LuaScripts.xdf", CA+"/LuaScripts.xdf"):
        if os.path.exists(p): print("on-disk", p, "->", md5f(p))
    if os.path.exists(CA+"/LuaCacheVer.txt"):
        print("LuaCacheVer:", open(CA+"/LuaCacheVer.txt", encoding="utf-8").read().strip())

if __name__ == "__main__":
    a = sys.argv[1] if len(sys.argv) > 1 else ""
    {"--restore": restore, "--verify": verify}.get(a, deploy)()
