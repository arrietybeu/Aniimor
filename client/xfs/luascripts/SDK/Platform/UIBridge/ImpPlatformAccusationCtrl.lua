-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformAccusationCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

M.REPORT_SOURCE_HOMELAND = "homeland"

function M.getChatPlayerInfo(uid)
	if string.isNilOrEmpty(uid) or not pg or not pg.game or not pg.game.chat or not pg.game.chat.getPlayerInfo then
		return nil
	end

	return pg.game.chat:getPlayerInfo(uid)
end

function M:renderPlayerName(rawName)
	local uid = self._reportInfo and self._reportInfo.uid

	if string.isNilOrEmpty(uid) then
		uid = self._playerId
	end

	if string.isNilOrEmpty(uid) then
		return nil
	end

	local playerInfo = M.getChatPlayerInfo(uid)
	local action = self._reportSource == M.REPORT_SOURCE_HOMELAND and PlatformNameMaskService.Action.HomeCampCustomName or PlatformNameMaskService.Action.AccusationName

	return PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo and playerInfo.playerName or ""
	})
end

return M
