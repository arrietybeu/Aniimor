-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SludgeField.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SludgeField = Class.LightClass("SludgeField", LevelItem)

function SludgeField:ctor(sandbox, spawnInfo, syncInfo)
	SludgeField.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

return SludgeField
