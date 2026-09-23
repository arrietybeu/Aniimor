-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformPetExchangeSelectCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.isUnityNil(value)
	return value == nil or type(IsNil) == "function" and IsNil(value)
end

function M.getPlayerInfo(uid, fallbackName)
	local chatSystem = pg and pg.game and pg.game.chat or nil

	if chatSystem and chatSystem.getPlayerInfo and not string.isNilOrEmpty(uid) then
		local playerInfo = chatSystem:getPlayerInfo(uid)

		if type(playerInfo) == "table" then
			return playerInfo
		end
	end

	return {
		uid = uid,
		playerName = fallbackName
	}
end

function M.resolvePlayerName(owner, options)
	if type(owner) ~= "table" or type(options) ~= "table" then
		return options and options.rawText or ""
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = options.action or PlatformNameMaskService.Action.PetExchangePlayerName,
		uid = options.uid,
		playerInfo = options.playerInfo,
		rawText = options.rawText or ""
	})
end

function M:applyPlayerNameMask(rawName)
	if type(self.friendInfo) ~= "table" or not self.view then
		return nil
	end

	local uid = self.info and self.info.uid or self.friendInfo.uid

	return M.resolvePlayerName(self, {
		uid = uid,
		playerInfo = self.friendInfo,
		rawText = rawName or self.friendInfo.playerName or ""
	})
end

function M:applyExchangeTipNameMask(uid, rawName)
	if string.isNilOrEmpty(uid) then
		return rawName or ""
	end

	local playerInfo = M.getPlayerInfo(uid, rawName)

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.PetExchangeTipPlayerName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
