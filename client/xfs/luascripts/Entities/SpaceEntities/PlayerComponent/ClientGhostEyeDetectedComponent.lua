-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientGhostEyeDetectedComponent.lua

local class = require("Core.Framework.Class")
local GhostEyeConst = require("Common.Const.GhostEyeConst")
local ClientGhostEyeDetectedComponent = class.Component("ClientGhostEyeDetectedComponent")

function ClientGhostEyeDetectedComponent:ctor()
	self.GhostEyeDetected = {
		entEffectEnable = false,
		entEffectType = GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.NONE
	}
end

function ClientGhostEyeDetectedComponent:setGhostEyeDetectedState(enable, effectType, delayTime)
	if delayTime > 0 then
		self.GhostEyeDetected.delayTimerId = self:addTimer(delayTime, function()
			self:_setGhostEyeDetectedState(enable, effectType)
		end)
	else
		self:_setGhostEyeDetectedState(enable, effectType)
	end
end

function ClientGhostEyeDetectedComponent:_setGhostEyeDetectedState(enable, effectType)
	if self.GhostEyeDetected.delayTimerId ~= nil then
		self:removeTimer(self.GhostEyeDetected.delayTimerId)

		self.GhostEyeDetected.delayTimerId = nil
	end

	if self.GhostEyeDetected.entEffectEnable then
		self:RefreshShow(false, self.GhostEyeDetected.entEffectType)
	end

	self.GhostEyeDetected.entEffectEnable = enable
	self.GhostEyeDetected.entEffectType = effectType

	if self.GhostEyeDetected.entEffectEnable then
		self:RefreshShow(true, self.GhostEyeDetected.entEffectType)
	end
end

function ClientGhostEyeDetectedComponent:EVENT_onModelLoaded()
	if self.GhostEyeDetected.entEffectEnable then
		self:RefreshShow(true, self.GhostEyeDetected.entEffectType)
	end
end

function ClientGhostEyeDetectedComponent:EVENT_OnModelRefreshed()
	if self.GhostEyeDetected.entEffectEnable then
		self:RefreshShow(true, self.GhostEyeDetected.entEffectType)
	end
end

function ClientGhostEyeDetectedComponent:RefreshShow(enable, effectType)
	if not self.eModel then
		return
	end

	if effectType == GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.CHEST then
		self.eModel.shaderView:EnableChestOutline(enable)
	elseif effectType == GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.CAMOUFLAGE then
		if self.setGhostEyeDetected then
			self:setGhostEyeDetected(enable)
		end
	elseif effectType == GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.CONGENER then
		self.eModel.shaderView:EnableCongenerOutline(enable)
	end
end

return ClientGhostEyeDetectedComponent
