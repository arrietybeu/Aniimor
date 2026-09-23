-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\SeasonUtils.lua

local SeasonUtils = {}
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")

function SeasonUtils.getCurrentSeasonId()
	local seasonStageInfo = Utils.getCurrentSeasonStage()

	if Utils.isSeasonStageInfoActive(seasonStageInfo) then
		return seasonStageInfo.seasonId, seasonStageInfo.stageId
	end

	return 0, 0
end

function SeasonUtils.getCurrentSeasonCoinId()
	local seasonStageInfo = Utils.getCurrentSeasonStage()

	if Utils.isSeasonStageInfoActive(seasonStageInfo) then
		return seasonStageInfo.seasonCoinId or 0, seasonStageInfo.seasonId, seasonStageInfo.stageId
	end

	return 0, 0, 0
end

function SeasonUtils.convertUniversalCoin(itemId)
	if itemId ~= ItemConst.ITEM_SPECIAL_MONEY_BADGE then
		return itemId, 0, 0
	end

	local currentSeasonCoinId, seasonId, stageId = SeasonUtils.getCurrentSeasonCoinId()

	if currentSeasonCoinId and currentSeasonCoinId > 0 then
		return currentSeasonCoinId, seasonId, stageId
	end

	return 0, 0, 0
end

return SeasonUtils
