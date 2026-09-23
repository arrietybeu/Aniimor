-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformBossRushBattleResultCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.getPlayerInfo(uid, recordInfo, rawName)
	if type(recordInfo) == "table" then
		recordInfo.uid = recordInfo.uid or uid
		recordInfo.playerId = recordInfo.playerId or uid
		recordInfo.playerName = recordInfo.playerName or rawName

		return recordInfo
	end

	local chatSystem = pg and pg.game and pg.game.chat or nil

	if chatSystem and chatSystem.getPlayerInfo and uid ~= nil and tostring(uid) ~= "" then
		local cachedInfo = chatSystem:getPlayerInfo(tostring(uid))

		if type(cachedInfo) == "table" then
			return cachedInfo
		end
	end

	return {
		uid = uid,
		playerId = uid,
		playerName = rawName
	}
end

function M:getMaskedPlayerName(data, recordInfo, ent, rawName)
	local uid = ent and ent.uid or recordInfo and recordInfo.uid or data and data.uid
	local playerInfo = M.getPlayerInfo(uid, recordInfo, rawName)

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.BossRushChallengeResultMemberName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName or ""
	})
end

return M
