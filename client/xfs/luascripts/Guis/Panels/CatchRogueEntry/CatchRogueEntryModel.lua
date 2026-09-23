-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRogueEntry\\CatchRogueEntryModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRogueEntryModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local EventCatchRogueData = require("Data.event_catch_rogue_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local LimitData = require("Data.limit_data")
local ItemData = require("Data.item_data")
local CatchRogueEntryModel = Class.LightClass("CatchRogueEntryModel", UIModel)

function CatchRogueEntryModel:getCurCatchRogueInfo()
	if not pg.me then
		return
	end

	local gameId = pg.me:getCatchRogueCurGameId()

	return gameId
end

function CatchRogueEntryModel:getCatchRogueElementList(gameId)
	local data = CatchRoguePhaseData[gameId].recommendType
	local result = {}

	for i = 1, #data do
		table.insert(result, {
			element = data[i]
		})
	end

	return result
end

function CatchRogueEntryModel:getCatchRogueCommonPetList(gameId)
	local data = CatchRoguePhaseData[gameId].catchpetType
	local result = {}

	for i = 1, #data do
		table.insert(result, {
			templateId = data[i],
			gameId = gameId
		})
	end

	return result
end

function CatchRogueEntryModel:getCatchRogueRemainInfo(gameId)
	local cnt = CatchRoguePhaseData[gameId].trainCount
	local hasEnterCnt, totalCnt = pg.me.catchRogueInfo.statCntFinishGame or 0, cnt
	local remainCnt = totalCnt - hasEnterCnt

	return remainCnt, totalCnt
end

function CatchRogueEntryModel:getCatchRogueSpecialBall(gameId)
	local itemIds = CatchRoguePhaseData[gameId].gameBallType
	local result = {}

	if not itemIds then
		return result
	end

	for index, itemId in ipairs(itemIds) do
		local num = ItemUtils.getItemCountById(pg.me, itemId)
		local icon = ItemData[itemId].icon

		if num > 0 then
			table.insert(result, {
				isSpecial = true,
				tIndex = 0,
				itemId = itemId,
				icon = icon,
				num = num
			})
		else
			table.insert(result, {
				tIndex = 1
			})
		end
	end

	return result
end

function CatchRogueEntryModel:getCurCatchRogueCommonBall(gameId, tempCommonBallInfo)
	tempCommonBallInfo = tempCommonBallInfo or {}

	local ballTypeInfo = CatchRoguePhaseData[gameId].ballType
	local totalCnt = CatchRoguePhaseData[gameId].maxCount
	local curCnt = 0
	local result = {}

	if not ballTypeInfo or totalCnt <= 0 then
		return result, 0, 0
	end

	for index, info in ipairs(tempCommonBallInfo) do
		local itemId = info.itemId
		local cnt = info.cnt
		local icon = ItemData[itemId].icon

		curCnt = curCnt + cnt

		table.insert(result, {
			isSpecial = false,
			tIndex = 0,
			itemId = itemId,
			icon = icon,
			num = cnt
		})
	end

	local resumeGame = pg.me:isPlayCatchRogue()
	local totalGridCnt = #ballTypeInfo

	for i = 1, totalGridCnt - #result do
		if not resumeGame then
			table.insert(result, {
				tIndex = 1
			})
		else
			table.insert(result, {
				tIndex = 2
			})
		end
	end

	return result, curCnt, totalCnt
end

function CatchRogueEntryModel:getAllCatchRogueCommonBall(gameId, tempCommonBallInfo)
	tempCommonBallInfo = tempCommonBallInfo or {}

	local tempCommonBallCntMap = {}

	for index, info in ipairs(tempCommonBallInfo) do
		tempCommonBallCntMap[info.itemId] = info.cnt
	end

	local ballTypeInfo = CatchRoguePhaseData[gameId].ballType
	local totalCnt = CatchRoguePhaseData[gameId].maxCount
	local curCnt = 0
	local result = {}

	if not ballTypeInfo or totalCnt <= 0 then
		return result, 0, 0
	end

	for index, info in ipairs(ballTypeInfo) do
		local itemId = info[1]
		local limitNum = info[2]
		local icon = ItemData[itemId].icon
		local oriCnt = tempCommonBallCntMap[itemId] or 0
		local num = ItemUtils.getItemCountById(pg.me, itemId)

		curCnt = curCnt + oriCnt

		table.insert(result, {
			id = itemId,
			icon = icon,
			limitNum = limitNum,
			oriCnt = oriCnt,
			num = num
		})
	end

	return result, curCnt, totalCnt
end

function CatchRogueEntryModel:getCatchRoguePetList(gameId, tempPetInfo)
	tempPetInfo = tempPetInfo or {}

	local result = {}
	local totalCnt = 4

	for index, petId in ipairs(tempPetInfo) do
		local petInfo = pg.me:getPetInfo(petId)

		table.insert(result, {
			petId = petId,
			templateId = petInfo.templateId,
			petInfo = petInfo
		})
	end

	local resumeGame = pg.me:isPlayCatchRogue()

	for i = 1, totalCnt - #result do
		if not resumeGame then
			table.insert(result, {
				tIndex = 1
			})
		else
			table.insert(result, {
				tIndex = 2
			})
		end
	end

	return result
end

function CatchRogueEntryModel:getLackCommonCatchRogueBallInfo()
	local result = {}

	for index, itemId in ipairs(pg.me.catchRogueInfo:getValidBallList(pg.me)) do
		local cnt = pg.me.catchRogueInfo:getValidBallCount(pg.me, itemId)
		local hasCnt = ItemUtils.getItemCountById(pg.me, itemId)

		if hasCnt < cnt then
			table.insert(result, {
				itemId = itemId,
				num = cnt - hasCnt
			})
		end
	end

	return result
end

return CatchRogueEntryModel
