-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\LevelFruitFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local SysConfigData = require("Data.sys_config_data")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local LevelFruitFeature = Class.LiteClass("LevelFruitFeature", iFeature)

function LevelFruitFeature:ctor()
	LevelFruitFeature.super.ctor(self)
end

function LevelFruitFeature:init(master, data)
	LevelFruitFeature.super.init(self, master, data)

	local envData = self.master.envData or {}

	self.plantTreeId = envData.plantTreeId
	self.slotIdx = envData.slotIdx
	self.sandboxId = self.master.sandboxId
end

function LevelFruitFeature:destroy()
	LevelFruitFeature.super.destroy(self)
end

function LevelFruitFeature:on_isInTree_Changed(oldv, newv)
	if not self.isInTree then
		self:setFruitScale(1)
	end
end

function LevelFruitFeature:setFruitScale(scale)
	scale = scale or 1

	self.master:setScaleNumber(scale)
end

function LevelFruitFeature:canBeLift()
	if self.isInTree and self.slotIdx and self.sandboxId and self.plantTreeId then
		local plantTree = self.master.space:getSandboxLevelItem(self.sandboxId, self.plantTreeId)

		if plantTree and plantTree:isInGrowAnim() then
			return false
		end
	end

	return true
end

return LevelFruitFeature
