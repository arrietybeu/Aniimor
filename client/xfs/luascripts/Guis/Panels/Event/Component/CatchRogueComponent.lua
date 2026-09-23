-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CatchRogueComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CatchRogueComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local GameEventData = require("Data.game_event_data")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Time = require("Core.Common.Time")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local PetAvatarData = require("Data.pet_avatar_data")
local LimitData = require("Data.limit_data")
local EventCatchRogueData = require("Data.event_catch_rogue_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local CatchRogueComponent = Class.LightClass("CatchRogueComponent", EventContainerComponent)

function CatchRogueComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.detailsUBaseText = self.objectReference:GetRefValue("detailsUBaseText")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.btnChallengeUButton = self.objectReference:GetRefValue("btnChallengeUButton")
	self.listBossUList = self.objectReference:GetRefValue("listBossUList")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.txtTimesUBaseText = self.objectReference:GetRefValue("txtTimesUBaseText")
	self.pet1UContainer = self.objectReference:GetRefValue("pet1UContainer")
	self.pet2UContainer = self.objectReference:GetRefValue("pet2UContainer")
	self.pet3UContainer = self.objectReference:GetRefValue("pet3UContainer")
	self.pet4UContainer = self.objectReference:GetRefValue("pet4UContainer")
	self.pet5UContainer = self.objectReference:GetRefValue("pet5UContainer")
	self.pet6UContainer = self.objectReference:GetRefValue("pet6UContainer")
	self.catchPetBtnInfo = self.objectReference:GetRefValue("catchPetBtnInfo")
	self.remainChallengeTxt = self.objectReference:GetRefValue("remainChallengeTxt")
	self.elementUList = self.objectReference:GetRefValue("elementUList")
	self.elementTxt = self.objectReference:GetRefValue("elementTxt")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.txtLockUBaseText = self.objectReference:GetRefValue("txtLockUBaseText")
end

function CatchRogueComponent:addListener()
	function self.listRewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.btnChallengeUButton.luaClick()
		self:onBtnGoClick()
	end

	function self.listBossUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderCatchRogueCommonPet(button, index, data)
	end

	function self.btnInfoUButton.luaClick()
		local desc = ClientActivityUtils.getEventRule(self.eventId)

		pg.global.ui.tips:openEventRuleDesc(desc)
	end

	function self.elementUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.element)
	end

	function self.catchPetBtnInfo.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_PET_PREVIEW, {
			templateIds = CatchRoguePhaseData[self.gameId].catchpetType,
			title = pg.getGameString("CATCH_ROGUE_SHOW_PET")
		})
	end
end

function CatchRogueComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	self.gameId = EventCatchRogueData[self.eventPhase].gameId
	self.unlock = ActivityUtils.getOprActivityUnlockCond(self.eventId)
end

function CatchRogueComponent:refreshPage()
	local eventData = GameEventData[self.eventId]
	local catchRogueData = EventCatchRogueData[self.eventPhase]

	if not eventData or not catchRogueData then
		return
	end

	self.refUContainer.content:TryChangePage("LevelRestrictions", self.unlock and "Unlock" or "Lock")

	if not self.unlock then
		ClientTextUtils.setText(self.txtLockUBaseText, self.model:getEventLockInfo(self.eventId))
	end

	self.catchPetBtnInfo.enabledTooltip = false

	ClientTextUtils.setText(self.titleUBaseText, pg.getLocalizationText(catchRogueData.trainTitle))
	ClientTextUtils.setText(self.detailsUBaseText, pg.getLocalizationText(catchRogueData.trainDesc))

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local remainTime = eventTimeCfg.tabEndDayTime - Time.secondCache
	local d = ClientTextUtils.getGameString("DAY")
	local h = ClientTextUtils.getGameString("HOUR")
	local m = ClientTextUtils.getGameString("MINUTE")
	local s = ClientTextUtils.getGameString("SECOND")

	if remainTime > Const.SECONDS_ONE_DAY then
		self.countDownUCountDown.formatText = string.format("{0}%s{1}%s", d, h)
	else
		self.countDownUCountDown.formatText = string.format("{1}%s{2}%s", h, m)
	end

	self.countDownUCountDown:Play(remainTime)

	local rewards = LuaUIUtils.getRewardItemByDropId(catchRogueData.trainReward1)

	self.listRewardUList:SetList(rewards)

	local commonPetList = {}

	for index, data in ipairs(CatchRoguePhaseData[self.gameId].catchpetType or EMPTY_TABLE) do
		table.insert(commonPetList, {
			templateId = data,
			gameId = self.gameId
		})
	end

	self.listBossUList:SetList(commonPetList)

	for i = 1, 3 do
		local uContainer = self["pet" .. i .. "UContainer"]

		if not uContainer then
			return
		end

		if uContainer:CheckURLLoaded() then
			LuaUIUtils.renderCatchRogueCenterPet(i, uContainer.content, self.gameId)
		else
			uContainer:LoadDefaultUrlManually(function(content)
				LuaUIUtils.renderCatchRogueCenterPet(i, uContainer.content, self.gameId)
			end)
		end
	end

	local cnt = CatchRoguePhaseData[self.gameId].trainCount
	local curCnt, totalCnt = pg.me.catchRogueInfo.statCntFinishGame, cnt
	local remainCnt = totalCnt - curCnt

	ClientTextUtils.setText(self.remainChallengeTxt, string.format(pg.getGameString("CATCH_ROGUE_CHALLENGE_QUANTITY"), remainCnt, totalCnt))
	LuaUIUtils.renderPetElement(self.elementUList, EventCatchRogueData[self.eventPhase].gameType or {})
	ClientTextUtils.setText(self.elementTxt, pg.getLocalizationText(EventCatchRogueData[self.eventPhase].subTrainTitle))
end

function CatchRogueComponent:onBtnGoClick()
	local eventId = EventCatchRogueData[self.eventPhase].event

	if not eventId then
		logger:error("CatchRogueComponent:onBtnGoClick eventId is nil curActivityId is:%s ", self.eventId)

		return
	end

	if not self.unlock then
		return
	end

	pg.me:doEvent(eventId)
end

function CatchRogueComponent:onBtnTrackClick()
	self.model:redDotRecordSet(RedDotConst.RedDotPath.EVENT_CATCH_ROGUE_TRACK)

	local isShow = self.model:redDotRecordGet(RedDotConst.RedDotPath.EVENT_CATCH_ROGUE_TRACK)

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_CATCH_ROGUE_TRACK, self.btnTrackUButton, isShow, RedDotConst.RedDotStyle.POINT)
	self:refreshCommonNodeRedDot()

	local trackInfo = self.model:getTrackInfo(self.eventId, self.eventType)

	if not trackInfo then
		logger:error("CatchRogueComponent:onBtnTrackClick can not getTrackInfo curWeekWishId is:%s eventId:%s", self._curWeekWishId, self.eventId)

		return
	end

	local markStaticId = trackInfo.markStaticId
	local hasTrack = trackInfo.hasTrack

	if hasTrack then
		pg.game.map:manualUnTraceQuestMark(markStaticId)
		self.btnTrackUButton:TryChangePage("Track", 0)
	else
		local function cb()
			pg.game.map:manualTraceQuestMark(Const.MAP_MARK_TRACE, markStaticId, false)
			pg.global.ui:open(UIConst.UI_ID_MAP, {}, function()
				pg.global.ui.map:focusMark({
					string.format("mark_%s_%s", Const.MAP_MARK_TRACE, markStaticId),
					nil,
					true
				})
			end)
			self.btnTrackUButton:TryChangePage("Track", 1)
		end

		self.ctrl:startEventTrack(self.eventId, markStaticId, cb)
	end
end

return CatchRogueComponent
