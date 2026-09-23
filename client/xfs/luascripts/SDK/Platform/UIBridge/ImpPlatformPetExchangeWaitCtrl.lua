-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformPetExchangeWaitCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformPetNameMaskService = require("SDK.Platform.PlatformPetNameMaskService")

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

function M.resolvePetName(owner, options)
	if type(owner) ~= "table" or type(options) ~= "table" then
		return options and options.configName or ""
	end

	return PlatformPetNameMaskService.getMaskedDisplayPetName({
		action = PlatformPetNameMaskService.Action.PetExchangePetName,
		uid = options.uid,
		playerInfo = options.playerInfo,
		customName = options.customName,
		configName = options.configName
	})
end

function M:applyFriendPlayerNameMask(playerInfo, rawName)
	if type(playerInfo) ~= "table" then
		return nil
	end

	return M.resolvePlayerName(self, {
		uid = playerInfo.uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

function M:applyBottomBaseInfoMask(data)
	if type(data) ~= "table" or type(data.playerInfo) ~= "table" or type(data.info) ~= "table" then
		return
	end

	local uid = data.playerInfo.uid
	local playerName = M.resolvePlayerName(self, {
		uid = uid,
		playerInfo = data.playerInfo,
		rawText = data.playerInfo.playerName or data.info.playerName or ""
	})
	local petName = M.resolvePetName(self, {
		uid = uid,
		playerInfo = data.playerInfo,
		customName = data.info.petCustomName,
		configName = data.info.petConfigName or data.info.petName or ""
	})

	return {
		playerName = playerName,
		petName = petName
	}
end

return M
