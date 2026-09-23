-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\TikTokPetGuideHandler.lua

local Class = require("Core.Framework.Class")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local EventCommonGuideData = require("Data.event_common_guide_data")
local EventLittleFirePersonData = require("Data.event_littleFirePerson_data")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TikTokPetGuideHandler = Class.LightClass("TikTokPetGuideHandler", GuideHandlerBase)

function TikTokPetGuideHandler:getOwnedRefKeys()
	return {
		"tikTokPetUContainer"
	}
end

function TikTokPetGuideHandler:getOwnedContainers()
	return {
		"tikTokPetUContainer"
	}
end

function TikTokPetGuideHandler:needBtn1()
	return false
end

function TikTokPetGuideHandler:onFindObjects(objectReference)
	self.tikTokPetUContainer = objectReference:GetRefValue("tikTokPetUContainer")
end

function TikTokPetGuideHandler:onRefresh()
	if not self.tikTokPetUContainer then
		return
	end

	self.tikTokPetUContainer:SetActive(true)

	if self.tikTokPetUContainer:CheckURLLoaded() then
		self:_refreshTikTokPet()
	else
		self.tikTokPetUContainer:LoadDefaultUrlManually(function()
			self:_refreshTikTokPet()
		end)
	end
end

function TikTokPetGuideHandler:onExit()
	if self.tikTokPetUContainer then
		self.tikTokPetUContainer:SetActive(false)
	end
end

function TikTokPetGuideHandler:_refreshTikTokPet()
	if not self.tikTokPetUContainer or not self.tikTokPetUContainer.content then
		return
	end

	local objectReference = self.tikTokPetUContainer.content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnGetUComponent = objectReference:GetRefValue("btnGetUComponent")
	self.cardUComponent = objectReference:GetRefValue("cardUComponent")
	self.txtSelect = objectReference:GetRefValue("txtSelect")
	self.imgPetIcon = objectReference:GetRefValue("imgPetIcon")
	self.txtGetCondition = objectReference:GetRefValue("txtGetCondition")
	self.getBtnUButton = objectReference:GetRefValue("getBtnUButton")

	local getBtnObjRef = self.getBtnUButton:GetComponent("ObjectReference")
	local txtNameUText = getBtnObjRef:GetRefValue("txtNameUText")

	self:_refreshRewardState()

	if self.txtSelect then
		ClientTextUtils.setText(self.txtSelect, pg.getGameString("FIREMAN_NAME"))
	end

	if self.txtGetCondition then
		ClientTextUtils.setText(self.txtGetCondition, pg.getGameString("FIREMAN_LIMIT"))
	end

	if txtNameUText then
		local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]
		local btn1Txt = commonGuideData.btnName1 and pg.getLocalizationText(commonGuideData.btnName1) or pg.getGameString("BUTTON_NAME_4")

		ClientTextUtils.setText(txtNameUText, btn1Txt)
	end
end

function TikTokPetGuideHandler:_canReceiveReward()
	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.LittleFirePerson)
	local activityBase = activityData and activityData.activityBase
	local activityId = activityBase and activityBase.activityId

	if not activityId or activityId <= 0 then
		return false
	end

	local activityPhase = activityBase and activityBase.activityPhase
	local phaseData = activityPhase and EventLittleFirePersonData[activityPhase]
	local conditionId = phaseData and phaseData.claimCondition

	if not conditionId or conditionId <= 0 then
		return false
	end

	return ClientUtils.checkCondition(conditionId)
end

function TikTokPetGuideHandler:_openRewardUrl()
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]
	local schema = commonGuideData and commonGuideData.linkAddress1

	if not schema or schema == "" then
		return
	end

	pg.global.sdkManager:openSchema(schema)
end

function TikTokPetGuideHandler:_refreshRewardState()
	local canReceive = self:_canReceiveReward()

	self.btnGetUComponent:TryChangePage("Btn", canReceive and 1 or 0)

	if canReceive then
		function self.getBtnUButton.luaClick()
			self:_onClickReceive()
		end
	else
		self.getBtnUButton.luaClick = nil
	end
end

function TikTokPetGuideHandler:_onClickReceive()
	if not self:_canReceiveReward() then
		self:_refreshRewardState()

		return
	end

	self:_openRewardUrl()
end

return TikTokPetGuideHandler
