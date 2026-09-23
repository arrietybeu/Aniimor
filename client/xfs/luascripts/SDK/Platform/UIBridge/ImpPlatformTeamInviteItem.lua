-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformTeamInviteItem.lua

local M = {}
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlatformTextMaskService = require("SDK.Platform.PlatformTextMaskService")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")

M.CONFIG = PlatformDisplayNameConfig.UI_Node_Popup_FriendInvent_Mini

function M.resolveInvitePlayerUid(data)
	local playerInfo = data and data.playerInfo or nil

	return playerInfo and (playerInfo.uid or playerInfo.playerId) or data and data.playerId or nil
end

function M.isSelfUid(uid)
	return not string.isNilOrEmpty(uid) and pg and pg.me and tostring(uid) == tostring(pg.me.uid)
end

M.INVITE_NAME_REF_NAMES = {
	"playerNameUText",
	"nameCoverUSDFText",
	"nameisChangeUSDFText"
}

function M.enableInviteNameRichText(objectReference)
	return PlatformDisplayNameInjector.enableRichTextRefs(objectReference, M.INVITE_NAME_REF_NAMES)
end

function M:renderTeamInvite(button, index, data, rawName)
	local inviteUid = M.resolveInvitePlayerUid(data)

	if string.isNilOrEmpty(inviteUid) or M.isSelfUid(inviteUid) then
		return nil
	end

	self._ugcInviteNameState = self._ugcInviteNameState or {}
	self._ugcInviteNoticeState = self._ugcInviteNoticeState or {}

	local invitePlayerInfo = data.playerInfo
	local objectReference = button:GetComponent("ObjectReference")

	M.enableInviteNameRichText(objectReference)

	local playerNameUText = objectReference:GetRefValue("playerNameUText")
	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.TeamInvitePlayerName,
		uid = inviteUid,
		playerInfo = invitePlayerInfo,
		rawText = rawName or invitePlayerInfo and invitePlayerInfo.playerName or ""
	})

	self._ugcInviteNameState[inviteUid] = displayText

	if data.tIndex == 0 and data.noticeMsg and data.noticeMsg ~= "" then
		local noticeUText = objectReference:GetRefValue("noticeUText")

		if noticeUText then
			local noticeState = self._ugcInviteNoticeState[inviteUid]

			if type(noticeState) == "string" then
				ClientTextUtils.setText(noticeUText, noticeState)
			elseif noticeState ~= "pending" then
				self._ugcInviteNoticeState[inviteUid] = "pending"

				PlatformTextMaskService:bindText({
					action = "ugc_team_invite_notice_msg",
					uid = inviteUid,
					playerInfo = invitePlayerInfo,
					rawText = data.noticeMsg,
					isAlive = function()
						return self.uWidget ~= nil and button ~= nil and button.gameObject ~= nil
					end,
					apply = function(displayText, isVisible)
						ClientTextUtils.setText(noticeUText, displayText)

						if isVisible ~= nil then
							self._ugcInviteNoticeState[inviteUid] = displayText
						end
					end
				})
			end
		end
	end

	displayText = PlatformDisplayNameInjector.getDisplayName({
		playerInfo = invitePlayerInfo,
		config = M.CONFIG,
		rawName = displayText
	})

	return displayText
end

return M
