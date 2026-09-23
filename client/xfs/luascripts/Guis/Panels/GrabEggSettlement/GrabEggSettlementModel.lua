-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggSettlement\\GrabEggSettlementModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("GrabEggSettlementModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggSettlementModel = Class.LightClass("GrabEggSettlementModel", UIModel)
local ItemConst = require("Common.Const.ItemConst")
local Time = require("Core.Common.Time")
local ItemEffectData = require("Data.item_effect_data")
local ItemData = require("Data.item_data")
local EggRankBaseData = require("Data.egg_rank_base_data")
local EggRankDailyBoxData = require("Data.egg_rank_daily_box_data")

function GrabEggSettlementModel:GetFallItemList()
	if not pg.me:hasEquipBag() then
		return {}
	end

	local packSlot = pg.me:getItemFromBagSlotIndex(ItemConst.ROB_EGG_EQUIP_SLOT.BAG, ItemConst.INV_TYPE_EQUIP_SLOTS)
	local itemId = packSlot and packSlot.id
	local effectData = ItemEffectData[itemId]
	local capacity = effectData.volume or 0
	local beginPos = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN
	local result = {}

	for i = beginPos, beginPos + capacity - 1 do
		local packSlot = pg.me:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_ROB_EGG)

		if packSlot then
			result[#result + 1] = packSlot.id
		end
	end

	table.sort(result, function(a, b)
		return ItemData[a].quality < ItemData[b].quality
	end)

	return result
end

function GrabEggSettlementModel:getDailyBoxStatus(levelInfo)
	local eggLv = levelInfo and levelInfo.eggLv
	local secEggLv = levelInfo and levelInfo.secEggLv
	local bigRank = eggLv and eggLv[2] or pg.me.eggLv or 1
	local smallRank = secEggLv and secEggLv[2] or pg.me.secEggLv or 1
	local rankCfg = EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]
	local acquired = pg.me.refreshCountDaily or 0
	local limit = rankCfg and rankCfg.boxUpLimit or 0

	return {
		acquired = acquired,
		limit = limit,
		isFull = rankCfg ~= nil and limit <= acquired
	}
end

function GrabEggSettlementModel:findSettlementRewardBox(boxId)
	local targetBox
	local targetAchievedTime = -1

	for _, box in ipairs(pg.me.rewardBoxList or EMPTY_TABLE) do
		if tonumber(box.id) == boxId then
			local achievedTime = tonumber(box.achievedTime) or 0

			if targetAchievedTime < achievedTime then
				targetBox = box
				targetAchievedTime = achievedTime
			end
		end
	end

	return targetBox
end

function GrabEggSettlementModel:getSettlementChestInfo(boxId, levelInfo)
	local dailyStatus = self:getDailyBoxStatus(levelInfo)

	boxId = tonumber(boxId) or 0

	local boxCfg = EggRankDailyBoxData[boxId]
	local isGranted = boxId > 0 and boxCfg ~= nil
	local rewardBox = isGranted and self:findSettlementRewardBox(boxId)

	if boxId > 0 and not boxCfg then
		logger:error("settlement chest config not found, boxId:%s", tostring(boxId))
	elseif isGranted and not rewardBox then
		logger:warn("settlement reward box not found, boxId:%s", tostring(boxId))
	end

	local quality = boxCfg and tonumber(boxCfg.quality) or 1

	quality = math.max(1, math.min(6, quality))

	return {
		isGranted = isGranted,
		icon = boxCfg and boxCfg.icon,
		quality = quality,
		openTimestamp = rewardBox and rewardBox.timestamp or Time.secondCache,
		acquired = dailyStatus.acquired,
		limit = dailyStatus.limit,
		isDailyFull = dailyStatus.isFull
	}
end

return GrabEggSettlementModel
