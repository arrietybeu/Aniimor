-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\CondenseWaterBoundItem.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local CondenseWaterBoundItem = Class.LightClass("CondenseWaterBoundItem", LevelItem)

function CondenseWaterBoundItem:ctor(sandbox, spawnInfo, syncInfo)
	CondenseWaterBoundItem.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function CondenseWaterBoundItem:destroy()
	CondenseWaterBoundItem.super.destroy(self)
end

return CondenseWaterBoundItem
