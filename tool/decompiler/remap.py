import os,sys
# game_opcode_byte -> standard opcode  (identity unless listed)
REMAP={4:6,5:7,6:8,7:9,8:4,9:5,
 45:47,46:48,47:49,48:45,49:46,50:51,51:50,
 52:53,53:52,54:57,55:58,56:59,57:54,58:55,59:56,60:63,61:64,62:60,63:61,64:62}
MAP=[REMAP.get(i,i) for i in range(256)]

def uleb(d,p):
    v=0;s=0
    while True:
        b=d[p];p+=1;v|=(b&0x7f)<<s
        if b<0x80:break
        s+=7
    return v,p

def remap_file(src,dst):
    d=bytearray(open(src,'rb').read())
    if d[:3]!=b'\x1bLJ': return False
    p=4
    flags,p=uleb(d,p); STRIP=flags&2
    if not STRIP:
        n,p=uleb(d,p); p+=n
    while True:
        plen,p=uleb(d,p)
        if plen==0: break
        st=p
        p+=4
        nk,p=uleb(d,p); nn,p=uleb(d,p); nb,p=uleb(d,p)
        if not STRIP:
            sd,p=uleb(d,p)
            if sd:
                _,p=uleb(d,p); _,p=uleb(d,p)
        # instructions: nb * 4 bytes, remap opcode byte (first byte of each)
        for k in range(nb):
            off=p+4*k
            d[off]=MAP[d[off]]
        p=st+plen
    open(dst,'wb').write(bytes(d))
    return True

if __name__=="__main__":
    src=sys.argv[1]; dst=sys.argv[2]
    if os.path.isfile(src):
        remap_file(src,dst)
    else:
        cnt=0
        for dp,dn,fn in os.walk(src):
            for f in fn:
                if not f.endswith('.lua'): continue
                s=os.path.join(dp,f)
                rel=os.path.relpath(s,src)
                o=os.path.join(dst,rel)
                os.makedirs(os.path.dirname(o),exist_ok=True)
                try:
                    if remap_file(s,o): cnt+=1
                except Exception as e:
                    pass
        print("remapped",cnt,"files")
