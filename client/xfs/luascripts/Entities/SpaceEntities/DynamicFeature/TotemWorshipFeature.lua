-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\TotemWorshipFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local SysConfigData = require("Data.sys_config_data")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local TotemWorshipFeature = Class.LiteClass("TotemWorshipFeature", iFeature)

function TotemWorshipFeature:ctor()
	TotemWorshipFeature.super.ctor(self)
end

function TotemWorshipFeature:init(master, data)
	TotemWorshipFeature.super.init(self, master, data)

	local configData = self.master:getConfigData() or {}
	local featureConfigData = configData.featureConfigData or {}

	self.totemId = featureConfigData.totemId

	function self.onTotemMapChanged(totemId)
		if totemId == self.totemId then
			self:refreshTotemEffect()
		end
	end

	pg.me.eventEmitter:addEventListener(EventConst.ON_TOTEM_MAP_CHANGED, self.onTotemMapChanged)
end

function TotemWorshipFeature:onEnterSpace()
	self:refreshTotemEffect()
end

function TotemWorshipFeature:destroy()
	if pg.me then
		pg.me.eventEmitter:removeEventListener(EventConst.ON_TOTEM_MAP_CHANGED, self.onTotemMapChanged)
	end

	if self.totemEffect then
		self.master:stopEffect("Eff_LVIOT_Build_FlowerVillage_TotemPoles_001_loop")

		self.totemEffect = nil
	end

	TotemWorshipFeature.super.destroy(self)
end

function TotemWorshipFeature:refreshTotemEffect()
	if self.isInCutscene then
		return
	end

	if self.totemId then
		local totemInfo = pg.me.totemMap[self.totemId]

		if totemInfo and totemInfo.isMaxLevel then
			if not self.totemEffect then
				self.totemEffect = self.master:playEffect("Eff_LVIOT_Build_FlowerVillage_TotemPoles_001_loop")
			end
		elseif self.totemEffect then
			self.master:stopEffect("Eff_LVIOT_Build_FlowerVillage_TotemPoles_001_loop")

			self.totemEffect = nil
		end
	end
end

return TotemWorshipFeature
