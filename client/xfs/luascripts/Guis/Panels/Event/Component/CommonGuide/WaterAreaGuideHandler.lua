-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\WaterAreaGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local EventCommonGuideData = require("Data.event_common_guide_data")
local WaterAreaGuideHandler = Class.LightClass("WaterAreaGuideHandler", GuideHandlerBase)

function WaterAreaGuideHandler:getOwnedRefKeys()
	return {
		"waterSectorPreheatingUContainer"
	}
end

function WaterAreaGuideHandler:getOwnedContainers()
	return {
		"waterSectorPreheatingUContainer"
	}
end

function WaterAreaGuideHandler:onFindObjects(objectReference)
	self.waterSectorPreheatingUContainer = objectReference:GetRefValue("waterSectorPreheatingUContainer")
end

function WaterAreaGuideHandler:onRefresh()
	if self.waterSectorPreheatingUContainer:CheckURLLoaded() then
		self:_refreshWaterAreaPreview()
	else
		self.waterSectorPreheatingUContainer:LoadDefaultUrlManually(function()
			self:_refreshWaterAreaPreview()
		end)
	end
end

function WaterAreaGuideHandler:onExit()
	self.waterSectorPreheatingUContainer:SetActive(false)
end

function WaterAreaGuideHandler:onButton1()
	if self.comp.preheated then
		local LoggerManager = require("Core.Log.LoggerManager")
		local logger = LoggerManager.getLogger("EventCommonGuideComponent")

		if pg.logError() then
			logger:error("@EventCommonGuideComponent 活动已预约，活动ID：%d", self.comp.eventId)
		end

		return true
	end

	pg.me:reqPreHeatReward(self.comp.eventId)

	return true
end

function WaterAreaGuideHandler:_refreshWaterAreaPreview()
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]
	local objectReference = self.waterSectorPreheatingUContainer.content:GetComponent("ObjectReference")
	local backgroundUImage = objectReference:GetRefValue("backgroundUImage")
	local centerTxt = objectReference:GetRefValue("centerTxt")
	local countDownTxt = objectReference:GetRefValue("countDownTxt")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

	ClientTextUtils.setText(centerTxt, pg.getLocalizationText(commonGuideData.eventDesc))
	ClientTextUtils.setText(countDownTxt, pg.getGameString("PRE_REG_COUNTDOWN_TEXT"))

	local previewTs = Utils.getConfigTimeOfArea(commonGuideData, "launchDayTime")

	LuaUIUtils.setCountDownTime(countDownUCountDown, previewTs, UIConst.TimeType.Short)

	backgroundUImage.url = commonGuideData.backImage
end

return WaterAreaGuideHandler
