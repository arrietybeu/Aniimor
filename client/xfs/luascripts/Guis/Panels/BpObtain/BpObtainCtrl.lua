-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpObtain\\BpObtainCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpObtainCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BattlePassData = require("Data.event_battlepass_data")
local EventTaskData = require("Data.event_task_data")
local ItemData = require("Data.item_data")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local BpObtainCtrl = Class.LightClass("BpObtainCtrl", UICtrl)

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

BpObtainCtrl.messages = {}

function BpObtainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BpObtainCtrl:addListener()
	local view = self.view

	if view.btnBGClose then
		function view.btnBGClose.luaClick()
			self:dismiss()
		end
	end

	if view.btnGoTo then
		function view.btnGoTo.luaClick()
			if not ClientCashShopUtils.canOpenBattlePass() then
				return
			end

			if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
				PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

				return
			end

			pg.global.ui:open(UIConst.UI_ID_BP_PURCHASE)
			self:dismiss()
		end
	end

	if view.listItem then
		function view.listItem.luaRenderItem(button, _, data)
			LuaUIUtils.renderRewardItem(button, data, tostring(data.num or 1))
		end
	end

	if view.listItemExtra then
		function view.listItemExtra.luaRenderItem(button, _, data)
			LuaUIUtils.renderRewardItem(button, data, tostring(data.num or 1))
		end
	end
end

function BpObtainCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function BpObtainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function BpObtainCtrl:onShow()
	local view = self.view

	if view.txtTitle then
		ClientTextUtils.setText(view.txtTitle, pg.getGameString("BATTLEPASS_POPUP_TITLETEXT"))
	end

	if view.txtExtra then
		ClientTextUtils.setText(view.txtExtra, pg.getGameString("BATTLEPASS_POPUP_UNLOCKEDTEXT"))
	end

	if view.btnGoToName then
		ClientTextUtils.setText(view.btnGoToName, pg.getGameString("BATTLEPASS_POPUP_GOPOS"))
	end

	local info = self._openInfo

	if view.listItem then
		view.listItem:SetList(sortByQualityDesc(info and info.itemList or {}))
	end

	if view.listItemExtra then
		view.listItemExtra:SetList(sortByQualityDesc(self:_collectPayRewardsUpToCurrentLevel()))
	end
end

function BpObtainCtrl:_collectPayRewardsUpToCurrentLevel()
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return {}
	end

	local bpLevel = actData.bpLevel or 0

	if bpLevel <= 0 then
		return {}
	end

	local phase = actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]

	if not bpData then
		return {}
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(bpData.awardTaskGroupId)
	local payTasks = {}

	for _, taskId in ipairs(taskIds) do
		local cfg = EventTaskData[taskId]

		if cfg and cfg.actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardPay then
			payTasks[#payTasks + 1] = cfg
		end
	end

	table.sort(payTasks, function(a, b)
		return (a.sort or 1) < (b.sort or 1)
	end)

	local results = {}

	for i = 1, bpLevel do
		local cfg = payTasks[i]

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

function BpObtainCtrl:onHide()
	return
end

return BpObtainCtrl
