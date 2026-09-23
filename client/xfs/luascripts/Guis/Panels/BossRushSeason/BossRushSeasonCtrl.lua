-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushSeason\\BossRushSeasonCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("BossRushSeasonCtrl")
local BossRushUtils = require("Utils.BossRushUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BossRushSeasonData = require("Data.bossrush_season_data")
local BossRushBuffData = require("Data.bossrush_buff_data")
local ItemData = require("Data.item_data")
local ItemConstSourceData = require("Data.item_const_source_data")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local UICtrl = require("Guis.UICtrl")
local BossRushSeasonCtrl = Class.LightClass("BossRushSeasonCtrl", UICtrl)

BossRushSeasonCtrl.messages = {}

local ANIM_DELAY_1 = 0.7
local ANIM_DELAY_2 = 0.3

local function getObtainItemList(awardIdList)
	local itemList = {}
	local itemIndexMap = {}

	for _, awardId in ipairs(awardIdList) do
		local rewards = LuaUIUtils.getRewardItemByDropId(awardId)

		for _, rewardData in ipairs(rewards) do
			if rewardData.type == 0 and rewardData.id and rewardData.num and rewardData.num > 0 then
				local itemIndex = itemIndexMap[rewardData.id]

				if itemIndex then
					itemList[itemIndex].itemCount = itemList[itemIndex].itemCount + rewardData.num
				else
					itemList[#itemList + 1] = {
						itemId = rewardData.id,
						itemCount = rewardData.num
					}
					itemIndexMap[rewardData.id] = #itemList
				end
			end
		end
	end

	return itemList
end

function BossRushSeasonCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if self.uiScene and not pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_MAIN) then
		self.uiScene:showModels()
		self.uiScene:setAllModelVisible(false)
	end
end

function BossRushSeasonCtrl:addListener()
	function self.view.seasonUCountDown.luaFinished()
		self:close()
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.BOSS_RUSH_HELP_SEASON)
	end

	function self.view.listUList.luaRenderItem(button, idx, data)
		self:renderList(button, idx, data)
	end

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.listUList.luaVirtualListRefreshCb()
		self:refreshGamepadDefaultFocus()
	end
end

function BossRushSeasonCtrl:onDestroy()
	if self.newBuffRedDotKeys then
		for redDotKey, v in pairs(self.newBuffRedDotKeys) do
			pg.me:setRedDotRecord(Const.CLIENT_KEY.BOSS_RUSH, redDotKey, false)
		end

		facade:sendMsgToUI(MessageName.BOSS_RUSH_RED_DOT_CHANGED)
	end

	UICtrl.onDestroy(self)
end

function BossRushSeasonCtrl:loadRewardList()
	local seasonId = self.seasonId == 0 and 1 or self.seasonId

	self.rewardList = self.model:getData(seasonId)
end

function BossRushSeasonCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.seasonId = BossRushUtils.getDisplaySeasonId()

	if pg.me.curBossRushSeasonId == 0 then
		self.view.countDownULayoutBox:SetActive(false)
	end

	self:loadRewardList()

	self.curStar = BossRushUtils.getCurSeasonStar()
	self.localReceivedRewards = {}
	self.newBuffRedDotKeys = {}
	self.blueRayIndex = self:getBlueRayIndex()

	pg.game.input:tempDisableInput(ANIM_DELAY_1 + ANIM_DELAY_2)
	self:startTimer(function()
		if self.view.listUList and NotNil(self.view.listUList) then
			self.view.listUList:SetList(self.rewardList)
			self:focusLatestReward()
		end
	end, ANIM_DELAY_1)
	ClientTextUtils.setText(self.view.starNumUSDFText, self.curStar)
	self:refreshNextRewardTip()
	self:refreshSeasonCountDown()
end

function BossRushSeasonCtrl:onShow()
	return
end

function BossRushSeasonCtrl:onHide()
	self.ItemEffPlayed = nil
end

function BossRushSeasonCtrl:onVisibleChange(visible)
	if visible and self.uiScene then
		self.uiScene:switchCameraPos(Const.BossRushTeleportTarget.Season)
		self.uiScene:setEnvComponentEnable(true)
	end
end

function BossRushSeasonCtrl:getRewardState(data)
	local isUnlocked = self.curStar >= data.needStar
	local isReceived = data.seasonBuff and isUnlocked or BossRushUtils.isSeasonRewardReceived(data.needStar) or self.localReceivedRewards and self.localReceivedRewards[data.needStar] or false

	return isUnlocked, isReceived
end

function BossRushSeasonCtrl:renderListType(button, idx, isReceived)
	local typeStatus = isReceived and 2 or self.blueRayIndex - 1 == idx and 1 or 0

	if typeStatus == 1 and not self.ItemEffPlayed then
		button:TryChangePage("type", 0)
		self:startTimer(function()
			button:TryChangePage("type", 1)
		end, ANIM_DELAY_2)

		self.ItemEffPlayed = true
	else
		button:TryChangePage("type", typeStatus, false, true, false)
	end
end

function BossRushSeasonCtrl:renderSeasonBuff(button, objectReference, data, isUnlocked)
	local comItemUButton = objectReference:GetRefValue("comItemUButton")
	local buffUButton = objectReference:GetRefValue("buffUButton")
	local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	local textDetailsUSDFText = objectReference:GetRefValue("textDetailsUSDFText")
	local textNameSelUSDFText = objectReference:GetRefValue("textNameSelUSDFText")
	local textDetailsSelUSDFText = objectReference:GetRefValue("textDetailsSelUSDFText")

	comItemUButton:ClearRedDot()
	buffUButton:ClearRedDot()
	button:TryChangePage("reward", 1)

	local buffData = BossRushBuffData[data.seasonBuff]

	if not buffData then
		ClientTextUtils.setText(textNameUSDFText, "")
		ClientTextUtils.setText(textDetailsUSDFText, "")

		return
	end

	local buffObjectReference = buffUButton:GetComponent("ObjectReference")
	local iconUImage = buffObjectReference:GetRefValue("iconUImage")

	iconUImage.url = buffData.buffIcon or ""

	buffUButton:TryChangePage("Level", 0)

	local levelStr = buffData.Bufflevel and " " .. pg.getGameString("LEVEL_LITE") .. tostring(buffData.Bufflevel) or ""

	ClientTextUtils.setText(textNameUSDFText, pg.getLocalizationText(buffData.buffName or "") .. levelStr)
	ClientTextUtils.setText(textDetailsUSDFText, pg.getLocalizationText(buffData.desc or ""))
	ClientTextUtils.setText(textNameSelUSDFText, pg.getLocalizationText(buffData.buffName or "") .. levelStr)
	ClientTextUtils.setText(textDetailsSelUSDFText, pg.getLocalizationText(buffData.desc or ""))

	local buffRedDotKey = string.format(RedDotConst.RedDotPath.BOSS_RUSH_SEASON_REWARD_BUFF, self.seasonId, data.seasonBuff)
	local showNew = isUnlocked and pg.me:getRedDotRecord(Const.CLIENT_KEY.BOSS_RUSH, buffRedDotKey, true)

	pg.global.setRedDot(buffRedDotKey, buffUButton, showNew, RedDotConst.RedDotStyle.NEW)

	if showNew then
		self.newBuffRedDotKeys[buffRedDotKey] = true
	end
end

function BossRushSeasonCtrl:onReceiveSeasonRewardSuccess(awardIdList)
	if type(awardIdList) == "table" then
		for _, rewardData in ipairs(self.rewardList or EMPTY_TABLE) do
			if not rewardData.seasonBuff and rewardData.needStar <= self.curStar then
				self.localReceivedRewards[rewardData.needStar] = true
			end
		end
	end

	self:loadRewardList()
	self.view.listUList:SetList(self.rewardList)
	self:focusLatestReward()

	local itemList = getObtainItemList(awardIdList)

	pg.global.ui.tips:showPropsObtainTips({
		itemList = itemList,
		source = ItemConstSourceData.ITEM_SOURCE_EVENT_BOSSRUSH_STAR
	})
end

function BossRushSeasonCtrl:receiveSeasonReward(needStar)
	pg.me:serverMsg("RPC_CS_BossRushReceiveSeasonReward", needStar, function(errno, awardIdList)
		if errno == NoticeDef.SUCCESS then
			self:onReceiveSeasonRewardSuccess(awardIdList)
		end
	end)
end

function BossRushSeasonCtrl:renderSeasonRewardItem(button, objectReference, data, isUnlocked, isReceived)
	local comItemUButton = objectReference:GetRefValue("comItemUButton")
	local buffUButton = objectReference:GetRefValue("buffUButton")
	local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	local textDetailsUSDFText = objectReference:GetRefValue("textDetailsUSDFText")
	local textNameSelUSDFText = objectReference:GetRefValue("textNameSelUSDFText")
	local textDetailsSelUSDFText = objectReference:GetRefValue("textDetailsSelUSDFText")

	buffUButton:ClearRedDot()
	button:TryChangePage("reward", 0)

	local rewards = LuaUIUtils.getRewardItemByDropId(data.awardId)
	local reward = rewards[1]

	if not reward or reward.type ~= 0 then
		comItemUButton:ClearRedDot()
		ClientTextUtils.setText(textNameUSDFText, "")
		ClientTextUtils.setText(textDetailsUSDFText, "")

		comItemUButton.luaClick = nil

		return
	end

	local itemRedDotKey = string.format(RedDotConst.RedDotPath.BOSS_RUSH_SEASON_REWARD_ITEM, self.seasonId, data.needStar)

	if isUnlocked and not isReceived then
		function reward.extraFunc()
			self:receiveSeasonReward(data.needStar)
		end
	end

	reward.hasGet = isReceived
	reward.canGet = isUnlocked and not isReceived

	LuaUIUtils.renderRewardItem(comItemUButton, reward)
	pg.global.setRedDot(itemRedDotKey, comItemUButton, reward.canGet, RedDotConst.RedDotStyle.REWARD)

	local itemData = ItemData[reward.id]

	ClientTextUtils.setText(textNameUSDFText, itemData and pg.getLocalizationText(itemData.itemName or "") or "")
	ClientTextUtils.setText(textDetailsUSDFText, itemData and pg.getLocalizationText(itemData.funcRep or "") or "")
	ClientTextUtils.setText(textNameSelUSDFText, itemData and pg.getLocalizationText(itemData.itemName or "") or "")
	ClientTextUtils.setText(textDetailsSelUSDFText, itemData and pg.getLocalizationText(itemData.funcRep or "") or "")
end

function BossRushSeasonCtrl:renderList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textStarNumUSDFText = objectReference:GetRefValue("textStarNumUSDFText")
	local isUnlocked, isReceived = self:getRewardState(data)

	ClientTextUtils.setText(textStarNumUSDFText, data.needStar)
	self:renderListType(button, idx, isReceived)

	if data.seasonBuff then
		self:renderSeasonBuff(button, objectReference, data, isUnlocked)
	else
		self:renderSeasonRewardItem(button, objectReference, data, isUnlocked, isReceived)
	end
end

function BossRushSeasonCtrl:focusLatestReward()
	local targetIndex = self:getLastRewardIndex()

	self.view.listUList:GoToIndex(targetIndex - 1, true)
end

function BossRushSeasonCtrl:refreshGamepadDefaultFocus()
	local targetIndex, isSeasonBuff = self:getLastRewardIndex()
	local res, btn = self.view.listUList:TryGetChildAt(targetIndex - 1)

	if not res then
		return
	end

	local objectReference = btn:GetComponent("ObjectReference")
	local comItemUButton = objectReference:GetRefValue("comItemUButton")
	local buffUButton = objectReference:GetRefValue("buffUButton")
	local focusItem = isSeasonBuff and buffUButton or comItemUButton

	self.view.listUList:SetNavGroupDefaultItem(focusItem)
	pg.global.navMgr:FocusItem(focusItem)
end

function BossRushSeasonCtrl:getLastRewardIndex()
	if not self.rewardList or #self.rewardList == 0 then
		return 1, false
	end

	local firstNewBuffIndex, firstReceivableItemIndex, firstUnfinishedIndex

	for index, data in ipairs(self.rewardList) do
		local isUnlocked, isReceived = self:getRewardState(data)

		if not firstUnfinishedIndex and not isReceived then
			firstUnfinishedIndex = index
		end

		if data.seasonBuff then
			if not firstNewBuffIndex and isUnlocked then
				local buffRedDotKey = string.format(RedDotConst.RedDotPath.BOSS_RUSH_SEASON_REWARD_BUFF, self.seasonId, data.seasonBuff)

				if pg.me:getRedDotRecord(Const.CLIENT_KEY.BOSS_RUSH, buffRedDotKey, true) then
					firstNewBuffIndex = index
				end
			end
		elseif not firstReceivableItemIndex and isUnlocked and not isReceived then
			firstReceivableItemIndex = index
		end
	end

	local targetIndex

	if firstNewBuffIndex and firstReceivableItemIndex then
		targetIndex = math.min(firstNewBuffIndex, firstReceivableItemIndex)
	else
		targetIndex = firstNewBuffIndex or firstReceivableItemIndex
	end

	targetIndex = targetIndex or firstUnfinishedIndex or #self.rewardList

	return targetIndex, self.rewardList[targetIndex].seasonBuff ~= nil
end

function BossRushSeasonCtrl:refreshNextRewardTip()
	local nextNeedStar

	for _, rewardData in ipairs(self.rewardList) do
		if rewardData.needStar > self.curStar then
			nextNeedStar = rewardData.needStar

			break
		end
	end

	if nextNeedStar then
		ClientTextUtils.setText(self.view.starTipsUSDFText, ClientTextUtils.getFormatText(ClientTextUtils.getGameString("BOSS_RUSH_SEASON_TIP1"), nextNeedStar - self.curStar))
	else
		ClientTextUtils.setText(self.view.starTipsUSDFText, "")
	end
end

function BossRushSeasonCtrl:refreshSeasonCountDown()
	local seasonData = BossRushSeasonData[self.seasonId]
	local endTime = seasonData and Utils.getConfigTimeOfArea(seasonData, "endDayTime") or 0

	if endTime and endTime > Time.getSecond() then
		self.view.seasonUCountDown:Play(endTime - Time.getSecond())
	else
		self.view.seasonUCountDown:Stop()
	end
end

function BossRushSeasonCtrl:getBlueRayIndex()
	if not self.rewardList or #self.rewardList == 0 then
		return 1, false
	end

	local targetIndex = 1

	for index, data in ipairs(self.rewardList) do
		local isUnlocked = self.curStar >= data.needStar

		targetIndex = index

		if not isUnlocked then
			break
		end
	end

	return targetIndex
end

return BossRushSeasonCtrl
