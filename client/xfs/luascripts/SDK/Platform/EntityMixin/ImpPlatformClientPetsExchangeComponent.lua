-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientPetsExchangeComponent.lua

local M = {}
local EventConst = require("Common.Const.EventConst")
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformShellInviteService = require("SDK.Platform.PlatformShellInviteService")
local PlatformShellConst = require("Common.Const.PlatformShellConst")

function M:init()
	local emitter = pg.global and pg.global.eventEmitter

	if not emitter then
		return
	end

	self.platformShellInviteAutoAcceptHandler = self.platformShellInviteAutoAcceptHandler or function(payload)
		M.handlePlatformShellInviteAcceptSent(self, payload)
	end

	emitter:removeEventListener(EventConst.PLATFORM_SHELL_INVITE_AUTO_ACCEPT, self.platformShellInviteAutoAcceptHandler)
	emitter:addEventListener(EventConst.PLATFORM_SHELL_INVITE_AUTO_ACCEPT, self.platformShellInviteAutoAcceptHandler)
end

function M:destroy()
	local emitter = pg.global and pg.global.eventEmitter

	if emitter and self.platformShellInviteAutoAcceptHandler then
		emitter:removeEventListener(EventConst.PLATFORM_SHELL_INVITE_AUTO_ACCEPT, self.platformShellInviteAutoAcceptHandler)
	end

	self.platformShellInviteAutoAcceptHandler = nil
	self.pendingPlatformShellPetExchangeInvitorUid = nil
end

function M:handlePlatformShellInviteAcceptSent(payload)
	if type(payload) ~= "table" or payload.tokenType ~= PlatformShellConst.TokenType.InviteExchangePet or payload.inviteeUid ~= nil and tostring(payload.inviteeUid) ~= tostring(self.uid or "") then
		return
	end

	local invitorUid = payload.invitorUid or payload.inviterGameUid

	if string.isNilOrEmpty(invitorUid) then
		return
	end

	self.pendingPlatformShellPetExchangeInvitorUid = tostring(invitorUid)
end

function M:onStartPetExchangeSocial(socialInfo, isResume)
	local invitorUid = self.pendingPlatformShellPetExchangeInvitorUid

	if string.notNilOrEmpty(invitorUid) and socialInfo and socialInfo.players and socialInfo.players[invitorUid] then
		self.pendingPlatformShellPetExchangeInvitorUid = nil

		self:openPetExchangeSelectPage(invitorUid)
	end
end

function M:beforeSendPetExchangeInvite(inviteeUid)
	if PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation then
		return false
	end

	local playerInfo = pg.game.chat:getPlayerInfo(inviteeUid)

	return PlatformShellInviteService:sendPetExchangeInvite(playerInfo, inviteeUid) == true
end

function M:beforeRecvPetExchangeInvite(invitorUid)
	if PlatformCommunicationService:isLocalCommunicationBlocked(PlatformCommunicationService.Channel.Text) then
		self:replyPetExchangeInvite(invitorUid, false, {})

		return true
	end

	return false
end

return M
