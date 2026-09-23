# -*- coding: utf-8 -*-
# skillspam_patch.py - No Cooldown + Unlimited (spam skill + ultimate). --revert de go.
import os, re, sys, shutil
HERE=os.path.dirname(os.path.abspath(__file__)); CLIENT=os.path.join(os.path.dirname(HERE),"client","xfs","luascripts")
PRISTINE=r"E:/MoBung/Sandbox/Export/lua_source_final/xfs/luascripts"
ABIL="Common/Components/AbilityComponent.lua"
p=os.path.join(CLIENT,ABIL.replace("/",os.sep))
if "--revert" in sys.argv:
    src=os.path.join(PRISTINE,ABIL)
    if os.path.isfile(src): shutil.copy(src,p); print("reverted:",ABIL)
    else: print("no pristine:",ABIL)
    sys.exit(0)
d=open(p,"rb").read(); e=b"\r\n" if b"\r\n" in d else b"\n"; n=0
if b'[[NOCD]]' not in d:
    d,c=re.subn(rb'\treturn not ability:isInCd\(\)', b'\treturn true --[[NOCD]]', d, count=1); n+=c
if b'[[NOCOST]]' not in d:
    pat=re.compile(rb'(function AbilityComponent:checkAbilityCost\(abilityId\)\r?\n\tlocal ability = self:getAbility\(abilityId\)\r?\n\r?\n\tif ability == nil then\r?\n\t\treturn false, nil\r?\n\tend\r?\n)')
    d,c=pat.subn(lambda m: m.group(1)+e+b'\tif true then return true end --[[NOCOST]]'+e, d, count=1); n+=c
open(p,"wb").write(d)
print("AbilityComponent edits:",n,"| NOCD:",b'[[NOCD]]' in d,"NOCOST:",b'[[NOCOST]]' in d)
print("DONE. -> build_surgical.py -> taskkill -> deploy.py")
