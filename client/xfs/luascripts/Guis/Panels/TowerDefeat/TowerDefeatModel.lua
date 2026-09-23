-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerDefeat\\TowerDefeatModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local TowerDefeatModel = Class.LightClass("TowerDefeatModel", UIModel)
local Const = require("Common.Const.Const")
local CatchRogueLevelReverseData = require("Data.catch_rogue_level_reverse_data")

function TowerDefeatModel:getCatchRogueFailCondition(gameId, failReason)
	local result = {}
	local curFloorId = pg.me.catchRogueInfo.floorId
	local totalFloor = #CatchRogueLevelReverseData[gameId]
	local failKey = ""

	if failReason == Const.CatchRogue.SETTLE_TIMEOUT then
		failKey = "CATCH_ROGUE_DEFEAT_TIME"
	elseif failReason == Const.CatchRogue.SETTLE_PLAYER_DIED then
		failKey = "CATCH_ROGUE_DEFEAT_DIE"
	end

	local killNum, totalNum = pg.me:getCurPuppetFinishCount()

	table.insert(result, {
		hasComplete = false,
		desc = string.format(pg.getGameString("CATCH_ROGUE_DEFEAT_GOAT"), killNum, totalNum)
	})

	return result
end

return TowerDefeatModel
