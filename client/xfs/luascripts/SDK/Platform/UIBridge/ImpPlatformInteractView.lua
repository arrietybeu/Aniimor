-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformInteractView.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.isUnityNil(value)
	return value == nil or type(IsNil) == "function" and IsNil(value)
end

function M.getPlayerInfo(uid, rawName)
	local chatSystem = pg and pg.game and pg.game.chat or nil
	local playerInfo

	if chatSystem and chatSystem.getPlayerInfo and not string.isNilOrEmpty(uid) then
		playerInfo = chatSystem:getPlayerInfo(uid)
	end

	if type(playerInfo) == "table" then
		return playerInfo
	end

	return {
		uid = uid,
		playerName = rawName
	}
end

function M.findMaskTarget(styleInfo, actionText)
	local text = actionText or ""
	local candidates = {
		{
			name = styleInfo.targetPlayerName,
			uid = styleInfo.targetUid,
			playerInfo = styleInfo.targetPlayerInfo,
			action = PlatformNameMaskService.Action.InteractSwitchPlayerName
		},
		{
			name = styleInfo.petCustomName,
			uid = styleInfo.ownerUid or pg and pg.me and pg.me.uid,
			playerInfo = styleInfo.playerInfo,
			action = PlatformNameMaskService.Action.InteractSwitchPetName
		}
	}

	for _, candidate in ipairs(candidates) do
		local rawName = candidate.name or ""

		if not string.isNilOrEmpty(rawName) and string.find(text, rawName, 1, true) then
			return rawName, candidate.uid, candidate.playerInfo, candidate.action
		end
	end
end

function M.replaceFirstPlainText(source, target, replacement)
	local startIndex, endIndex = string.find(source or "", target or "", 1, true)

	if not startIndex then
		return source or ""
	end

	return string.sub(source, 1, startIndex - 1) .. tostring(replacement or "") .. string.sub(source, endIndex + 1)
end

function M:showSwitchCtrlText(styleInfo, actionText)
	if type(styleInfo) ~= "table" then
		return nil
	end

	local rawName, uid, playerInfo, action = M.findMaskTarget(styleInfo, actionText)

	if string.isNilOrEmpty(rawName) then
		return actionText
	end

	playerInfo = playerInfo or M.getPlayerInfo(uid, rawName)

	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName
	})

	return M.replaceFirstPlainText(actionText, rawName, displayName)
end

return M
