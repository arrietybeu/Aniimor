-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\BeeFlower.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local BeeFlower = Class.LightClass("BeeFlower", LevelItem)

function BeeFlower:ctor(sandbox, spawnInfo, syncInfo)
	BeeFlower.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function BeeFlower:onInit()
	self.majorCompId = self.spawnInfo.majorCompId
end

function BeeFlower:onSandboxReady()
	BeeFlower.super.onSandboxReady(self)

	if self.shell and self.majorCompId then
		self.beeFlowerSB = self.shell:GetComponentById(self.majorCompId)
	end

	self:_applyHarvestCount(self.syncInfo.harvestCount or 0)
end

function BeeFlower:onValueChange(key, oldValue, value, isInit)
	BeeFlower.super.onValueChange(self, key, oldValue, value, isInit)

	if key == "harvestCount" then
		self:_applyHarvestCount(value)
	end
end

function BeeFlower:_applyHarvestCount(harvestCount)
	if self.beeFlowerSB then
		self.beeFlowerSB:SetHarvestCount(harvestCount or 0)
	end
end

function BeeFlower:destroy()
	self.beeFlowerSB = nil

	BeeFlower.super.destroy(self)
end

return BeeFlower
