-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Trampoline.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local Trampoline = Class.LightClass("Trampoline", LevelItem)

function Trampoline:ctor(sandbox, spawnInfo, syncInfo)
	Trampoline.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Trampoline:press()
	self:serverMsg("RPC_CS_Press")
end

function Trampoline:setPressCallback(cb)
	self.pressCallback = cb
end

function Trampoline:RPC_SC_Press(args)
	if self.pressCallback then
		self.pressCallback()
	end
end

function Trampoline:destroy()
	Trampoline.super.destroy(self)
end

return Trampoline
