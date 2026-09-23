-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformCashGiftCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")

function M.getChatPlayerInfo(uid)
	if string.isNilOrEmpty(uid) or not pg or not pg.game or not pg.game.chat or not pg.game.chat.getPlayerInfo then
		return nil
	end

	return pg.game.chat:getPlayerInfo(tostring(uid))
end

function M.isUGCBlocked(playerInfo)
	if PlatformUGCService.isVisibleForPlayer == nil then
		return false
	end

	local visible = PlatformUGCService:isVisibleForPlayer(playerInfo)

	return visible == false
end

function M:_onConfirmGift()
	local uid = self._playerId
	local playerInfo = M.getChatPlayerInfo(uid)

	if M.isUGCBlocked(playerInfo) then
		PlatformNoticeUtils.showTextTipById(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	self:_onConfirmGiftImpl()
end

function M:resolveGiftReceiverName(uid, rawName)
	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.CashGiftReceiverName,
		uid = uid,
		rawText = rawName
	})

	return displayText
end

return M
