-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformInteractionUnitPlayerFunc.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.getPlayerInfo(ent)
	local uid = ent and ent.uid

	if string.isNilOrEmpty(uid) then
		return nil
	end

	local playerInfo = pg.game.chat:getPlayerInfo(uid)

	if type(playerInfo) == "table" then
		return playerInfo
	end
end

function M:getPlayerDisplayName(ent, rawName)
	if string.isNilOrEmpty(rawName) then
		return rawName
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.InteractSwitchPlayerName,
		uid = ent and ent.uid,
		playerInfo = M.getPlayerInfo(ent),
		rawText = rawName
	})
end

return M
