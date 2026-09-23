-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformTopLogoCarBoard.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")

M.CONFIG = PlatformDisplayNameConfig.UI_Node_Home_CampingCar_Announcement

function M.getHomeOwnerPlayerInfo(uid)
	if string.isNilOrEmpty(uid) or not pg or not pg.game or not pg.game.chat or not pg.game.chat.getPlayerInfo then
		return nil
	end

	return pg.game.chat:getPlayerInfo(uid)
end

function M.bindHomeCarBoardName(board, ownerUid, rawName)
	local ownerPlayerInfo = M.getHomeOwnerPlayerInfo(ownerUid)

	if string.isNilOrEmpty(rawName) or string.isNilOrEmpty(ownerUid) or ownerUid == pg.me.uid then
		return PlatformDisplayNameInjector.getDisplayName({
			playerInfo = ownerPlayerInfo,
			config = M.CONFIG,
			rawName = rawName
		})
	end

	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.TopLogoCarBoardName,
		uid = ownerUid,
		playerInfo = ownerPlayerInfo,
		rawText = rawName
	})

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = ownerPlayerInfo,
		config = M.CONFIG,
		rawName = displayText
	})
end

function M:refreshBoardName(ownerUid, rawName)
	PlatformDisplayNameInjector.enableRichText(self and self.txtName)

	return M.bindHomeCarBoardName(self, ownerUid, rawName)
end

return M
