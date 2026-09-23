-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformTeamMatchTipComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local Const = require("Common.Const.Const")

function M:renderPlayerState(button, idx, data, rawName)
	if tostring(data.uid) == tostring(pg.me.uid) then
		return nil
	end

	local membersInfo = self.getCurrentMembersInfo and self:getCurrentMembersInfo() or {}
	local playerInfo = membersInfo[data.uid]

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.TeamMatchPlayerName,
		uid = data.uid,
		playerInfo = playerInfo,
		rawText = rawName or data.name or ""
	})
end

function M:confirmStateChanged(uid, memberData, rawName)
	if tostring(uid) == tostring(pg.me.uid) then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.TeamMatchRefuseName,
		uid = uid,
		playerInfo = memberData,
		rawText = rawName or ""
	})
end

return M
