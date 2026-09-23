-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformBossRushChallengeCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.getPlayerInfo(uid, playerInfo, rawName)
	if type(playerInfo) == "table" then
		playerInfo.uid = playerInfo.uid or uid

		return playerInfo
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

function M.getPlayerInfoByEnt(ent)
	local uid = ent and ent.uid

	if string.isNilOrEmpty(uid) then
		return nil
	end

	local chatSystem = pg and pg.game and pg.game.chat or nil

	if not chatSystem or not chatSystem.getPlayerInfo then
		return nil
	end

	local playerInfo = chatSystem:getPlayerInfo(uid)

	if type(playerInfo) == "table" then
		return playerInfo
	end
end

function M:getMaskedEntDisplayName(ent, rawName)
	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.BossRushChallengeMemberName,
		uid = ent and ent.uid,
		playerInfo = M.getPlayerInfoByEnt(ent),
		rawText = rawName or ""
	})
end

function M:getMaskedPlayerDisplayName(uid, playerInfo, rawName)
	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.BossRushChallengeMemberName,
		uid = uid,
		playerInfo = M.getPlayerInfo(uid, playerInfo, rawName),
		rawText = rawName or ""
	})
end

return M
