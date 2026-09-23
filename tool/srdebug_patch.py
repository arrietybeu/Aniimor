# -*- coding: utf-8 -*-
# srdebug_patch.py - tu dong mo SRDebugger + DebugConsole ~8s sau khi vao world. --revert de go.
import os, re, sys
p = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                 "client","xfs","luascripts","GameApp","Input","Processor","TempInputProcessor.lua")
d = open(p,"rb").read()
if "--revert" in sys.argv:
    d2, n = re.subn(rb'\r?\n\r?\n\t\t\tTempInputProcessor\._gmTick.*?\r?\n\t\t\tend(?=\r?\n\t\t\tpcall)', b'', d, count=1, flags=re.S)
    open(p,"wb").write(d2); print("reverted:", n); sys.exit(0)
if b'[GM-DEMO2]' in d:
    print("already patched"); sys.exit(0)
e = b'\r\n' if b'\r\n' in d else b'\n'
lines = [b'',
 b'\t\t\tTempInputProcessor._gmTick = (TempInputProcessor._gmTick or 0) + 1 -- [GM-DEMO2] auto-open client debug UI',
 b'\t\t\tif TempInputProcessor._gmTick == 80 then',
 b'\t\t\t\tlocal ok, err = pcall(function()',
 b'\t\t\t\t\tlocal G = require("Utils.GmToolUtils")',
 b'\t\t\t\t\tif G.openSrDebugger then G.openSrDebugger() end',
 b'\t\t\t\t\tif G.openDebugConsole then G.openDebugConsole() end',
 b'\t\t\t\tend)',
 b'\t\t\t\tprint("[GM-DEMO2] srdebug ok=" .. tostring(ok) .. " err=" .. tostring(err))',
 b'\t\t\tend']
inj = e.join(lines) + e
d2, n = re.subn(rb'(TimerManager\.addRepeatTimer\(0\.1, function\(\)\r?\n)', lambda m: m.group(1)+inj, d, count=1)
open(p,"wb").write(d2)
print("injected:", n, "| marker:", b'[GM-DEMO2]' in d2)
