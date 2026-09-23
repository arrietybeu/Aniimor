-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpBuyLv\\BpBuyLvCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local BattlePassData = require("Data.event_battlepass_data")
local EventTaskData = require("Data.event_task_data")
local ItemData = require("Data.item_data")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local CYCLE_LEVEL_JUMP = 20
local BpBuyLvCtrl = Class.LightClass("BpBuyLvCtrl", UICtrl)

BpBuyLvCtrl.messages = {}

function BpBuyLvCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BpBuyLvCtrl:addListener()
	local view = self.view

	if view.btnClose then
		function view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if view.btnBGClose then
		function view.btnBGClose.luaClick()
			self:dismiss()
		end
	end

	if view.btnCancel then
		function view.btnCancel.luaClick()
			self:dismiss()
		end
	end

	if view.btnConfirm then
		function view.btnConfirm.luaClick()
			self:_tryBuy()
		end
	end

	if view.btnArrow then
		function view.btnArrow.luaClick()
			if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
				PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

				return
			end

			pg.global.ui:open(UIConst.UI_ID_BP_PURCHASE, nil, function()
				self:dismiss()
			end)
		end
	end

	if view.numSelector then
		function view.numSelector.luaValueChanged(value)
			if self._isCycleRewardStage then
				self:_updateCycleSelectorRange(value)
			end

			self:_refreshByCount(value)
		end
	end

	if view.listUList then
		function view.listUList.luaRenderItem(button, _, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end

	if view.listUList2 then
		function view.listUList2.luaRenderItem(button, _, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end

	if view.listExUList then
		function view.listExUList.luaRenderItem(button, _, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end

	if view.listCurrencyUList then
		function view.listCurrencyUList.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local countUText = objectReference:GetRefValue("countUText")

			if iconUImage then
				iconUImage.url = data.icon
			end

			if countUText then
				ClientTextUtils.setText(countUText, tostring(data.ownNum))
			end

			button:TryChangePage("Quality", data.quality or 0)

			button.enabledTooltip = true
			button.tooltipMode = 1

			function button.luaRenderTooltip(_, cmp)
				LuaUIUtils.refreshItemInfo(cmp, {
					fromParamCount = true,
					id = data.id,
					itemCount = data.ownNum,
					targetRect = button
				}, button)
			end
		end
	end
end

function BpBuyLvCtrl:_getNormalLevelLimit()
	return math.max(1, math.floor(tonumber(SysConfigData.BATTLE_PASS_LEVEL_UP_MAX) or 1))
end

function BpBuyLvCtrl:_getLoopLevelLimit()
	local normalLevelLimit = self:_getNormalLevelLimit()
	local loopLevelLimit = math.floor(tonumber(SysConfigData.LOOP_LEVEL_LIMITS) or normalLevelLimit)

	return math.max(normalLevelLimit, loopLevelLimit)
end

function BpBuyLvCtrl:_getCurrentLevelLimit()
	if self._isCycleRewardStage then
		return self:_getLoopLevelLimit()
	end

	return self:_getNormalLevelLimit()
end

function BpBuyLvCtrl:_getMaxBuyCount()
	return math.max(0, self:_getCurrentLevelLimit() - (self._bpLevel or 0))
end

function BpBuyLvCtrl:_showLevelMaxTip()
	pg.global.showBubbleMessageById(NoticeDef.ERROR_ACTIVITY_BP_LV_MAX)
end

function BpBuyLvCtrl:_tryBuy()
	local view = self.view
	local maxBuyCount = self:_getMaxBuyCount()

	if maxBuyCount <= 0 then
		self:_showLevelMaxTip()

		return
	end

	local count = view.numSelector and view.numSelector.value or 1

	count = math.min(maxBuyCount, math.max(1, math.floor(tonumber(count) or 1)))

	local targetLevel = (self._bpLevel or 0) + count
	local totalCost = (self._costPerLevel or 0) * count
	local expPerLevel = SysConfigData.BATTLE_PASS_LEVEL_UP_EXP or 0
	local ownNum = 0

	if self._costItemId and self._costItemId > 0 then
		local itemInfo = LuaUIUtils.getItemInfoById(self._costItemId)

		ownNum = itemInfo and itemInfo.ownNum or 0
	end

	if ownNum < totalCost then
		RechargeUtils.openQuickPay({
			itemId = self._bpData and self._bpData.levelItemId,
			itemNum = count * expPerLevel,
			needCount = totalCost,
			currencyID = self._costItemId,
			buyCallBack = function()
				self:_tryBuy()
			end
		})

		return
	end

	local costIcon = LuaUIUtils.getItemShowText(self._costItemId)
	local desc = pg.getFormatText(pg.getGameString("BP_BUY_LEVEL"), costIcon, totalCost, count)

	pg.global.ui.commonUseConfirm:open({
		type = 1,
		muteCheckEnough = true,
		hideCurrency = 1,
		title = pg.getGameString("SHOP_BUY_READY"),
		tipTop = desc,
		data = {
			{
				self._bpData and self._bpData.levelItemId,
				count * expPerLevel,
				hideOwnNum = true,
				ownNum = 1
			}
		},
		confirmCb = function()
			self:_doBuyLevel(targetLevel)
		end
	})
end

function BpBuyLvCtrl:_doBuyLevel(targetLevel)
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	self._bpLevel = actData.bpLevel or 0
	self._isCycleRewardStage = actData.unlockCycleReward == 1

	if type(targetLevel) ~= "number" or targetLevel > self:_getCurrentLevelLimit() then
		self:_showLevelMaxTip()

		return
	end

	if targetLevel <= self._bpLevel then
		return
	end

	pg.me:serverMsg("RPC_CS_BattlePassBuyBpLevel", targetLevel, function(resCode)
		if resCode == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.BATTLEPASS_LEVEL_UP, {
				bpLevel = targetLevel
			})
		end
	end)
	self:dismiss()
end

function BpBuyLvCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function BpBuyLvCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function BpBuyLvCtrl:_updateCycleSelectorRange(value)
	local numSelector = self.view and self.view.numSelector

	if not numSelector then
		return
	end

	local maxBuyCount = self:_getMaxBuyCount()

	if maxBuyCount <= 0 then
		return
	end

	value = math.min(maxBuyCount, math.max(1, value))

	numSelector:SetMinValueWithoutNotify(math.max(1, value - CYCLE_LEVEL_JUMP))
	numSelector:SetMaxValueWithoutNotify(math.min(maxBuyCount, value + CYCLE_LEVEL_JUMP))
end

function BpBuyLvCtrl:_setupCycleSelector()
	local numSelector = self.view and self.view.numSelector

	if not numSelector then
		return
	end

	local objectReference = numSelector.transform:GetComponent("ObjectReference")
	local btnMinNum = objectReference:GetRefValue("btnMinNum")
	local btnMaxNum = objectReference:GetRefValue("btnMaxNum")
	local minNumTxt = objectReference:GetRefValue("minNumTxt")
	local maxNumTxt = objectReference:GetRefValue("maxNumTxt")

	if btnMinNum then
		function btnMinNum.luaClick()
			numSelector.value = math.max(1, numSelector.value - CYCLE_LEVEL_JUMP)
		end
	end

	if btnMaxNum then
		function btnMaxNum.luaClick()
			numSelector.value = math.min(self:_getMaxBuyCount(), numSelector.value + CYCLE_LEVEL_JUMP)
		end
	end

	local maxBuyCount = self:_getMaxBuyCount()

	numSelector:SetAllValue(1, 1, math.max(1, math.min(maxBuyCount, 1 + CYCLE_LEVEL_JUMP)), 1, true)
	self:_updateCycleSelectorRange(1)

	if minNumTxt then
		ClientTextUtils.setText(minNumTxt, "-" .. CYCLE_LEVEL_JUMP)
	end

	if maxNumTxt then
		ClientTextUtils.setText(maxNumTxt, "+" .. CYCLE_LEVEL_JUMP)
	end
end

function BpBuyLvCtrl:onShow()
	local view = self.view
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	local bpLevel = actData.bpLevel or 0
	local bpGear = actData.bpGear or 0
	local phase = actData.activityBase and actData.activityBase.activityPhase

	self._bpData = phase and BattlePassData[phase]
	self._bpLevel = bpLevel
	self._bpGear = bpGear
	self._isCycleRewardStage = actData.unlockCycleReward == 1

	if view.rootUComponent then
		view.rootUComponent:TryChangePage("Kind", bpGear >= ActivityConst.BattlePassGear.Pay1 and 1 or 0)
	end

	if view.txtTitle then
		ClientTextUtils.setText(view.txtTitle, pg.getGameString("BATTLEPASS_BUYLEVEL"))
	end

	if view.txtBtnConfirm then
		ClientTextUtils.setText(view.txtBtnConfirm, pg.getGameString("BATTLEPASS_BUYLEVEL_CONFIRM"))
	end

	if view.txtBtnCancel then
		ClientTextUtils.setText(view.txtBtnCancel, pg.getGameString("BATTLEPASS_BUYLEVEL_CANCEL"))
	end

	if view.txtGetTitle then
		ClientTextUtils.setText(view.txtGetTitle, pg.getGameString("BATTLEPASS_BUYLEVEL_PAID1"))
	end

	if view.txtGetTitle2 then
		ClientTextUtils.setText(view.txtGetTitle2, pg.getGameString("BATTLEPASS_BUYLEVEL_PAID1"))
	end

	if view.txtGetExTitle then
		ClientTextUtils.setText(view.txtGetExTitle, pg.getGameString("BATTLEPASS_BUYLEVEL_PAID2"))
	end

	local purchaseCfg = SysConfigData.BATTLE_PASS_LEVEL_UP_PURCHASE or {}
	local costItemId = purchaseCfg[1] or 0

	self._costItemId = costItemId
	self._costPerLevel = purchaseCfg[2] or 0

	if view.imgCostIcon and costItemId > 0 then
		view.imgCostIcon.url = LuaUIUtils.getIconByItemId(costItemId)
	end

	if view.listCurrencyUList and costItemId > 0 then
		local itemInfo = LuaUIUtils.getItemInfoById(costItemId)

		if itemInfo then
			view.listCurrencyUList:SetList({
				itemInfo
			})
		end
	end

	local maxBuyCount = self:_getMaxBuyCount()

	if view.numSelector then
		view.numSelector:TryChangePage("Type", self._isCycleRewardStage and 1 or 0)

		if self._isCycleRewardStage then
			self:_setupCycleSelector()
		else
			view.numSelector:SetAllValue(1, 1, math.max(1, maxBuyCount), 1, true)
		end
	end

	if view.btnConfirm then
		view.btnConfirm.interactable = maxBuyCount > 0
	end

	self:_refreshByCount(math.min(1, maxBuyCount))
end

local function mergeItems(items)
	local merged = {}
	local order = {}

	for _, item in ipairs(items) do
		local key = item.id and tostring(item.id) or "pet_" .. tostring(item.petId)

		if merged[key] then
			merged[key].num = (merged[key].num or 0) + (item.num or 0)
		else
			local copy = {}

			for k, v in pairs(item) do
				copy[k] = v
			end

			merged[key] = copy
			order[#order + 1] = key
		end
	end

	local result = {}

	for _, key in ipairs(order) do
		result[#result + 1] = merged[key]
	end

	return result
end

local function getItemQuality(item)
	if item and item.id then
		local cfg = ItemData[item.id]

		if cfg and cfg.quality then
			return cfg.quality
		end
	end

	return 0
end

local function sortByQualityDesc(items)
	local indexed = {}

	for i, item in ipairs(items) do
		indexed[i] = {
			item = item,
			idx = i,
			quality = getItemQuality(item)
		}
	end

	table.sort(indexed, function(a, b)
		if a.quality ~= b.quality then
			return a.quality > b.quality
		end

		return a.idx < b.idx
	end)

	local sorted = {}

	for i, v in ipairs(indexed) do
		sorted[i] = v.item
	end

	return sorted
end

function BpBuyLvCtrl:_refreshByCount(count)
	local view = self.view
	local bpLevel = self._bpLevel or 0
	local bpGear = self._bpGear or 0

	count = math.min(self:_getMaxBuyCount(), math.max(0, math.floor(tonumber(count) or 0)))

	if view.txtLvUp then
		ClientTextUtils.setText(view.txtLvUp, pg.getFormatText(pg.getGameString("BATTLEPASS_BUYLEVEL_AIM"), bpLevel + count))
	end

	if view.txtCostNum then
		local totalCost = (self._costPerLevel or 0) * count
		local ownNum = 0

		if self._costItemId and self._costItemId > 0 then
			local itemInfo = LuaUIUtils.getItemInfoById(self._costItemId)

			ownNum = itemInfo and itemInfo.ownNum or 0
		end

		local text = tostring(totalCost)

		self.notEnough = ownNum < totalCost

		if self.notEnough then
			text = pg.getFormatText(pg.getGameString("BATTLEPASS_TIPS"), totalCost)
		end

		ClientTextUtils.setText(view.txtCostNum, text)
	end

	local freeRewards, payRewardsNew, payRewardsAll = self:_collectRewards(bpLevel, count)

	if view.listUList then
		if bpGear >= ActivityConst.BattlePassGear.Pay1 then
			local combined = {}

			for _, v in ipairs(freeRewards) do
				combined[#combined + 1] = v
			end

			for _, v in ipairs(payRewardsNew) do
				combined[#combined + 1] = v
			end

			view.listUList2:SetList(sortByQualityDesc(mergeItems(combined)))
		else
			view.listUList:SetList(sortByQualityDesc(freeRewards))
		end
	end

	if view.listExUList then
		view.listExUList:SetList(sortByQualityDesc(payRewardsAll))
	end
end

function BpBuyLvCtrl:_collectLoopRewards(rewardIds, fromLevel, toLevel)
	local results = {}
	local rewardCount = rewardIds and #rewardIds or 0

	if rewardCount == 0 then
		return results
	end

	local bpMaxLevel = SysConfigData.BATTLE_PASS_LEVEL_UP_MAX or 0

	for level = fromLevel, toLevel do
		local rewardIndex = (level - bpMaxLevel - 1) % rewardCount + 1
		local rewardId = rewardIds[rewardIndex]

		if rewardId and rewardId > 0 then
			local items = LuaUIUtils.getRewardItemByDropId(rewardId)

			if items then
				for _, item in ipairs(items) do
					results[#results + 1] = item
				end
			end
		end
	end

	return mergeItems(results)
end

function BpBuyLvCtrl:_collectRewards(bpLevel, count)
	local bpData = self._bpData

	if not bpData then
		return {}, {}, {}
	end

	local targetLevel = bpLevel + count

	if self._isCycleRewardStage then
		local bpMaxLevel = SysConfigData.BATTLE_PASS_LEVEL_UP_MAX or 0
		local freeRewards = self:_collectLoopRewards(bpData.freeLoopReward, bpLevel + 1, targetLevel)
		local payRewardsNew = self:_collectLoopRewards(bpData.advancedLoopReward, bpLevel + 1, targetLevel)
		local payRewardsAll = self:_collectLoopRewards(bpData.advancedLoopReward, bpMaxLevel + 1, targetLevel)

		return freeRewards, payRewardsNew, payRewardsAll
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(bpData.awardTaskGroupId)
	local freeTasks, payTasks = {}, {}

	for _, taskId in ipairs(taskIds) do
		local cfg = EventTaskData[taskId]

		if cfg then
			if cfg.actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardFree then
				freeTasks[#freeTasks + 1] = cfg
			elseif cfg.actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardPay then
				payTasks[#payTasks + 1] = cfg
			end
		end
	end

	table.sort(freeTasks, function(a, b)
		return (a.sort or 1) < (b.sort or 1)
	end)
	table.sort(payTasks, function(a, b)
		return (a.sort or 1) < (b.sort or 1)
	end)

	local function collectFromTasks(tasks, fromLevel, toLevel)
		local results = {}

		for i = fromLevel, toLevel do
			local cfg = tasks[i]

			if cfg and cfg.award then
				local items = LuaUIUtils.getRewardItemByDropId(cfg.award)

				if items then
					for _, item in ipairs(items) do
						results[#results + 1] = item
					end
				end
			end
		end

		return mergeItems(results)
	end

	local freeRewards = collectFromTasks(freeTasks, bpLevel + 1, targetLevel)
	local payRewardsNew = collectFromTasks(payTasks, bpLevel + 1, targetLevel)
	local payRewardsAll = collectFromTasks(payTasks, 1, targetLevel)

	return freeRewards, payRewardsNew, payRewardsAll
end

function BpBuyLvCtrl:onHide()
	return
end

return BpBuyLvCtrl
