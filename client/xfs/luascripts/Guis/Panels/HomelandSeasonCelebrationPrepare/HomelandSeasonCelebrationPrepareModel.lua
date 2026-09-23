-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationPrepare\\HomelandSeasonCelebrationPrepareModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomelandSeasonCelebrationPrepareModel = Class.LightClass("HomelandSeasonCelebrationPrepareModel", UIModel)

function HomelandSeasonCelebrationPrepareModel:getPlayerList()
	local result = {}
	local playerIds = {}

	local function addPlayer(entity)
		if not entity or not entity.uid or playerIds[entity.uid] then
			return
		end

		local playerInfo = pg.game.chat:getPlayerInfo(entity.uid)

		result[#result + 1] = {
			playerId = entity.uid,
			uid = entity.uid,
			level = playerInfo and playerInfo.level or entity.level or 1,
			entity = entity
		}
		playerIds[entity.uid] = true
	end

	addPlayer(pg.me)

	for _, entity in pairs(pg.global.entityMgr.getAllPlayers() or EMPTY_TABLE) do
		addPlayer(entity)
	end

	table.sort(result, function(left, right)
		return tostring(left.playerId) < tostring(right.playerId)
	end)

	return result
end

return HomelandSeasonCelebrationPrepareModel
