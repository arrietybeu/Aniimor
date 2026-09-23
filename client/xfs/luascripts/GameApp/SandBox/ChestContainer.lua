-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\ChestContainer.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ChestContainer = Class.LightClass("ChestContainer", LevelItem)

function ChestContainer:ctor(sandbox, spawnInfo, syncInfo)
	ChestContainer.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function ChestContainer:destroy()
	ChestContainer.super.destroy(self)
end

return ChestContainer
