-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformInteractUIComponent.lua

local M = {}
local Utils = require("Common.Utils.Utils")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.getEntityByUnitRoot(unitRoot)
	if type(unitRoot) ~= "table" then
		return nil
	end

	if unitRoot.globalId and pg and pg.getEntityByGlobalId then
		return pg.getEntityByGlobalId(unitRoot.globalId)
	end

	if type(unitRoot.getEnt) == "function" then
		return unitRoot:getEnt()
	end
end

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

function M.findMultInteractPlayerName(data, actionText)
	if type(data) ~= "table" or type(Utils.isPlayer) ~= "function" then
		return nil
	end

	local ent = M.getEntityByUnitRoot(data.unitRoot)

	if not Utils.isPlayer(ent) then
		return nil
	end

	local rawName = ent.playerName or ""

	if string.isNilOrEmpty(rawName) or not string.find(actionText or "", rawName, 1, true) then
		return nil
	end

	return rawName, ent.uid, M.getPlayerInfo(ent.uid, rawName)
end

function M.replaceFirstPlainText(source, target, replacement)
	local startIndex, endIndex = string.find(source or "", target or "", 1, true)

	if not startIndex then
		return source or ""
	end

	return string.sub(source, 1, startIndex - 1) .. tostring(replacement or "") .. string.sub(source, endIndex + 1)
end

function M:setupMultInteractBtnText(button, idx, data, actionText)
	if type(data) ~= "table" then
		return nil
	end

	local rawName, uid, playerInfo = M.findMultInteractPlayerName(data, actionText)

	if string.isNilOrEmpty(rawName) then
		return nil
	end

	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.InteractSwitchPlayerName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName
	})

	return M.replaceFirstPlainText(actionText, rawName, displayName)
end

return M
