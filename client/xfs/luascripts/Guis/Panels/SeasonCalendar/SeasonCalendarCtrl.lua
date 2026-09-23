-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonCalendar\\SeasonCalendarCtrl.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MODULE_TYPE_COMMON_FIRST = 0
local MODULE_TYPE_COMMON_SECOND = 1
local MODULE_TYPE_SPECIAL_FIRST = 2
local MODULE_TYPE_SPECIAL_SECOND = 3
local MODULE_TYPE_SEASON_CATCH = 4
local DISPLAY_TIME_TYPE_COUNT_DOWN = 1
local DISPLAY_TIME_TYPE_EXPECTED_OPEN = 2
local SeasonCalendarCtrl = Class.LightClass("SeasonCalendarCtrl", UICtrl)

SeasonCalendarCtrl.messages = {
	[MessageName.EVENT_REFRESH_REDDOT] = {
		"onActivityStateChanged",
		true
	},
	[MessageName.EVENT_REFRESH_TAB_LIST] = {
		"onActivityStateChanged",
		true
	},
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onActivityStateChanged",
		true
	}
}

function SeasonCalendarCtrl:getManagedBlurEffect()
	return self.view and self.view.staticUIBlurEffect
end

function SeasonCalendarCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()
end

function SeasonCalendarCtrl:addListener()
	self:_bindClick(self.view.btnCloseUButton, function()
		self:dismiss()
	end)
end

function SeasonCalendarCtrl:onOpen(info)
	if not self:_checkSeasonIntroductionActivityOpen() then
		return
	end

	self:_refreshCalendar()
end

function SeasonCalendarCtrl:onActivityStateChanged()
	if not self:_checkSeasonIntroductionActivityOpen() then
		return
	end

	self:_refreshCalendar()
end

function SeasonCalendarCtrl:_checkSeasonIntroductionActivityOpen()
	if self.model:isSeasonIntroductionActivityOpen() then
		return true
	end

	self:close()

	return false
end

function SeasonCalendarCtrl:_refreshCalendar()
	if self.view.txtTitleUSDFText then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("SEASON_LIMITED"))
	end

	local moduleDataList = self.model:getModuleList()
	local moduleList = self.view.listModuleUList

	if not moduleList then
		return
	end

	moduleList.ScrollType = CS.XGUI.EScrollType.Vertical

	for _, moduleData in ipairs(moduleDataList) do
		if moduleData.type == MODULE_TYPE_SEASON_CATCH then
			moduleData.tIndex = MODULE_TYPE_COMMON_FIRST
		else
			moduleData.tIndex = moduleData.type
		end
	end

	function moduleList.luaRenderItem(button, index, moduleData)
		self:_renderModule(button, moduleData)
	end

	moduleList:SetList(moduleDataList)
end

function SeasonCalendarCtrl:_renderModule(button, moduleData)
	if not button or not moduleData then
		return
	end

	button.luaClick = nil

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local titleText = moduleData.title and pg.getLocalizationText(moduleData.title) or ""

	ClientTextUtils.setText(txtTitleUSDFText, titleText)

	if bgUImage then
		bgUImage.url = moduleData.image or ""
	end

	local isCommonModule = moduleData.type == MODULE_TYPE_COMMON_FIRST or moduleData.type == MODULE_TYPE_COMMON_SECOND or moduleData.type == MODULE_TYPE_SEASON_CATCH

	if isCommonModule then
		self:_renderCommonModule(button, objectReference, moduleData)
	elseif moduleData.type == MODULE_TYPE_SPECIAL_FIRST then
		self:_renderSpecialFirstModule(button, objectReference, moduleData)
	elseif moduleData.type == MODULE_TYPE_SPECIAL_SECOND then
		self:_renderSpecialSecondModule(button, objectReference, moduleData)
	end

	self:_bindModuleClick(button, moduleData)
end

function SeasonCalendarCtrl:_renderCommonModule(button, objectReference, moduleData)
	local timeUWidget = objectReference:GetRefValue("timeUWidget")
	local timeUCountDown = objectReference:GetRefValue("timeUCountDown")
	local txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")

	if not moduleData.displayTimeType then
		if timeUCountDown then
			timeUCountDown:Stop()
		end

		if timeUWidget then
			timeUWidget:SetActive(false)
		end

		return
	end

	if moduleData.displayTimeType == DISPLAY_TIME_TYPE_COUNT_DOWN then
		button:TryChangePage("Time", 0)

		local endTime = self.model:getConfigTime(moduleData, "endTime")

		if not timeUCountDown or not endTime then
			if timeUWidget then
				timeUWidget:SetActive(false)
			end

			return
		end

		local currentTime = Time.secondCache or Time.getSecond()

		if endTime <= currentTime then
			timeUCountDown:Stop()

			if timeUWidget then
				timeUWidget:SetActive(false)
			end

			return
		end

		if timeUWidget then
			timeUWidget:SetActive(true)
		end

		LuaUIUtils.setCountDownTime(timeUCountDown, endTime, UIConst.TimeType.Short)
	elseif moduleData.displayTimeType == DISPLAY_TIME_TYPE_EXPECTED_OPEN then
		button:TryChangePage("Time", 1)

		if timeUWidget then
			timeUWidget:SetActive(true)
		end

		if timeUCountDown then
			timeUCountDown:Stop()
		end

		ClientTextUtils.setText(txtTipsUSDFText, self.model:getOpenTimeText(moduleData))
	end
end

function SeasonCalendarCtrl:_renderSpecialFirstModule(button, objectReference, moduleData)
	local buttonConfigs = self.model:getTemplateTwoButtonConfigs()

	for _, buttonConfig in ipairs(buttonConfigs) do
		self:_renderSpecialFirstButton(objectReference, buttonConfig)
	end
end

function SeasonCalendarCtrl:_renderSpecialFirstButton(objectReference, buttonConfig)
	local itemButton = objectReference:GetRefValue(buttonConfig.buttonRefName)

	if not itemButton then
		return
	end

	self:_bindModuleClick(itemButton, buttonConfig)

	local itemObjectReference = itemButton:GetComponent("ObjectReference")

	if not itemObjectReference then
		return
	end

	local txtTitleUSDFText = itemObjectReference:GetRefValue("txtTitleUSDFText")
	local bgUImage = itemObjectReference:GetRefValue("bgUImage")
	local titleText = ""

	if buttonConfig.titleKey and buttonConfig.titleKey ~= "" then
		titleText = pg.getGameString(buttonConfig.titleKey)
	end

	ClientTextUtils.setText(txtTitleUSDFText, titleText)

	if bgUImage then
		bgUImage.url = buttonConfig.imageUrl or ""
	end
end

function SeasonCalendarCtrl:_renderSpecialSecondModule(button, objectReference, moduleData)
	local itemBtnUList = objectReference:GetRefValue("itemBtnUList")

	if not itemBtnUList then
		return
	end

	function itemBtnUList.luaRenderItem(itemButton, index, itemData)
		self:_renderTreeActivityItem(itemButton, itemData)
	end

	itemBtnUList:SetList(self.model:getTreeActivityList(moduleData))
end

function SeasonCalendarCtrl:_renderTreeActivityItem(button, itemData)
	if not button or not itemData then
		return
	end

	button.luaClick = nil

	button:TryChangePage("State", itemData.state or 0)

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local petIconUImage = objectReference:GetRefValue("petIconUImage")
	local petIcon2UImage = objectReference:GetRefValue("petIcon2UImage")
	local weekUSDFText = objectReference:GetRefValue("weekUSDFText")
	local timeUSDFText = objectReference:GetRefValue("timeUSDFText")
	local indexUImage = objectReference:GetRefValue("indexUImage")
	local iconUrl = itemData.icon or ""

	if petIconUImage then
		petIconUImage.url = iconUrl
	end

	if petIcon2UImage then
		petIcon2UImage.url = iconUrl
	end

	if indexUImage then
		indexUImage.url = "$UI_Img_Event_Season_Overview_Bar_Num" .. itemData.index .. ".png"
	end

	local weekText = itemData.text and pg.getLocalizationText(itemData.text) or ""

	ClientTextUtils.setText(weekUSDFText, weekText)
	ClientTextUtils.setText(timeUSDFText, itemData.timeText or "")
end

function SeasonCalendarCtrl:_bindModuleClick(button, moduleData)
	local sourceData = self.model:getSourceData(moduleData.sourceId)

	if not sourceData then
		button.luaClick = nil

		return
	end

	function button.luaClick()
		self:_onCardClick(moduleData)
	end
end

function SeasonCalendarCtrl:_onCardClick(itemData)
	local sourceData = itemData and self.model:getSourceData(itemData.sourceId)

	if not sourceData then
		return
	end

	if sourceData.type == LuaUIUtils.ITEM_SOURCE_TYPE_TIPS then
		local tips = sourceData.tips and pg.getLocalizationText(sourceData.tips) or ""

		if tips ~= "" then
			pg.global.showBubbleMessageRaw(tips)
		end

		return
	end

	LuaUIUtils.clueSeek(sourceData, function()
		return
	end)
end

function SeasonCalendarCtrl:_bindClick(btn, callback)
	if not btn then
		return
	end

	btn.luaClick = callback
end

return SeasonCalendarCtrl
