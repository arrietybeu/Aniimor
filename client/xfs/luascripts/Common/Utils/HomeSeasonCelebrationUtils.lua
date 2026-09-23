-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\HomeSeasonCelebrationUtils.lua

local CelebrationData = require("Data.home_season_celebration_data")
local CELEBRATION_STATE_IDLE = 0
local entryNpcFuncMenuIds = {}

for _, festival in pairs(CelebrationData) do
	if festival.entryNpcFuncMenuId then
		entryNpcFuncMenuIds[festival.entryNpcFuncMenuId] = true
	end
end

local HomeSeasonCelebrationUtils = {}

function HomeSeasonCelebrationUtils.isEntryNpcFuncMenu(funcMenuId)
	return entryNpcFuncMenuIds[funcMenuId] == true
end

function HomeSeasonCelebrationUtils.isEntryNpcFuncDisabled(space, funcMenuId)
	if not space or not space.homeSeasonCelebrationState then
		return false
	end

	if space.homeSeasonCelebrationState == CELEBRATION_STATE_IDLE then
		return false
	end

	local festival = CelebrationData[space.homeSeasonCelebrationFestivalId]

	return festival ~= nil and festival.entryNpcFuncMenuId == funcMenuId
end

return HomeSeasonCelebrationUtils
