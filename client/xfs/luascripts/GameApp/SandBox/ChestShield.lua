-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\ChestShield.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ChestShield = Class.LightClass("ChestShield", LevelItem)

function ChestShield:ctor(sandbox, spawnInfo, syncInfo)
	ChestShield.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function ChestShield:destroy()
	ChestShield.super.destroy(self)
end

return ChestShield
