-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\BeePollenFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local BeePollenFeature = Class.LiteClass("BeePollenFeature", iFeature)

function BeePollenFeature:ctor()
	BeePollenFeature.super.ctor(self)

	self.warningTimer = nil
	self.warningEffectKey = nil
end

function BeePollenFeature:init(master, data)
	BeePollenFeature.super.init(self, master, data)

	local configData = self.master:getConfigData()
	local featureConfig = configData.featureConfigData or {}

	self.warningEffectKey = featureConfig.pollenWarningEffect or featureConfig.warningEffect or configData.warningEffect
	self.warningDuration = featureConfig.pollenWarningDuration or featureConfig.warningDuration or 0
	self.lifeTime = self.master.envData and self.master.envData.maxLifeTime or configData.maxLifeTime or 0

	self:_refreshWarningTimer()
end

function BeePollenFeature:destroy()
	self:_clearWarningTimer()
	self:_stopWarningEffect()
	BeePollenFeature.super.destroy(self)
end

function BeePollenFeature:EVENT_OnLifterIdChanged()
	self:_refreshWarningTimer()
end

function BeePollenFeature:_refreshWarningTimer()
	self:_clearWarningTimer()
	self:_stopWarningEffect()

	if not string.isNilOrEmpty(self.master.lifterId) then
		return
	end

	if not self.warningEffectKey or self.warningEffectKey == "" then
		return
	end

	if not self.lifeTime or self.lifeTime <= 0 then
		return
	end

	local warningDuration = self.warningDuration

	if not warningDuration or warningDuration <= 0 then
		warningDuration = math.min(3, self.lifeTime)
	end

	local delay = math.max(0, self.lifeTime - warningDuration)

	self.warningTimer = self.master:addTimer(delay, function()
		self.warningTimer = nil

		self:_playWarningEffect()
	end)
end

function BeePollenFeature:_clearWarningTimer()
	if self.warningTimer then
		self.master:removeTimer(self.warningTimer)

		self.warningTimer = nil
	end
end

function BeePollenFeature:_playWarningEffect()
	if self.warningEffectKey and self.warningEffectKey ~= "" then
		self.master:playEffect(self.warningEffectKey)
	end
end

function BeePollenFeature:_stopWarningEffect()
	if self.warningEffectKey and self.warningEffectKey ~= "" then
		self.master:stopEffect(self.warningEffectKey)
	end
end

return BeePollenFeature
