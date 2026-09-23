-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapture\\FishingCaptureCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("FishingCaptureCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local PetData = require("Data.pet_data")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local MatchConst = require("Common.Const.MatchConst")
local lume = require("Core.Common.lume")
local FishingCaptureCtrl = Class.LightClass("FishingCaptureCtrl", UICtrl)

FishingCaptureCtrl.MODE = {
	SINGLE = 1,
	MULTI = 2
}
FishingCaptureCtrl.messages = {
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItems",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onMoneyCountChange",
		true
	}
}

function FishingCaptureCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function FishingCaptureCtrl:addListener()
	self:bindCloseButton()

	function self.view.btnConfirmUButton.luaClick()
		self:onBtnEnterClick()
	end

	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnInfoUButton.luaClick()
		self:onBtnInfoClick()
	end

	function self.view.rewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	if not IsNil(self.view.listCurrencyUList) then
		function self.view.listCurrencyUList.luaRenderItem(button, index, data)
			LuaUIUtils.setTopCurrencyItem(button, data.itemId)
		end
	end

	function self.view.recommendEleList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.element)
	end
end

function FishingCaptureCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.model:setOpenInfo(info)
	self:refreshAll()
end

function FishingCaptureCtrl:onShow()
	self:refreshAll()
	pg.game.audio:playEvent(FishingCaptureConst.SFX_ACTIVITY_UI)
end

function FishingCaptureCtrl:onHide()
	pg.game.audio:stopEvent(FishingCaptureConst.SFX_ACTIVITY_UI)
end

function FishingCaptureCtrl:onDestroy()
	self.loadingEntranceBackgroundType = nil

	UICtrl.onDestroy(self)
end

function FishingCaptureCtrl:refreshAll()
	self.activityInfo = self.model:getActivityInfo()

	if not self.activityInfo then
		return
	end

	self:refreshEntranceBackground()
	self:refreshActivityInfo()
	self:refreshDynamic()
end

function FishingCaptureCtrl:refreshEntranceBackground()
	local entranceType = self.model:getEntranceType()

	self.view.widget:TryChangePage("DungType", self.model:getEntranceStatePage())

	local container = self.view.entranceBgUContainers and self.view.entranceBgUContainers[entranceType]

	for containerType, entranceBgUContainer in ipairs(self.view.entranceBgUContainers) do
		entranceBgUContainer:SetActive(containerType == entranceType)
	end

	if not container then
		return
	end

	if container:CheckURLLoaded() then
		if entranceType == FishingCaptureConst.EntranceType.Final then
			self:refreshBossInfo(container.content)
		end

		return
	end

	if self.loadingEntranceBackgroundType == entranceType then
		return
	end

	self.loadingEntranceBackgroundType = entranceType

	container:LoadDefaultUrlManually(function(content)
		if self.loadingEntranceBackgroundType == entranceType then
			self.loadingEntranceBackgroundType = nil
		end

		if self.model:getEntranceType() ~= entranceType then
			return
		end

		if entranceType == FishingCaptureConst.EntranceType.Final then
			self:refreshBossInfo(content)
		end
	end)
end

function FishingCaptureCtrl:refreshMode()
	local mode = self.model:getSelectedMode()

	self.view.btnSingleUButton.interactable = mode ~= FishingCaptureCtrl.MODE.SINGLE
	self.view.btnMultiUButton.interactable = mode ~= FishingCaptureCtrl.MODE.MULTI

	if self.uiScene then
		self.uiScene:switchMode(mode)
	end
end

function FishingCaptureCtrl:refreshActivityInfo()
	ClientTextUtils.setText(self.view.dungeonNameUText, pg.getLocalizationText(self.model:getEntranceName()))

	local rewardId = self.model:getDisplayRewardId()
	local rewards = LuaUIUtils.getRewardItemByDropId(rewardId)

	self.view.rewardUList:SetList(rewards)
	ClientTextUtils.setText(self.view.challengeUText, pg.getGameString("FC_ENTRY_START_CHALLENGE"))

	local elements = self.model:getElementList()

	self.view.recommendEleList:SetList(elements)
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("FC_ENTRY_RECOMMEND_ATTR"))
	ClientTextUtils.setText(self.view.backTitle, pg.getGameString("FC_ENTRY_DUNGEON_TITLE"))
	ClientTextUtils.setText(self.view.txtDetailsUScrollRect.content:GetComponent("UBaseText"), pg.getLocalizationText(self.model:getEntranceDescription()))

	local rewardTitle = pg.getGameString("FC_ENTRY_REWARD_PREVIEW")

	if self.model:isWeeklyEntrance() then
		local _, costCount = self.model:getWeeklyChestCost()

		if costCount then
			rewardTitle = string.format(pg.getGameString("FC_WEEK_REWARD_TEXT"), costCount)
		end
	end

	ClientTextUtils.setText(self.view.rewardTitleUSDFText, rewardTitle)

	local level = self.activityInfo.recommendLevel

	if level then
		ClientTextUtils.setText(self.view.txtLevelUBaseText, string.format("Level %d", level))
	end

	ClientTextUtils.setText(self.view.txtLevelNameUBaseText, pg.getGameString("FC_ENTRY_LEVEL"))
	self:_refreshActivityCountDown()
	ClientTextUtils.setText(self.view.infoTxt, pg.getGameString("BATTLEPASS_RULE_TITLE"))
end

function FishingCaptureCtrl:refreshBossInfo(bossCatchModeUWidget)
	if not bossCatchModeUWidget then
		return
	end

	local bossObjectReference = bossCatchModeUWidget:GetComponent("ObjectReference")

	if not bossObjectReference then
		logger:warn("refreshBossInfo: ObjectReference not found")

		return
	end

	local btnLabelUButton = bossObjectReference:GetRefValue("labelUButton")
	local petNameUBaseText = bossObjectReference:GetRefValue("petNameUBaseText")
	local elementUButton = bossObjectReference:GetRefValue("elementUButton")
	local labelTxt = bossObjectReference:GetRefValue("labelBoss")

	if labelTxt then
		ClientTextUtils.setText(labelTxt, pg.getGameString("PET_STAGE_TXT_4"))
	end

	local templateId = self.activityInfo.keyPetType
	local pData = PetData[templateId]

	if not pData then
		logger:error("refreshActivityInfo: PetData missing for keyPetType=%s", tostring(templateId))

		return
	end

	local _, names = LuaUIUtils.getElementInfo(pData.elementType)

	if petNameUBaseText then
		ClientTextUtils.setText(petNameUBaseText, pg.getLocalizationText(LuaUIUtils.getPetNameWithIdOrTmpId(templateId)))
	end

	if elementUButton then
		LuaUIUtils.setElementButtonNew(elementUButton, names[1].element)
	end

	if btnLabelUButton then
		function btnLabelUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				templateId = templateId
			})
		end
	end
end

function FishingCaptureCtrl:_refreshActivityCountDown()
	local endTime = self.model:getActivityEndTime()
	local nowTime = Time.secondCache or 0
	local leftSecond = endTime - nowTime

	if endTime <= 0 or leftSecond <= 0 then
		self.view.countDownUCountDown:SetActive(false)
		self.view.timeTitleTxt:SetActive(false)

		return
	end

	self.view.countDownUCountDown:SetActive(true)
	self.view.timeTitleTxt:SetActive(true)
	ClientTextUtils.setText(self.view.timeTitleTxt, pg.getGameString("EVENT_TIME_TIP_5"))
	LuaUIUtils.setCountDownTime(self.view.countDownUCountDown, leftSecond, UIConst.TimeType.Short, nil, nil, true)
end

function FishingCaptureCtrl:refreshDynamic()
	local isWeeklyEntrance = self.model:isWeeklyEntrance()

	self.view.txtTipsUBaseText:SetActive(isWeeklyEntrance)

	if isWeeklyEntrance then
		local remainCount, limitCount = self.model:getWeeklyChallengeCount()

		ClientTextUtils.setText(self.view.txtTipsUBaseText, pg.getFormatText(pg.getGameString("FC_WEEKLY_COUNT_TEXT"), remainCount, limitCount))
	end

	if not IsNil(self.view.listCurrencyUList) then
		local currencyItems = {}

		for _, itemId in ipairs(self.model:getTopCurrencyItemIds()) do
			currencyItems[#currencyItems + 1] = {
				itemId = itemId
			}
		end

		if #currencyItems > 0 then
			self.view.listCurrencyUList:SetActive(true)
			self.view.listCurrencyUList:SetList(currencyItems)
		else
			self.view.listCurrencyUList:SetActive(false)
		end
	end
end

function FishingCaptureCtrl:refreshPetModel()
	if not self.uiScene then
		return
	end

	local petId = self.model:getDisplayPetId()

	if petId then
		self.uiScene:showPetModel(petId)
	end
end

function FishingCaptureCtrl:onBtnEnterClick()
	local canEnter, reason = self.model:checkEnterCondition()

	if not canEnter then
		pg.global.showBubbleMessageRaw(reason)

		return
	end

	if self.model:isWeeklyEntrance() then
		if not self:checkWeeklyChallengeCount() then
			return
		end

		local costItemId, costItemNum = self.model:getWeeklyChestCost()

		if costItemId and costItemNum and costItemNum > pg.me:getItemCountById(costItemId) then
			self:openWeeklyChestCostConfirm(costItemId, costItemNum)

			return
		end

		self:enterWeeklyDungeon()

		return
	end

	local mode = self.model:getSelectedMode()

	logger:debug("onBtnEnterClick mode=%d", mode)
	pg.me:requestEnter(function(noticeId, noticeArgs)
		if noticeId ~= NoticeDef.SUCCESS then
			pg.global.showBubbleMessageById(noticeId, noticeArgs)
		end
	end)
end

function FishingCaptureCtrl:openWeeklyChestCostConfirm(costItemId, costItemNum)
	local ownItemNum = pg.me:getItemCountById(costItemId)
	local costText = LuaUIUtils.getItemCountConsumeShowText(costItemId, costItemNum)
	local ownText = LuaUIUtils.getItemCountConsumeShowText(costItemId, ownItemNum)
	local tipText = pg.getFormatText(pg.getGameString("FC_WEEKLY_CHEST_STAMINA_CONFIRM"), costText, ownText)

	pg.global.ui.commonUseConfirm:open({
		muteCheckEnough = true,
		title = pg.getGameString("FC_CONFIRM_START_TITLE"),
		tipTop = tipText,
		data = {
			{
				costItemId,
				costItemNum
			}
		},
		confirmCb = function()
			self:enterWeeklyDungeon()
		end
	})
end

function FishingCaptureCtrl:checkWeeklyChallengeCount()
	local remainCount = self.model:getWeeklyChallengeCount()

	if remainCount <= 0 then
		pg.global.showBubbleMessageById(NoticeDef.WEEKLY_DUNGEON_COUNT_LIMIT)

		return false
	end

	return true
end

function FishingCaptureCtrl:enterWeeklyDungeon()
	if not self:checkWeeklyChallengeCount() then
		return
	end

	local dungeonSceneId = self.model:getEntranceSceneId()

	if not dungeonSceneId then
		logger:error("enterWeeklyDungeon: weeksceneId not found")

		return
	end

	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	if pg.me:isInTeam() and lume.getMapLen(pg.me.teamInfo.playerInDungeon) > 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_HAS_PLAYER_IN_DUNGEON"))

		return
	end

	pg.me:serverMsg("RPC_CS_ApplyEnterTeamDungeon", dungeonSceneId, 0, MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER)
	self:dismiss()
end

function FishingCaptureCtrl:onBtnInfoClick()
	local rule = self.model:getEntranceRule()

	if not rule then
		return
	end

	pg.global.ui.tips:openEventRuleDesc(pg.getLocalizationText(rule))
end

function FishingCaptureCtrl:onBuyItems(data)
	self:refreshDynamic()
end

function FishingCaptureCtrl:onMoneyCountChange()
	if not self.model:isWeeklyEntrance() then
		return
	end

	self:refreshDynamic()
end

return FishingCaptureCtrl
