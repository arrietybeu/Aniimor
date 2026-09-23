-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchBossNew\\CatchBossNewModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CatchBossNewModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local Utils = require("Common.Utils.Utils")
local castItemData = require("Data.cast_item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local lume = require("Core.Common.lume")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local LevelRewardLinkedData = require("Data.level_reward_linked_data")
local PetConfigData = require("Data.pet_config_data")
local CatchBossNewModel = Class.LightClass("CatchBossNewModel", UIModel)
local CHAMPION_BALL_ID = 110003
local SHINE_CHAMPION_BALL_ID = 110006

local function getLevelRewardConfig(bossEntity)
	if not bossEntity then
		return
	end

	return LevelRewardLinkedData[bossEntity.sandboxId]
end

local function getFreeBallIds()
	local ids = {}

	for itemId, enabled in pairs(PetConfigData.bossCatchFreeBall or EMPTY_TABLE) do
		if itemId and enabled == 1 then
			table.insert(ids, itemId)
		end
	end

	table.sort(ids)

	return ids
end

function CatchBossNewModel:buildBallInfo(bossEntity, itemId, options)
	if type(options) ~= "table" then
		options = {
			isFree = options == true
		}
	end

	local itemConfig = ItemData[itemId]

	if not itemConfig then
		return
	end

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]

	if not ballData or not ballData.canQuickCaptureInHand then
		return
	end

	local context = CatchProbContext.clientGet(bossEntity, itemId)

	return {
		itemId = itemId,
		icon = itemConfig.icon,
		name = itemConfig.itemName,
		count = ClientUtils.getItemCountById(itemId),
		prob = context and context.finalProb or 0,
		quality = itemConfig.quality or 0,
		isFree = options.isFree == true,
		isChampion = options.isChampion == true
	}
end

function CatchBossNewModel:getBossCapturePropInfos(bossEntity)
	local propList = {}
	local addedMap = {}
	local freeBallIds = getFreeBallIds() or {}

	for _, itemId in ipairs(freeBallIds) do
		if ClientCaptureUtils.checkBallCanThrow(itemId) then
			local itemInfo = self:buildBallInfo(bossEntity, itemId, {
				isFree = true
			})

			if itemInfo then
				propList[#propList + 1] = itemInfo
				addedMap[itemId] = true
			end
		end
	end

	local championOrder = {
		CHAMPION_BALL_ID,
		SHINE_CHAMPION_BALL_ID
	}

	for _, championId in ipairs(championOrder) do
		if not addedMap[championId] and ClientCaptureUtils.checkBallCanThrow(championId) then
			local championInfo = self:buildBallInfo(bossEntity, championId, {
				isChampion = true
			})

			if championInfo then
				propList[#propList + 1] = championInfo
				addedMap[championId] = true
			end
		end
	end

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, ItemConst.INV_TYPE_BALL)
	local normalBallList = {}

	if bag and bag.items then
		for _, packSlot in bag:items() do
			local item = LuaUIUtils.getItemClientInfoById(packSlot.id)
			local itemId = item and item.itemId

			if itemId and itemId ~= 0 and not addedMap[itemId] and ItemData[itemId] and ClientCaptureUtils.checkBallCanThrow(itemId) then
				local count = ClientUtils.getItemCountById(itemId)

				if count > 0 then
					local itemInfo = self:buildBallInfo(bossEntity, itemId)

					if itemInfo then
						normalBallList[#normalBallList + 1] = itemInfo
					end
				end
			end
		end
	end

	normalBallList = lume.sort(normalBallList, function(a, b)
		if a.prob == b.prob then
			return a.itemId < b.itemId
		end

		return a.prob > b.prob
	end)

	for _, itemInfo in ipairs(normalBallList) do
		propList[#propList + 1] = itemInfo
	end

	return propList
end

function CatchBossNewModel:getBossCaptureRewardInfos(bossEntity)
	local config = getLevelRewardConfig(bossEntity)
	local starTitle = pg and pg.me and pg.me.starTitle or 0
	local rewardId = config and config.periodRewardId and config.periodRewardId[starTitle]

	if not rewardId then
		return {}
	end

	return LuaUIUtils.getRewardItemByDropId(rewardId)
end

function CatchBossNewModel:getBossCaptureCostInfo(bossEntity)
	local config = getLevelRewardConfig(bossEntity)
	local cost = config and config.cost or PetConfigData.bossCatchDefaultCost

	if not cost or not cost[1] then
		return
	end

	local itemId = cost[1]
	local count = cost[2] or 0

	return {
		itemId = itemId,
		count = count,
		ownCount = ClientUtils.getItemCountById(itemId),
		icon = LuaUIUtils.getIconByItemId(itemId)
	}
end

return CatchBossNewModel
