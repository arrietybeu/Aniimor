# -*- coding: utf-8 -*-
# build_surgical.py - chi recompile file DA PATCH, giu bytecode GOC cho phan con lai (fix cursor).
import os, sys, re, time, json, io, struct, zipfile, hashlib, subprocess, collections, shutil
HERE=os.path.dirname(os.path.abspath(__file__)); ROOT=os.path.dirname(HERE)
CLIENT=os.path.join(ROOT,"client"); BUILD=os.path.join(ROOT,"build"); BCOUT=os.path.join(BUILD,"bc")
RECOMP=os.path.join(HERE,"recompiler.exe"); XLUA=os.path.join(HERE,"xlua.dll")
REF_XDF=os.path.join(HERE,"reference","LuaScripts.orig.xdf"); REF_XDT=os.path.join(HERE,"reference","LuaScripts.orig.xdt")
OUT_XDF=os.path.join(BUILD,"LuaScripts.xdf"); OUT_XDT=os.path.join(BUILD,"LuaScripts.xdt")
MANIFEST=os.path.join(BUILD,"_recompile_manifest.txt"); PRISTINE=r"E:/MoBung/Sandbox/Export/lua_source_final"
def arc(src): return os.path.relpath(src,CLIENT).replace("\\","/")
def recompile():
    if os.path.isdir(BCOUT): shutil.rmtree(BCOUT,ignore_errors=True)
    os.makedirs(BCOUT,exist_ok=True)
    allf=sorted(os.path.join(dp,f) for dp,_,fn in os.walk(CLIENT) for f in fn if f.endswith(".lua"))
    patched=[]
    for src in allf:
        pri=os.path.join(PRISTINE,arc(src).replace("/",os.sep))
        try: same=os.path.isfile(pri) and open(src,"rb").read()==open(pri,"rb").read()
        except Exception: same=False
        if not same: patched.append(src)
    print("  source .lua:",len(allf),"| PATCHED:",len(patched))
    for s in patched: print("     +",arc(s))
    if not patched: print("  no patched file"); return 0
    with open(MANIFEST,"w",encoding="utf-8") as m:
        for src in patched:
            rel=arc(src); out=os.path.join(BCOUT,rel.replace("/",os.sep)); os.makedirs(os.path.dirname(out),exist_ok=True)
            chunk="@"+rel
            try:
                mm=re.search(r"chunkname:\s*(@[^\r\n]+)",open(src,encoding="utf-8",errors="replace").readline())
                if mm: chunk=mm.group(1).replace("\\\\","\\")
            except Exception: pass
            m.write("%s\t%s\t%s\n"%(src,out,chunk))
    t0=time.time(); r=subprocess.run([RECOMP,XLUA,"-batch",MANIFEST],capture_output=True,text=True)
    errs=[l for l in (r.stderr or "").splitlines() if l.startswith("COMPILE_ERROR")]
    print("  ",(r.stderr or "").splitlines()[-1] if r.stderr else "","| failures:",len(errs))
    for l in errs[:10]: print("     ",l[:160])
    print("  recompiled in %.1fs"%(time.time()-t0)); return len(patched)
def build_xdf():
    j=json.loads(open(REF_XDT,"rb").read().decode("utf-8")); order=[e["CEName"] for e in j["CMList"]]
    cont={e["CEName"]:e.get("CEContainer",0) for e in j["CMList"]}; header={k:j[k] for k in j if k!="CMList"}
    zin=zipfile.ZipFile(REF_XDF,"r"); oct={i.filename:i.compress_type for i in zin.infolist()}
    rc=og=nl=0; os.makedirs(BUILD,exist_ok=True)
    with zipfile.ZipFile(OUT_XDF,"w",allowZip64=False) as z:
        for name in order:
            bc=os.path.join(BCOUT,name.replace("/",os.sep))
            if name.lower().endswith(".lua") and os.path.isfile(bc): data,ct=open(bc,"rb").read(),zipfile.ZIP_STORED; rc+=1
            else:
                data,ct=zin.read(name),oct.get(name,zipfile.ZIP_DEFLATED)
                if name.lower().endswith(".lua"): og+=1
                else: nl+=1
            zi=zipfile.ZipInfo(filename=name); zi.compress_type=ct; zi.date_time=(1980,1,1,0,0,0); zi.external_attr=0
            z.writestr(zi,data)
    zin.close(); print("  recompiled_lua=%d original_lua=%d non_lua=%d total=%d"%(rc,og,nl,rc+og+nl)); return header,cont
def _off(fp,ho):
    fp.seek(ho); lh=fp.read(30); assert lh[:4]==b"PK\x03\x04"
    return ho+30+struct.unpack("<H",lh[26:28])[0]+struct.unpack("<H",lh[28:30])[0]
def regen(header,cont):
    whole=open(OUT_XDF,"rb").read(); fp=io.BytesIO(whole); z=zipfile.ZipFile(OUT_XDF,"r"); cm=[]
    for idx,zi in enumerate(z.infolist()):
        off=_off(fp,zi.header_offset); c=z.read(zi.filename)
        cm.append(collections.OrderedDict([("CEName",zi.filename),("CEMD5",hashlib.md5(c).hexdigest()),
            ("CESize",zi.file_size),("CEIndex",idx),("CEOffset",off),("CECSize",zi.compress_size),("CEContainer",cont.get(zi.filename,0))]))
    z.close(); out=collections.OrderedDict()
    for k in ("CMSign","CMVersion","CMToolVer","CMCompress"): out[k]=header.get(k,0)
    out["CMDataLen"]=len(whole); out["CMDataMD5"]=hashlib.md5(whole).hexdigest(); out["CMEntryNum"]=len(cm); out["CMList"]=cm
    open(OUT_XDT,"w",encoding="utf-8",newline="\n").write(json.dumps(out,indent=4,ensure_ascii=False)); return out
def verify(out):
    whole=open(OUT_XDF,"rb").read(); fp=io.BytesIO(whole); z=zipfile.ZipFile(OUT_XDF,"r"); bad=0
    for e in out["CMList"]:
        c=z.read(e["CEName"])
        if hashlib.md5(c).hexdigest()!=e["CEMD5"] or len(c)!=e["CESize"] or _off(fp,z.getinfo(e["CEName"]).header_offset)!=e["CEOffset"]: bad+=1
    z.close(); print("  verify mismatch=%d xdf=%d"%(bad,len(whole))); return bad==0
if __name__=="__main__":
    for p in (RECOMP,XLUA,REF_XDF,REF_XDT):
        if not os.path.isfile(p): print("MISSING",p); sys.exit(2)
    if not os.path.isdir(PRISTINE): print("MISSING pristine",PRISTINE); sys.exit(2)
    print("[1] surgical recompile"); recompile()
    print("[2] repack (patched + original passthrough)"); h,c=build_xdf()
    print("[3] xdt"); out=regen(h,c); print("[4] verify"); ok=verify(out)
    print("XDF CMDataMD5:",out["CMDataMD5"]); print("RESULT:","OK -> deploy.py" if ok else "FAILED"); sys.exit(0 if ok else 1)