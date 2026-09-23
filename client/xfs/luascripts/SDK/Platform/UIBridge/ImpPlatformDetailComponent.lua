-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformDetailComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformManagementDataHelper = require("Utils.PetManagementDataHelper")

function M.resolveSourcePlayerName(action, source, playerName, playerInfo)
	local displayPlayerName, isVisible, resolvedPlayerInfo = PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = source,
		playerInfo = playerInfo,
		rawText = playerName
	})
	local resolvedName = displayPlayerName or ""

	if isVisible ~= false and string.isNilOrEmpty(resolvedName) and type(resolvedPlayerInfo) == "table" then
		resolvedName = resolvedPlayerInfo.playerName or ""
	end

	return resolvedName
end

function M.refreshPetUtilSourcePlayerName(_, data, source, playerName, playerInfo)
	local source = PlatformManagementDataHelper.getPetSource(data.id)

	if not source or source == "" then
		return nil
	end

	return M.resolveSourcePlayerName(PlatformNameMaskService.Action.PetUtilSourceName, source, playerName, playerInfo)
end

function M.refreshDetailSourcePlayerName(_, data, source, playerName, playerInfo)
	local source = PlatformManagementDataHelper.getPetSource(data.id)

	if not source or source == "" then
		return nil
	end

	return M.resolveSourcePlayerName(PlatformNameMaskService.Action.PetDetailSourceName, source, playerName, playerInfo)
end

return M
