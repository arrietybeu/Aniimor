-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformClientCashShopUtils.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.getChatPlayerInfo(uid)
	if string.isNilOrEmpty(uid) or not pg or not pg.game or not pg.game.chat or not pg.game.chat.getPlayerInfo then
		return nil
	end

	return pg.game.chat:getPlayerInfo(tostring(uid))
end

function M.resolveGiftReceiverName(uid, rawName)
	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.CashGiftReceiverName,
		uid = uid,
		playerInfo = M.getChatPlayerInfo(uid),
		rawText = rawName
	})
end

return M
