-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SpurtItem.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SceneUtils = require("Common.Utils.SceneUtils")
local inspect = require("Core.Common.inspect")
local SpurtItem = Class.LightClass("SpurtItem", LevelItem)

function SpurtItem:ctor(sandbox, spawnInfo, syncInfo)
	SpurtItem.super.ctor(self, sandbox, spawnInfo, syncInfo)

	if spawnInfo.defaultValue.spurtInterval == 1 then
		pg.spr = self
	end
end

function SpurtItem:onSandboxReady()
	SpurtItem.super.onSandboxReady(self)
end

function SpurtItem:destroy()
	SpurtItem.super.destroy(self)
end

return SpurtItem
