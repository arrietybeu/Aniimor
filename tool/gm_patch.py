import os, re, sys
HERE   = os.path.dirname(os.path.abspath(__file__))
CLIENT = os.path.join(os.path.dirname(HERE), "client", "xfs", "luascripts")
UTILS  = os.path.join(CLIENT, "Common", "Utils", "Utils.lua")
TEMP   = os.path.join(CLIENT, "GameApp", "Input", "Processor", "TempInputProcessor.lua")

def eol_of(data): return b"\r\n" if b"\r\n" in data else b"\n"

def patch_utils(data, revert):
    if revert:
        return re.subn(rb'\treturn true -- \[GM-DEMO\][^\r\n]*\r?\n\r?\n', b'', data, count=1)
    if b'[GM-DEMO]' in data: return data, 0
    e = eol_of(data)
    pat = re.compile(rb'(function Utils\.enableClientUseGm\(player\)\r?\n\tif not player then\r?\n'
                     rb'\t\treturn false\r?\n\tend\r?\n\r?\n)(\tif not _G_IsDebugMode then)')
    ins = b'\treturn true -- [GM-DEMO] force-enable client GM/debug UI (review check #8)' + e + e
    return pat.subn(lambda m: m.group(1) + ins + m.group(2), data, count=1)

def patch_temp(data, revert):
    if revert:
        return re.subn(rb'\r?\n\tif not TempInputProcessor\._gmHotkeyInstalled then -- \[GM-DEMO\].*?\r?\n\tend(?=\r?\nend)',
                       b'', data, count=1, flags=re.S)
    if b'[GM-DEMO]' in data: return data, 0
    e = eol_of(data)
    pat = re.compile(rb'(function TempInputProcessor:onInit\(\)\r?\n\tBaseInputProcessor\.onInit\(self\)\r?\n\r?\n'
                     rb'\tself\.actionMapKey = HotkeyConst\.INPUT_MAP_ACTION_KEY\.Temp\r?\n)(end)')
    lines = [b'\tif not TempInputProcessor._gmHotkeyInstalled then -- [GM-DEMO] F9 toggles GM/debug panel',
             b'\t\tTempInputProcessor._gmHotkeyInstalled = true',
             b'\t\tlocal TimerManager = require("Core.Timer.TimerManager")',
             b'\t\tTimerManager.addRepeatTimer(0.1, function()',
             b'\t\t\tpcall(function()',
             b'\t\t\t\tif CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F9) then',
             b'\t\t\t\t\tlocal ui = pg.global.ui',
             b'\t\t\t\t\tif ui:checkUIOpen(UIConst.UI_ID_CONFIG) then',
             b'\t\t\t\t\t\tui:close(UIConst.UI_ID_CONFIG)',
             b'\t\t\t\t\telse',
             b'\t\t\t\t\t\tui:open(UIConst.UI_ID_CONFIG)',
             b'\t\t\t\t\tend',
             b'\t\t\t\tend',
             b'\t\t\tend)',
             b'\t\tend)',
             b'\tend']
    ins = e + e.join(lines) + e
    return pat.subn(lambda m: m.group(1) + ins + m.group(2), data, count=1)

def run(path, fn, revert, name):
    if not os.path.isfile(path): print("  MISSING:", path); return False
    data = open(path, "rb").read()
    new, n = fn(data, revert)
    if n: open(path, "wb").write(new); print("  %-24s %s" % (name, "REVERTED" if revert else "PATCHED"))
    else: print("  %-24s no change (already %s / anchor?)" % (name, "reverted" if revert else "patched"))
    return True

if __name__ == "__main__":
    rev = "--revert" in sys.argv
    print("[gm_patch]", "REVERT" if rev else "ENABLE", "GM/debug UI")
    ok = run(UTILS, patch_utils, rev, "Utils.lua") and run(TEMP, patch_temp, rev, "TempInputProcessor.lua")
    # verify markers
    u = b'[GM-DEMO]' in open(UTILS,"rb").read(); t = b'[GM-DEMO]' in open(TEMP,"rb").read()
    print("markers -> Utils:%s Temp:%s" % (u, t))
    print("DONE." if (u and t) != rev else "CHECK ABOVE.")