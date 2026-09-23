-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformShopGiftReceiveCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")

function M:resolveGiverDisplayName(uid, rawName)
	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.MailGiftGiverName,
		uid = uid,
		rawText = rawName
	})

	return displayText
end

function M:resolveGiftBlessText(uid, playerInfo, rawText)
	if PlatformUGCService.isVisibleForPlayer == nil then
		return rawText
	end

	local visible = PlatformUGCService:isVisibleForPlayer(playerInfo)

	if visible == false then
		return ""
	end

	return rawText
end

return M
