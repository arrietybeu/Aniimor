-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetBallInfo.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetBallData = require("Data.pet_ball_data")
local PetData = require("Data.pet_data")
local PetFeedItemData = require("Data.pet_feed_item_data")
local ItemConstSourceData = require("Data.item_const_source_data")
local PetBallInfo = class.LiteClass("PetBallInfo", CustomDict)

function PetBallInfo:getExpActionTotalRemainTime()
	local remainTime = 0
	local firstAction = #self.expActionList > 0 and self.expActionList[1]

	if firstAction then
		if self.expActionStatus == Const.PET_BALL.EXP_STATUS_INIT then
			remainTime = remainTime + firstAction:getRemainTime()
		elseif self.expActionStatus == Const.PET_BALL.EXP_STATUS_PAUSE then
			remainTime = remainTime + self.expNextRefreshTs
		elseif self.expActionStatus == Const.PET_BALL.EXP_STATUS_START then
			remainTime = remainTime + firstAction:getRemainTime(self.expNextRefreshTs - Time.secondCache)
		end
	end

	for i = 2, #self.expActionList do
		local actionInfo = self.expActionList[i]

		remainTime = actionInfo:getRemainTime()
	end

	return remainTime
end

function PetBallInfo:addExpAction(itemId, itemCount)
	local latestAction = #self.expActionList > 0 and self.expActionList[#self.expActionList]

	if latestAction and latestAction.itemId == itemId then
		latestAction.itemCount = latestAction.itemCount + itemCount
	else
		self.expActionList:insert(#self.expActionList + 1, {
			itemId = itemId,
			itemCount = itemCount
		})
	end

	if self.expActionStatus == Const.PET_BALL.EXP_STATUS_INIT then
		self.expActionStatus = Const.PET_BALL.EXP_STATUS_START
		self.expNextRefreshTs = Time.secondCache + Utils.getExpActionTime(itemId)
	end
end

function PetBallInfo:settleExpAction(player)
	if #self.expActionList == 0 then
		ALARM("settleExpAction empty list")

		self.expActionStatus = Const.PET_BALL.EXP_STATUS_INIT
		self.expNextRefreshTs = 0

		return
	end

	if self.expActionStatus ~= Const.PET_BALL.EXP_STATUS_START then
		ALARM("settleExpAction not in start")

		return
	end

	local petInfo = player.pets[self.petId]

	if petInfo == nil then
		ALARM("settleExpAction pet not found")

		return
	end

	local expTotalSettlte = 0
	local expMaxAdd = Utils.getPetExpMaxAdd(player, petInfo.id)
	local expPer = Utils.getPetBallExpNum(self.templateId, petInfo.level)
	local settleTime = Time.secondCache - self.expNextRefreshTs + Utils.getExpActionTime(self.expActionList[1].itemId)

	for i = 1, #self.expActionList do
		local actionInfo = self.expActionList[i]
		local interval, count = Utils.getExpActionTime(actionInfo.itemId), Utils.getExpActionCount(actionInfo.itemId)

		if interval == 0 or count == 0 then
			ALARM("config not found")

			break
		end

		if expMaxAdd <= expTotalSettlte or settleTime < interval then
			break
		end

		local maxSettltCount = math.min(actionInfo.itemCount * count - actionInfo.finishCount, math.ceil(expMaxAdd / expPer))
		local settleCount = lume.clamp(math.floor(settleTime / interval), 0, maxSettltCount)

		expTotalSettlte = expTotalSettlte + settleCount * expPer
		settleTime = settleTime - settleCount * interval
		actionInfo.finishCount = actionInfo.finishCount + settleCount
	end

	while #self.expActionList > 0 do
		local actionInfo = self.expActionList[1]
		local count = math.max(1, Utils.getExpActionCount(actionInfo.itemId))
		local removeItemCount = math.floor(actionInfo.finishCount / count)

		if removeItemCount < actionInfo.itemCount then
			actionInfo.itemCount = actionInfo.itemCount - removeItemCount
			actionInfo.finishCount = actionInfo.finishCount % count

			break
		end

		self.expActionList:remove(1)
	end

	if expMaxAdd <= expTotalSettlte then
		self:pauseExpAction(settleTime)
	else
		self:continueExpAction(settleTime)
	end

	player:addPetExp(petInfo.id, expTotalSettlte, ItemConstSourceData.ITEM_SOURCE_PETBALL)
	player.logger:debug("settleExpAction expTotalSettle=%d, expMaxAdd=%d, expPer=%d, remainSettleTime=%d", expTotalSettlte, expMaxAdd, expPer, settleTime, self:dumpExpAction(), player:repr())
end

function PetBallInfo:pauseExpAction(settleTime)
	if #self.expActionList == 0 then
		self.expActionStatus = Const.PET_BALL.EXP_STATUS_INIT
		self.expNextRefreshTs = 0

		return
	end

	local interval = Utils.getExpActionTime(self.expActionList[1].itemId)

	if settleTime == nil then
		settleTime = interval - (self.expNextRefreshTs - Time.secondCache)
		settleTime = math.max(0, settleTime)
	end

	self.expActionStatus = Const.PET_BALL.EXP_STATUS_PAUSE
	self.expNextRefreshTs = settleTime
end

function PetBallInfo:continueExpAction(settleTime)
	if #self.expActionList == 0 then
		self.expActionStatus = Const.PET_BALL.EXP_STATUS_INIT
		self.expNextRefreshTs = 0

		return
	end

	local interval = Utils.getExpActionTime(self.expActionList[1].itemId)

	if settleTime == nil then
		settleTime = self.expNextRefreshTs
		settleTime = math.min(settleTime, interval)
	end

	self.expActionStatus = Const.PET_BALL.EXP_STATUS_START
	self.expNextRefreshTs = Time.secondCache + interval - settleTime
end

function PetBallInfo:getClearExpActionPayback()
	local res = {}
	local addItemInfoToRet = ItemUtils.addItemInfoToRet
	local firstAction = #self.expActionList > 0 and self.expActionList[1]

	if firstAction then
		local itemId, itemCount = firstAction.itemId, firstAction.itemCount
		local pfidd = PetFeedItemData[itemId]
		local count = pfidd and pfidd.times or 1

		count = math.max(1, count)

		local usedCount = firstAction.finishCount + 1
		local remainItemCount = itemCount - math.ceil(usedCount / count)

		addItemInfoToRet(res, itemId, remainItemCount)
	end

	for i = 2, #self.expActionList do
		local actionInfo = self.expActionList[i]

		if actionInfo.finishCount == 0 then
			addItemInfoToRet(res, actionInfo.itemId, actionInfo.itemCount)
		else
			ALARM("应该只消耗第一个，规则改了？？")
		end
	end

	return res
end

function PetBallInfo:clearExpAction()
	self.expActionList = {}
	self.expActionStatus = Const.PET_BALL.EXP_STATUS_INIT
	self.expNextRefreshTs = 0
end

function PetBallInfo:dumpExpAction()
	return string.format("(PetBall: id=%s st=%d ts=%d action=%s)", self._name, self.expActionStatus, self.expNextRefreshTs, inspect(self.expActionList:getRawTable()))
end

function PetBallInfo:dumpPetStatic(player)
	local petInfo = player.pets[self.petId]

	if petInfo == nil then
		return string.format("(PetBall: id=%s petId=%s)", self._name, self.petId)
	else
		return string.format("(PetBall: id=%s petId=%s, stage=%d level=%d exp=%d expMaxAdd=%d)", self._name, self.petId, petInfo.stage, petInfo.level, petInfo.exp, Utils.getPetExpMaxAdd(player, petInfo.id))
	end
end

function PetBallInfo:isElementMatch(playerEnt, petId)
	local pbdd = PetBallData[self.templateId]
	local petInfo = playerEnt:getPetInfo(petId)

	if petInfo then
		local pdd = PetData[petInfo.templateId]

		for _, type in pairs(pbdd.fitElement or EMPTY_TABLE) do
			if pdd.elementType[type] then
				return true
			end
		end
	end

	return false
end

function PetBallInfo:addProduction(playerEnt, productionType, newProduction)
	local curProduction = self.productions[productionType]

	if curProduction then
		if curProduction.targetId ~= 0 and curProduction.targetId ~= newProduction.targetId then
			playerEnt.logger:error("petBallTimerRefresh addProduction targetId error", newProduction.targetId, curProduction.targetId, playerEnt:repr())
		else
			newProduction.value = newProduction.value + curProduction.value
		end
	end

	self.productions[productionType] = newProduction

	if productionType ~= Const.PET_BALL.PRODUCTION_EXP and productionType ~= Const.PET_BALL.PRODUCTION_EXP_SUB then
		playerEnt.logger:info("petBall updateProduction: type:%d info:%s", productionType, playerEnt:repr())
	end
end

function PetBallInfo:getCurItemActionId()
	for actionId, actionInfo in self.actions:item() do
		if actionInfo.actionType ~= Const.PET_BALL.ACTION_EXP then
			return actionId
		end
	end

	return nil
end

return PetBallInfo
