# -*- coding: utf-8 -*-
# speedstam_patch.py - Infinite Stamina + Speedhack (chi player). --revert de go.
# Doi so 2.0 o duoi = he so toc do (vd 3.0 = x3).
import os, re, sys, shutil
HERE = os.path.dirname(os.path.abspath(__file__))
CLIENT = os.path.join(os.path.dirname(HERE), "client", "xfs", "luascripts")
PRISTINE = r"E:/MoBung/Sandbox/Export/lua_source_final/xfs/luascripts"
STAM = "Entities/SpaceEntities/CommonComponent/ClientStaminaComponent.lua"
ATTR = "Common/Ability/Attribute/ActorCombatAttribute.lua"
SPEED_MULT = b"2.0"   # <== doi so nay de chinh toc do

def rd(rel): return open(os.path.join(CLIENT, rel.replace("/", os.sep)), "rb").read()
def wr(rel, d): open(os.path.join(CLIENT, rel.replace("/", os.sep)), "wb").write(d)
def eol(d): return b"\r\n" if b"\r\n" in d else b"\n"

if "--revert" in sys.argv:
    for rel in (STAM, ATTR):
        src = os.path.join(PRISTINE, rel)
        if os.path.isfile(src): shutil.copy(src, os.path.join(CLIENT, rel.replace("/", os.sep))); print("reverted:", rel)
        else: print("no pristine:", rel)
    print("DONE (revert)"); sys.exit(0)

# 1) Infinite Stamina
d = rd(STAM); e = eol(d)
if b'[INFSTAM]' in d:
    print("stamina: already")
else:
    pat = re.compile(rb'(function ClientStaminaComponent:costStamina\(stateTag, staminaTag, cost\)\r?\n)')
    d, c = pat.subn(lambda m: m.group(1) + b'\tif true then return end --[[INFSTAM]]' + e, d, count=1)
    wr(STAM, d); print("stamina (infinite):", c, "edit")

# 2) Speedhack (getRawSpeed, player only)
d = rd(ATTR); e = eol(d)
if b'[SPEEDHACK]' in d:
    print("speed: already")
else:
    old = rb'\treturn self\.actorInterface:getConfigData\(\)\[AttributeConst\.ID2NAME\[attributeId\]\] or 0'
    new = (b'\tlocal v = self.actorInterface:getConfigData()[AttributeConst.ID2NAME[attributeId]] or 0' + e +
           b'\tif pg.me and self.entity == pg.me then v = v * ' + SPEED_MULT + b' end --[[SPEEDHACK]]' + e +
           b'\treturn v')
    d, c = re.subn(old, lambda m: new, d, count=1)
    wr(ATTR, d); print("speed (x%s, player only):" % SPEED_MULT.decode(), c, "edit")

print("markers -> INFSTAM:", b'[INFSTAM]' in rd(STAM), "SPEEDHACK:", b'[SPEEDHACK]' in rd(ATTR))
print("DONE.  -> build.py -> taskkill -> deploy.py")
