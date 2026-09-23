-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformMailNewComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")

M.CONFIG = PlatformDisplayNameConfig.UI_Pb_Chat_Mail_Details_Popup

function M.getGiftMailGiverUid(mailData)
	if not mailData.Params or not mailData.Params.giftInfo then
		return nil
	end

	local gifts = mailData.Params.giftInfo

	if type(gifts) == "string" then
		local ClientRepo = require("Core.Client.ClientRepo")

		gifts = ClientRepo.protoCodec:decode(gifts)
	end

	if gifts.customData and gifts.customData.giverUid then
		return tostring(gifts.customData.giverUid)
	end

	return nil
end

function M:getGiftMailGiverName(mailData, playerName)
	local giverUid = M.getGiftMailGiverUid(mailData)

	if string.isNilOrEmpty(giverUid) then
		return playerName
	end

	local playerInfo = pg.game.chat:getPlayerInfo(giverUid)

	if not playerInfo then
		return playerName
	end

	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.MailGiftGiverName,
		uid = giverUid,
		playerInfo = playerInfo,
		rawText = playerName
	})

	return displayName
end

function M:getGiftMailGiverDisplayName(mailData, giverName)
	local giverUid = M.getGiftMailGiverUid(mailData)

	if string.isNilOrEmpty(giverUid) then
		return giverName
	end

	local playerInfo = pg.game.chat:getPlayerInfo(giverUid)

	if not playerInfo then
		return giverName
	end

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = playerInfo,
		config = M.CONFIG,
		rawName = giverName
	})
end

return M
