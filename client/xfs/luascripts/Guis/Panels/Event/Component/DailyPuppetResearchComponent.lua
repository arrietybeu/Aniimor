-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\DailyPuppetResearchComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("DailyPuppetResearchComponent")
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
local PetAvatarData = require("Data.pet_avatar_data")
local ClientConst = require("Const.ClientConst")
local ItemSourceData = require("Data.item_source_data")
local DailyPuppetResearchComponent = Class.LightClass("DailyPuppetResearchComponent", EventContainerComponent)

function DailyPuppetResearchComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.listLuckyPetUList = self.objectReference:GetRefValue("listLuckyPetUList")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.curProgressUBaseText = self.objectReference:GetRefValue("curProgressUBaseText")
end

function DailyPuppetResearchComponent:addListener()
	function self.listLuckyPetUList.luaRenderItem(button, index, data)
		self:onRenderCatchItem(button, index, data)
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		self:onRenderRewardItem(button, index, data)
	end
end

function DailyPuppetResearchComponent:refreshPage()
	local eventData = GameEventData[self.eventId]

	if not eventData then
		return
	end

	self:setEventTitle(self.eventTitleUContainer, pg.me.luckyPetCurPhaseEndTm, nil, pg.getGameString("EVENT_TIME_TIP_5"))
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_PUPPET_CATCH)

	local rewardList = self.model:getPuppetCatchRewardDataList()

	self.listRewardUList:SetList(rewardList)

	local petList = self.model:getPuppetCatchList(self.eventId)

	self.listLuckyPetUList:SetList(petList)

	local curProgress = ActivityUtils.getLuckyPetScore(pg.me)
	local totalProgress = rewardList and rewardList[#rewardList].targetNum or -1

	ClientTextUtils.setText(self.curProgressUBaseText, pg.getFormatText("<b><color=#f3f5ff>{0}</color></b><size=-4>/{1}</size>", curProgress, totalProgress))
end

function DailyPuppetResearchComponent:onRenderCatchItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgPetUImage = objectReference:GetRefValue("imgPetUImage")
	local txtPetNameUBaseText = objectReference:GetRefValue("txtPetNameUBaseText")
	local listPointUList = objectReference:GetRefValue("listPointUList")
	local tagNewUWidget = objectReference:GetRefValue("tagNewUWidget")
	local btnTrackUButton = objectReference:GetRefValue("btnTrackUButton")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local txtNotGet = objectReference:GetRefValue("txtNotGet")

	button:TryChangePage("State", data.state)
	button:TryChangePage("multiple", ActivityUtils.getLuckyPetDoubleScore(data.index, data.templateId) and 1 or 0)

	imgPetUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)

	ClientTextUtils.setText(txtPetNameUBaseText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(txtNotGet, pg.getGameString("PETSHAPE_NOT_OWNED"))
	ClientTextUtils.setText(textUBaseText, "x2")

	local pointList = {}

	for i = 1, data.score do
		table.insert(pointList, {
			fake = true
		})
	end

	listPointUList:SetList(pointList)

	local templateId = data.templateId
	local hasCatch = pg.me.petHandbookMap:isCatched(templateId, Const.GROUP_TYPE_SELF)

	LuaUIUtils.setUIVisible(tagNewUWidget, not hasCatch)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_PUPPET_CATCH_GET_SCORE, index + 1)
	local isShowRedDot = pg.me.luckyPetIdFinish[index + 1] == true and pg.me.luckyPetIdSubmit[index + 1] ~= true

	pg.global.setRedDot(treePath, btnTrackUButton, isShowRedDot, RedDotConst.RedDotStyle.POINT)

	function btnTrackUButton.luaClick()
		self:onBtnBottomClick(data, index + 1)
	end
end

function DailyPuppetResearchComponent:onRenderRewardItem(button, index, data)
	if data.state == ClientConst.RewardState.ReadyToClaim then
		function data.extraFunc()
			local realIdx = index + 1

			if realIdx > 1 then
				local canGetRewardList = ActivityUtils.getLuckyPetCanRewardList(pg.me)

				if canGetRewardList[realIdx - 1] == true and pg.me.luckyPetDayRewarded[realIdx - 1] ~= true then
					realIdx = -1
				end
			end

			pg.me:reqActivityCatchScoreReward(self.eventId, realIdx)
			self.listRewardUList:RefreshList()
			self:refreshCommonNodeRedDot()
		end
	end

	self.view:onRenderRewardItem(button, index, data)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_PUPPET_CATCH_REWARD_ITEM, index + 1)
	local showRedDot = ClientActivityUtils.redDotPoint_CheckPetResearchCatchItem(index + 1)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)
end

function DailyPuppetResearchComponent:onBtnBottomClick(data, index)
	if data.state <= self.model.PuppetCatchState.Track then
		local sourceId = data.sourceId

		if sourceId then
			local sourceData = ItemSourceData[sourceId]

			LuaUIUtils.clueSeek(sourceData)
		end
	elseif data.state == self.model.PuppetCatchState.Reward then
		pg.me:reqActivityCatchGetScore(self.eventId, index)
	end

	local ctrl = self.ctrl

	if ctrl and ctrl.curComponent == self and not ctrl:checkUIClosing() then
		self:refreshPage()
	end
end

function DailyPuppetResearchComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return DailyPuppetResearchComponent
