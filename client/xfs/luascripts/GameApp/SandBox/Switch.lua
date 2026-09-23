-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Switch.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Switch = Class.LightClass("Switch", LevelItem)

function Switch:ctor(sandbox, spawnInfo, syncInfo)
	Switch.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Switch:setSwitch(isOn)
	self:serverMsg("RPC_CS_SetSwitch", isOn)
end

function Switch:destroy()
	Switch.super.destroy(self)
end

return Switch
