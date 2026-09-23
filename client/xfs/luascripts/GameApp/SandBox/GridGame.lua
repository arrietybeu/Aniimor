-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\GridGame.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local GridGameState = SandboxConst.GridGameState
local GridGame = Class.LightClass("GridGame", LevelItem)

function GridGame:ctor(sandbox, spawnInfo, syncInfo)
	GridGame.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function GridGame:onInit()
	GridGame.super.onInit(self)
end

function GridGame:onSandboxReady()
	GridGame.super.onSandboxReady(self)
	self:_setGridCellsActive(false, true)
end

function GridGame:destroy()
	GridGame.super.destroy(self)
end

function GridGame:onLevelItemValueChange(key, oldValue, value)
	if key ~= "state" then
		return
	end

	local active = value == GridGameState.PLAYING or value == GridGameState.SUCCESS

	self:_setGridCellsActive(active, false)
end

function GridGame:_setGridCellsActive(active, isInit)
	local ids = self:getMajorConfig().gridCellIds or {}

	for _, cellId in ipairs(ids) do
		local cell = self.sandbox.levelItems[cellId]

		if cell then
			cell.shareMem:set("isActive", active, isInit)

			if not isInit then
				cell.shareMem:triggerChangeSingle("isActive")
			end
		end
	end
end

return GridGame
