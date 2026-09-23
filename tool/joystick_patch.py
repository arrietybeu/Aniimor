import os, re, sys
p = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                 "client","xfs","luascripts","GameApp","Input","Processor","TempInputProcessor.lua")
d = open(p,"rb").read()
if "--revert" in sys.argv:
    d2,n = re.subn(rb'\r?\n\r?\n\tif not TempInputProcessor\._joyInstalled then.*?\r?\n\tend(?=\r?\nend)', b'', d, count=1, flags=re.S)
    open(p,"wb").write(d2); print("reverted:", n); sys.exit(0)
if b'[JOYSTICK]' in d:
    print("already patched"); sys.exit(0)
e = b'\r\n' if b'\r\n' in d else b'\n'
lines = [b'',
 b'\tif not TempInputProcessor._joyInstalled then -- [JOYSTICK] show virtual joystick on PC',
 b'\t\tTempInputProcessor._joyInstalled = true',
 b'\t\tlocal TM = require("Core.Timer.TimerManager")',
 b'\t\tTM.addRepeatTimer(0.1, function()',
 b'\t\t\tTempInputProcessor._joyTick = (TempInputProcessor._joyTick or 0) + 1',
 b'\t\t\tif TempInputProcessor._joyTick == 50 then',
 b'\t\t\t\tlocal ok, err = pcall(function()',
 b'\t\t\t\t\tif pg.global.ui.mobileOperate then',
 b'\t\t\t\t\t\tpg.global.ui.mobileOperate:open()',
 b'\t\t\t\t\telse',
 b'\t\t\t\t\t\tpg.global.ui:open(UIConst.UI_ID_HUD_MOBILE_OPERATE)',
 b'\t\t\t\t\tend',
 b'\t\t\t\tend)',
 b'\t\t\t\tprint("[JOYSTICK] open ok=" .. tostring(ok) .. " err=" .. tostring(err))',
 b'\t\t\tend',
 b'\t\tend)',
 b'\tend']
inj = e.join(lines) + e
d2, n = re.subn(rb'(\tself\.actionMapKey = HotkeyConst\.INPUT_MAP_ACTION_KEY\.Temp\r?\n)(end)', lambda m: m.group(1)+inj+m.group(2), d, count=1)
open(p,"wb").write(d2)
print("injected:", n, "| marker:", b'[JOYSTICK]' in d2)