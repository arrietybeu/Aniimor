-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\PetSaveManualComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local GameEventData = require("Data.game_event_data")
local PetSaveManualData = require("Data.event_petsave_manual_data")
local SysConfigData = require("Data.sys_config_data")
local UIComponent = require("Guis.Helper.UIComponent")
local PetSaveManualComponent = Class.LightClass("PetSaveManualComponent", UIComponent)

function PetSaveManualComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.listDateUList = self.objectReference:GetRefValue("listDateUList")
	self.btnViewUButton = self.objectReference:GetRefValue("btnViewUButton")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.txtTipsTitle = self.objectReference:GetRefValue("txtTipsTitle")
end

function PetSaveManualComponent:onCtor(info)
	self.eventId = info.eventId
	self.week = info.week
	self.pshase = pg.me.activityPetSaveData.pshase or 1
end

function PetSaveManualComponent:initView()
	self:addListener()
	self:refreshPage()
end

function PetSaveManualComponent:addListener()
	function self.btnViewUButton.luaClick()
		if ClientActivityUtils.checkPetSaveFirstWeek(self.week) then
			pg.global.ui.tips:showTextTip(pg.getGameString("PET_SAVE_WEEK_1_TIP"))

			return
		end

		pg.global.ui:open(UIConst.UI_ID_Event_PetSave_Manual, {
			weekIndex = self.week,
			eventId = self.eventId
		})
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.listDateUList.luaRenderItem(button, index, data)
		self:renderManualItem(button, index, data)
	end

	self.btnInfoUButton.enabledTooltip = false

	function self.btnInfoUButton.luaClick()
		local desc = ClientActivityUtils.getEventRule(self.eventId)

		pg.global.ui.tips:openEventRuleDesc(desc)
	end
end

function PetSaveManualComponent:refreshPage()
	local eventData = GameEventData[self.eventId]

	if not eventData then
		return
	end

	ClientTextUtils.setText(self.txtTipsTitle, pg.getGameString("PET_SAVE_CALENDAR_TIP"))
	self.rootUComponent:TryChangePage("Bg", Utils.getServerArea() == Const.SERVER_AREANO.CN and 2 or 1)

	local countDownWeek
	local nextWeek = PetSaveManualData[self.pshase][1][self.week + 1]

	if nextWeek then
		countDownWeek = Utils.getConfigTimeOfArea(nextWeek, "startTime")
	end

	if self.ctrl and self.ctrl.setEventTitle then
		self.ctrl:setEventTitle(self.eventTitleUContainer, countDownWeek, pg.getGameString("PET_SAVE_WEEK_TITLE"), pg.getGameString("EVENT_TIME_TIP_2"), PetSaveManualData[self.pshase][1][self.week].rule, pg.getGameString("PET_SAVE_WEEK_DESC"))
	end

	LuaUIUtils.setCountDownTime(self.countDownUCountDown, Utils.getConfigTimeOfArea(PetSaveManualData[self.pshase][2][121], "startTime"), UIConst.TimeType.Short)

	local rewards = LuaUIUtils.getRewardItemByDropId(PetSaveManualData[self.pshase][1][self.week].showRewardId)

	self.listRewardUList:SetList(rewards)

	self.startTime = Utils.getConfigTimeOfArea(PetSaveManualData[self.pshase][1][111], "startTime")
	self.manualDates = {}
	self.blankDays = (SysConfigData.ALBUM_BLANK_DAYS or EMPTY_TABLE)[Utils.getServerArea()] or 0

	for i = 1, self.blankDays do
		self.manualDates[i] = {
			tIndex = 1
		}
	end

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local allDay = math.ceil((eventTimeCfg.tabEndDayTime - eventTimeCfg.tabStartDayTime) / Const.SECONDS_ONE_DAY)

	self.allDay = allDay

	for i = 1, allDay do
		self.manualDates[self.blankDays + i] = {
			tIndex = 0
		}
	end

	self.listDateUList:SetList(self.manualDates)
	self:refreshNodeRedDot()
end

function PetSaveManualComponent:refreshNodeRedDot()
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_PET_SAVE_REWARD, self.btnViewUButton, ClientActivityUtils.checkPetSaveRewardPoint(), RedDotConst.RedDotStyle.REWARD)
end

function PetSaveManualComponent:renderManualItem(item, index, data)
	if data.tIndex == 1 then
		return
	end

	local dateType = 0
	local showIndex = index - (self.blankDays or 0)
	local objectReference = item:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	if showIndex + 1 == self.allDay then
		dateType = 3
	else
		local time = self.startTime + showIndex * Const.SECONDS_ONE_DAY
		local leftTime = Time.getSecond() - time

		if leftTime < 0 then
			dateType = 2
		elseif leftTime < Const.SECONDS_ONE_DAY then
			dateType = 1
		end
	end

	ClientTextUtils.setText(txtNameUBaseText, showIndex + 1)
	item:TryChangePage("Date", dateType)
end

return PetSaveManualComponent
