# -*- coding: utf-8 -*-
# cheat_all.py - bat God Mode + No CD + Unlimited Ult + SpecialDamage0 + Aim. --revert de go het.
import os, re, sys, shutil
HERE = os.path.dirname(os.path.abspath(__file__))
CLIENT = os.path.join(os.path.dirname(HERE), "client", "xfs", "luascripts")
PRISTINE = r"E:/MoBung/Sandbox/Export/lua_source_final/xfs/luascripts"

ABIL = "Common/Components/AbilityComponent.lua"
UTILS = "Common/Utils/Utils.lua"
TEMP = "GameApp/Input/Processor/TempInputProcessor.lua"
SPD = ["Entities/SpaceEntities/ClientRobSpaceEgg.lua",
       "Entities/SpaceEntities/CommonComponent/ClientCombatEntityComponent.lua",
       "Entities/SpaceEntities/CommonComponent/ClientDyingComponent.lua"]
ALL = [ABIL, UTILS, TEMP] + SPD

def eol(d): return b"\r\n" if b"\r\n" in d else b"\n"
def rd(rel): return open(os.path.join(CLIENT, rel.replace("/", os.sep)), "rb").read()
def wr(rel, d): open(os.path.join(CLIENT, rel.replace("/", os.sep)), "wb").write(d)

def revert():
    for rel in ALL:
        src = os.path.join(PRISTINE, rel)
        if os.path.isfile(src):
            shutil.copy(src, os.path.join(CLIENT, rel.replace("/", os.sep))); print("reverted:", rel)
        else: print("no pristine:", rel)

def patch():
    # 1+2 AbilityComponent: No CD + Unlimited cost
    d = rd(ABIL); e = eol(d); n = 0
    if b'[[NOCD]]' not in d:
        d, c = re.subn(rb'\treturn not ability:isInCd\(\)', b'\treturn true --[[NOCD]]', d, count=1); n += c
    if b'[[NOCOST]]' not in d:
        pat = re.compile(rb'(function AbilityComponent:checkAbilityCost\(abilityId\)\r?\n\tlocal ability = self:getAbility\(abilityId\)\r?\n\r?\n\tif ability == nil then\r?\n\t\treturn false, nil\r?\n\tend\r?\n)')
        d, c = pat.subn(lambda m: m.group(1) + e + b'\tif true then return true end --[[NOCOST]]' + e, d, count=1); n += c
    wr(ABIL, d); print("AbilityComponent (NoCD+Unlimited):", n, "edit(s)")
    # 3 Utils: Aim
    d = rd(UTILS); e = eol(d)
    d = rd(ABIL); e = eol(d); n = 0
    if b'[[NOCD]]' not in d:
        d, c = re.subn(rb'\treturn not ability:isInCd\(\)', b'\treturn true --[[NOCD]]', d, count=1); n += c
    if b'[[NOCOST]]' not in d:
        pat = re.compile(rb'(function AbilityComponent:checkAbilityCost\(abilityId\)\r?\n\tlocal ability = self:getAbility\(abilityId\)\r?\n\r?\n\tif ability == nil then\r?\n\t\treturn false, nil\r?\n\tend\r?\n)')
        d, c = pat.subn(lambda m: m.group(1) + e + b'\tif true then return true end --[[NOCOST]]' + e, d, count=1); n += c
    wr(ABIL, d); print("AbilityComponent (NoCD+Unlimited):", n, "edit(s)")
    # 3 Utils: Aim
    d = rd(UTILS); e = eol(d)
    if b'[[AIM]]' not in d:
        pat = re.compile(rb'(function Utils\.checkValidTarget\(target, owner\)\r?\n\tif not target then\r?\n\t\treturn false\r?\n\tend\r?\n)')
        d, c = pat.subn(lambda m: m.group(1) + e + b'\tif true then return true end --[[AIM]]' + e, d, count=1)
        wr(UTILS, d); print("Utils (Aim):", c, "edit(s)")
    else: print("Utils (Aim): already")
    # 4 SpecialDamage=0
    for rel in SPD:
        d = rd(rel)
        if b'[[SPDMG0]]' in d: print("SpecialDamage already:", rel); continue
        d, c = re.subn(rb'("RPC_CS_SpecialDamage",\s*)[^,]+', lambda m: m.group(1) + b'0 --[[SPDMG0]]', d)
        wr(rel, d); print("SpecialDamage %d site(s): %s" % (c, rel))
    # 5 God Mode loop
    d = rd(TEMP); e = eol(d)
    if b'[GODMODE]' not in d:
        lines = [b'',
         b'\tif not TempInputProcessor._godInstalled then -- [GODMODE] auto-renew invincibility',
         b'\t\tTempInputProcessor._godInstalled = true',
         b'\t\tlocal TM = require("Core.Timer.TimerManager")',
         b'\t\tTM.addRepeatTimer(2, function()',
         b'\t\t\tpcall(function()',
         b'\t\t\t\tif pg.me and pg.me.actorId then',
         b'\t\t\t\t\tpg.me:serverMsg("RPC_CS_DialoguePauseRenewInvincible", { pg.me.actorId }, 1)',
         b'\t\t\t\tend',
         b'\t\t\tend)',
         b'\t\tend)',
         b'\tend']
        ins = e.join(lines) + e
        pat = re.compile(rb'(\tself\.actionMapKey = HotkeyConst\.INPUT_MAP_ACTION_KEY\.Temp\r?\n)(end)')
        d, c = pat.subn(lambda m: m.group(1) + ins + m.group(2), d, count=1)
        wr(TEMP, d); print("God Mode loop:", c, "edit(s)")
    else: print("God Mode: already")

if __name__ == "__main__":
    if "--revert" in sys.argv:
        print("[cheat_all] REVERT"); revert()
    else:
        print("[cheat_all] ENABLE all cheats"); patch()
    print("markers:", {m: any(m.encode() in rd(f) for f in ALL) for m in ["[[NOCD]]","[[NOCOST]]","[[AIM]]","[[SPDMG0]]","[GODMODE]"]})
    print("DONE.  -> build.py -> taskkill -> deploy.py")
