-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\PetHatchGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetHatchGuideHandler = Class.LightClass("PetHatchGuideHandler", GuideHandlerBase)

function PetHatchGuideHandler:getOwnedRefKeys()
	return {
		"hatchUpUWidget",
		"incubateUContainer"
	}
end

function PetHatchGuideHandler:getOwnedContainers()
	return {
		"incubateUContainer"
	}
end

function PetHatchGuideHandler:onFindObjects(objectReference)
	self.hatchUpUWidget = objectReference:GetRefValue("hatchUpUWidget")
	self.hatchUpTitleTxt = objectReference:GetRefValue("hatchUpTitleTxt")
	self.hatchUpTimeTxt = objectReference:GetRefValue("hatchUpTimeTxt")
	self.incubateUContainer = objectReference:GetRefValue("incubateUContainer")
end

function PetHatchGuideHandler:onRefresh()
	self.hatchUpUWidget:SetActive(true)
	self.incubateUContainer:SetActive(true)
	self:_refreshHatchAcceleration()

	if not self.incubateUContainer:CheckURLLoaded() then
		self.incubateUContainer:LoadDefaultUrlManually(function(content)
			self.incubateUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end)
	elseif self.incubateUContainer.content then
		self.incubateUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function PetHatchGuideHandler:onExit()
	self.hatchUpUWidget:SetActive(false)
	self.incubateUContainer:SetActive(false)
end

function PetHatchGuideHandler:_refreshHatchAcceleration()
	ClientTextUtils.setText(self.hatchUpTitleTxt, pg.getGameString("PET_HATCH_ACTIVITY_2"))

	local hatchData = pg.me.activityPetHatch
	local savedTimeSec = hatchData and hatchData.totalAccelHatchTime or 0

	ClientTextUtils.setText(self.hatchUpTimeTxt, self:_formatHatchSavedTime(savedTimeSec))
end

function PetHatchGuideHandler:_formatHatchSavedTime(seconds)
	seconds = math.max(0, seconds)

	local totalMinutes = math.floor(seconds / 60)

	if seconds > 0 and totalMinutes < 1 then
		totalMinutes = 1
	end

	local days = math.floor(totalMinutes / 1440)
	local hours = math.floor(totalMinutes / 60) % 24
	local minutes = totalMinutes % 60
	local dayL10n = pg.getGameString("DAY")
	local hourL10n = pg.getGameString("HOUR")
	local minuteL10n = pg.getGameString("MINUTE")

	if days > 0 then
		return ClientTextUtils.concatCountDownUnitsByLanguage(days, dayL10n, hours, hourL10n, minutes, minuteL10n)
	end

	if hours > 0 then
		return ClientTextUtils.concatCountDownUnitsByLanguage(hours, hourL10n, minutes, minuteL10n)
	end

	return ClientTextUtils.concatCountDownUnitsByLanguage(minutes, minuteL10n)
end

return PetHatchGuideHandler
