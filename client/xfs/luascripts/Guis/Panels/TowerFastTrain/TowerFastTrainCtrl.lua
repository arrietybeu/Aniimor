-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerFastTrain\\TowerFastTrainCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerFastTrainCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TowerFastTrainCtrl = Class.LightClass("TowerFastTrainCtrl", UICtrl)
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local ElementPropData = require("Data.element_prop_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")
local TalentEventData = require("Data.talent_event_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ItemData = require("Data.item_data")
local AddressDataConst = require("Const.AddressDataConst")
local AudioConst = require("Const.AudioConst")
local STAMINA_ITEM_ID = Const.CommonEnergyType_Stamina
local SWEEP_TICKET_ITEM_ID = Const.CommonItemID_SweepTicket

TowerFastTrainCtrl.messages = {
	[MessageName.MONEY_COUNT_CHANGE] = {
		"refreshCost",
		true
	},
	[MessageName.ITEM_GEN_COUNT_CHANGE] = {
		"refreshCost",
		true
	}
}

function TowerFastTrainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.levelId = info and info.levelId
	self.difficultyCfg = self.levelId and RogueDifficultyData[self.levelId]

	if not self.difficultyCfg then
		self:close()

		return
	end

	self.curTrainType = nil
	self.curTimes = 1
	self.pageState = 0
	self.isShowingResult = false
	self.showCurrencyIds = {
		{
			needAdd = false,
			itemId = SWEEP_TICKET_ITEM_ID
		},
		{
			needAdd = true,
			itemId = STAMINA_ITEM_ID
		}
	}

	self:initUI()
end

function TowerFastTrainCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCancelUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.pageState == 0 then
			self:onConfirm()
		elseif self.pageState == 1 then
			self:skipToAllRewards()
		elseif self.pageState == 2 then
			self:resetToConfigState()
		end
	end

	function self.view.trainTypeUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local typeNameUBaseText = objectReference:GetRefValue("typeNameUBaseText")
		local typeIconUImage = objectReference:GetRefValue("typeIconUImage")
		local itemUButton = objectReference:GetRefValue("itemUButton")

		ClientTextUtils.setText(typeNameUBaseText, data.name)

		typeIconUImage.url = data.url or ""

		itemUButton:TryChangePage("Quality", data.quality)
	end

	function self.view.trainTypeUList.luaClick(button, data)
		self.curTrainType = data.trainType

		self:refreshRewardPreview()
		self:refreshCost()
	end

	function self.view.trainTimesUNumSelector.luaValueChanged(num)
		self.curTimes = num

		self:refreshCost()
	end

	function self.view.trainFinishRewardUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local titleUBaseText = objectReference:GetRefValue("titleUBaseText")
		local rewardUList = objectReference:GetRefValue("rewardUList")
		local text = string.gsub(pg.getGameString("TOWER_FAST_TRAIN_REWARD_ITEM_TITLE"), "{index}", index + 1)

		ClientTextUtils.setText(titleUBaseText, text)

		function rewardUList.luaRenderItem(rewardButton, rewardIndex, rewardData)
			LuaUIUtils.renderRewards(rewardButton, rewardIndex, rewardData)
		end

		rewardUList:SetList(data.items)
	end
end

function TowerFastTrainCtrl:initUI()
	ClientTextUtils.setText(self.view.titleUBaseText, pg.getGameString("TOWER_FAST_TRAIN_TITLE"))
	ClientTextUtils.setText(self.view.btnConfirmUText, pg.getGameString("TOWER_FAST_TRAIN_CONFIRM"))
	ClientTextUtils.setText(self.view.btnCancelUText, pg.getGameString("TOWER_FAST_TRAIN_CANCEL"))

	local cfg = self.difficultyCfg

	if cfg.elementType then
		self.view.levelElementUButton:TryChangePage("type", cfg.elementType)

		function self.view.levelElementUButton.luaClick()
			pg.global.ui.tips:showRestraint(cfg.elementName)
		end
	end

	ClientTextUtils.setText(self.view.levelNameUBaseText, pg.getLocalizationText(cfg.levelName))
	ClientTextUtils.setText(self.view.lvUBaseText, "Lv." .. (cfg.recommendLv or 0))

	local trainTypes = {}

	if cfg.sweepRewardSetClient2 then
		self.curTrainType = Const.RogueExchangeRewardType.Gem

		table.insert(trainTypes, {
			selected = true,
			name = pg.getGameString("TOWER_FAST_TRAIN_TYPE_RUNE"),
			url = AddressDataConst.ROGUE_GEM_ICON,
			trainType = Const.RogueExchangeRewardType.Gem,
			quality = cfg.sweepRewardIconLevelSet2
		})
	end

	self.trainTypes = trainTypes

	self.view.trainTypeUList:SetList(trainTypes)

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId, data.needAdd)
	end

	self.view.listCurrencyUList:SetList(self.showCurrencyIds)
	self:refreshTimesSelector()
	self:refreshRewardPreview()
	self:refreshCost()
	ClientTextUtils.setText(self.view.rewardTitleUBaseText, pg.getGameString("TOWER_FAST_TRAIN_REWARD_TITLE"))
	ClientTextUtils.setText(self.view.trainTimesTitleUBaseText, pg.getGameString("TOWER_FAST_TRAIN_TIMES_TITLE"))
	ClientTextUtils.setText(self.view.costUBaseText, pg.getGameString("TOWER_FAST_TRAIN_COST"))
	ClientTextUtils.setText(self.view.quickTrainNumUBaseText, pg.getGameString("TOWER_FAST_TRAIN_TIMES"))
end

function TowerFastTrainCtrl:refreshTimesSelector()
	self.view.trainTimesUNumSelector.minValue = 1
	self.view.trainTimesUNumSelector.maxValue = 10
	self.view.trainTimesUNumSelector.value = math.min(self.curTimes, 10)
	self.curTimes = self.view.trainTimesUNumSelector.value
end

function TowerFastTrainCtrl:refreshRewardPreview()
	local cfg = self.difficultyCfg
	local dropId = self.curTrainType == Const.RogueExchangeRewardType.CarryItem and cfg.sweepRewardSetClient1 or cfg.sweepRewardSetClient2

	LuaUIUtils.setRewardListByDropId(self.view.rewardItemUList, dropId)
end

function TowerFastTrainCtrl:refreshCostCurrency(button, cost, itemId)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local countUText = objectReference:GetRefValue("countUText")
	local itemCfg = ItemData[itemId]

	if iconUImage and itemCfg then
		iconUImage.url = itemCfg.icon or ""
	end

	if countUText then
		local owned = pg.me:getItemCountById(itemId, true)
		local styleText = ""

		if owned < cost then
			styleText = "<style=Debuff>"
		end

		ClientTextUtils.setText(countUText, "")
		ClientTextUtils.setText(countUText, styleText, cost)
	end
end

function TowerFastTrainCtrl:refreshCost()
	local cfg = self.difficultyCfg
	local totalStamina = (cfg.sweepStamina or 0) * self.curTimes
	local totalTicket = (cfg.sweepTicket or 1) * self.curTimes

	self:refreshCostCurrency(self.view.coin1UButton, totalStamina, STAMINA_ITEM_ID)
	self:refreshCostCurrency(self.view.coin2UButton, totalTicket, SWEEP_TICKET_ITEM_ID)
	self.view.listCurrencyUList:RefreshList()
end

function TowerFastTrainCtrl:onConfirm()
	if self.needForbidden then
		return
	end

	if not self.curTrainType then
		return
	end

	local cfg = self.difficultyCfg
	local totalStamina = (cfg.sweepStamina or 0) * self.curTimes
	local totalTicket = (cfg.sweepTicket or 1) * self.curTimes

	if totalStamina > pg.me:getItemCountById(STAMINA_ITEM_ID, true) then
		LuaUIUtils.openVitalityGot(STAMINA_ITEM_ID)

		return
	end

	if totalTicket > pg.me:getItemCountById(SWEEP_TICKET_ITEM_ID, true) then
		self:onTicketNotEnough()

		return
	end

	pg.me:getCopyPlayerUid()

	self.needForbidden = true

	pg.me:reqSweepLevel(self.levelId, self.curTimes, self.curTrainType, function(result, rewards)
		self.needForbidden = false

		if not result then
			return
		end

		self:showTrainResult(rewards)
	end)
end

function TowerFastTrainCtrl:showTrainResult(rewards)
	self.isShowingResult = true

	self.view.rootUComponent:TryChangePage("Stage", 1)

	self.pageState = 1

	ClientTextUtils.setText(self.view.btnConfirmUText, pg.getGameString("TOWER_FAST_TRAIN_SKIP"))
	ClientTextUtils.setText(self.view.quickTrainingUBaseText, pg.getGameString("TOWER_FAST_TRAIN_IN_PROGRESS"))

	local rewardItems = rewards or {}

	self.displayIndex = 0
	self.allRewards = {}

	for i, reward in ipairs(rewardItems) do
		local items = {}
		local fixedItems = {}

		for id, info in pairs(reward) do
			local itemConfig = ItemData[id]
			local num = type(info) == "table" and info[3] or info
			local item = {
				type = 0,
				tIndex = 0,
				id = id,
				num = num,
				quality = itemConfig.quality
			}

			if id == 1001 then
				fixedItems[1] = item
			elseif id == 5000 then
				fixedItems[2] = item
			elseif id == 5001 then
				fixedItems[3] = item
			else
				table.insert(items, item)
			end
		end

		table.sort(items, function(a, b)
			return a.quality > b.quality
		end)

		for i = 3, 1, -1 do
			if fixedItems[i] then
				table.insert(items, 1, fixedItems[i])
			end
		end

		for i = #items + 1, 10 do
			table.insert(items, {
				tIndex = 1
			})
		end

		table.insert(self.allRewards, {
			items = items
		})
	end

	self.view.trainFinishRewardUList.visibility = CS.XGUI.EVisibility.HitTestInvisible

	self:displayNextReward()

	if pg.game.input:isUsingGamepad() then
		pg.global.navMgr:SetNavGroupForceNonInteractable("ListFinish", true)
	end
end

function TowerFastTrainCtrl:displayNextReward()
	if self.displayIndex >= #self.allRewards then
		self:onAllRewardsShown()

		return
	end

	pg.game.audio:playEvent(AudioConst.SFX_ROGUE_SWEEP)

	self.displayIndex = self.displayIndex + 1

	self:addFinishRewardList(self.allRewards[self.displayIndex])
	self:startTimer(function()
		self:displayNextReward()
	end, 0.3)
end

function TowerFastTrainCtrl:skipToAllRewards()
	self:killAllTimer()

	self.displayIndex = #self.allRewards

	self.view.trainFinishRewardUList:SetList(self.allRewards)
	self:startTimer(function()
		self.view.trainFinishRewardUList:GoToIndex(-1)
	end, 0)
	self:onAllRewardsShown()
end

function TowerFastTrainCtrl:addFinishRewardList(items)
	self.view.trainFinishRewardUList:AddElement(items)
	self:startTimer(function()
		self.view.trainFinishRewardUList:GoToIndex(-1)
	end, 0)

	local shown = self.displayIndex
	local total = #self.allRewards

	ClientTextUtils.setText(self.view.quickTrainProgressUBaseText, shown .. "/" .. total)
end

function TowerFastTrainCtrl:focusLastItem()
	local count = self.view.trainFinishRewardUList.itemCount or 1
	local res, btn = self.view.trainFinishRewardUList:TryGetChildAt(count - 1)

	if not res then
		return
	end

	pg.global.navMgr:FocusItem(btn)
end

function TowerFastTrainCtrl:onAllRewardsShown()
	self.view.trainFinishRewardUList.visibility = CS.XGUI.EVisibility.Visible

	pg.game.audio:playEvent(AudioConst.SFX_ROGUE_SWEEP_FINISH)
	self.view.rootUComponent:TryChangePage("Stage", 2)

	self.pageState = 2

	ClientTextUtils.setText(self.view.btnConfirmUText, pg.getGameString("TOWER_FAST_TRAIN_AGAIN"))
	ClientTextUtils.setText(self.view.btnCancelUText, pg.getGameString("TOWER_FAST_TRAIN_FINISH"))
	ClientTextUtils.setText(self.view.quickTrainingUBaseText, pg.getGameString("TOWER_FAST_TRAIN_COMPLETE"))

	local total = #self.allRewards

	ClientTextUtils.setText(self.view.quickTrainProgressUBaseText, total .. "/" .. total)

	if pg.game.input:isUsingGamepad() then
		pg.global.navMgr:SetNavGroupForceNonInteractable("ListFinish", false)
		self:focusLastItem()
	end
end

function TowerFastTrainCtrl:resetToConfigState()
	self.isShowingResult = false

	self.view.rootUComponent:TryChangePage("Stage", 0)

	self.pageState = 0

	self.view.trainFinishRewardUList:SetList({})
	ClientTextUtils.setText(self.view.btnConfirmUText, pg.getGameString("TOWER_FAST_TRAIN_CONFIRM"))
	ClientTextUtils.setText(self.view.btnCancelUText, pg.getGameString("TOWER_FAST_TRAIN_CANCEL"))
	self:refreshTimesSelector()
	self:refreshCost()
end

function TowerFastTrainCtrl:onTicketNotEnough()
	local title = pg.getGameString("TOWER_FAST_TRAIN_TICKET_NOT_ENOUGH_TITLE")
	local desc = pg.getGameString("TOWER_FAST_TRAIN_TICKET_NOT_ENOUGH_DESC")

	pg.global.showConfirmMsgRaw(title, desc, function()
		self:hide()
		pg.global.ui.towerLevelDetail:hide()
		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
			shopTags = {
				11
			},
			sourcePanel = UIConst.UI_ID_TOWER_FAST_TRAIN
		})
	end)
end

function TowerFastTrainCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerFastTrainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerFastTrainCtrl:onShow()
	self:refreshCost()
end

function TowerFastTrainCtrl:onHide()
	return
end

return TowerFastTrainCtrl
