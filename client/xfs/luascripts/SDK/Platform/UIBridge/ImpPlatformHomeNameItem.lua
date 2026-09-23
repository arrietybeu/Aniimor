-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformHomeNameItem.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:renderItemName(item, param, rawName)
	if not string.isNilOrEmpty(param.ownerUid) then
		local playerInfo = param.playerInfo or pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(param.ownerUid) or nil
		local displayOwnerName = PlatformNameMaskService.getMaskedDisplayName({
			action = PlatformNameMaskService.Action.HomeNameTip,
			uid = param.ownerUid,
			playerInfo = playerInfo,
			rawText = param.ownerPlayerName or ""
		})

		return pg.getFormatText(pg.getGameString("HOMELANE_NAME"), displayOwnerName or "")
	end

	if not string.isNilOrEmpty(param.name) then
		local homeOwnerUid = param.homeOwnerUid or nil

		if not string.isNilOrEmpty(homeOwnerUid) and tostring(homeOwnerUid) ~= tostring(pg.me and pg.me.uid) then
			return PlatformNameMaskService.getMaskedDisplayName({
				action = PlatformNameMaskService.Action.HomeCampCustomName,
				uid = homeOwnerUid,
				playerInfo = param.playerInfo,
				rawText = rawName or param.name
			})
		end
	end

	return nil
end

return M
