-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientFriendComponent.lua

local M = {}
local EventConst = require("Const.EventConst")
local PlatformShellInviteService = require("SDK.Platform.PlatformShellInviteService")
local PlatformShellConst = require("Common.Const.PlatformShellConst")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

M.platformAttributes = {
	"platformUserId",
	"platformFamily",
	"platformDisplayName",
	"platformUGCSwitch"
}

local PSN_AUTH_CODE_FETCH_TIMEOUT_MS = 10000

local function syncCachedPsnAuthCode(self)
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetCachedPlatformAuthCode then
		return false
	end

	local authCode = PlatformBridgeLuaFacade.GetCachedPlatformAuthCode()

	if string.isNilOrEmpty(authCode) then
		return false
	end

	self:syncPsnAuthCode(authCode)

	return true
end

local function fetchAndSyncPsnAuthCode(self)
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.PlayStation then
		return false
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.FetchPlatformAuthorizationCode then
		return syncCachedPsnAuthCode(self)
	end

	PlatformBridgeLuaFacade.FetchPlatformAuthorizationCode(PSN_AUTH_CODE_FETCH_TIMEOUT_MS, function(ok, errCode, msg, _payload)
		if ok ~= true then
			print(string.format("[PSN_AUTH] FetchPlatformAuthorizationCode failed errCode=%s msg=%s", tostring(errCode), tostring(msg)))

			return
		end

		if not syncCachedPsnAuthCode(self) then
			print(string.format("[PSN_AUTH] FetchPlatformAuthorizationCode success but cached auth code empty"))
		end
	end)
end

function M.appendAttributesUnique(attributesList, attributes)
	if not attributesList then
		return
	end

	local existing = {}

	for _, attr in ipairs(attributesList) do
		existing[attr] = true
	end

	for _, attr in ipairs(attributes) do
		if not existing[attr] then
			table.insert(attributesList, attr)

			existing[attr] = true
		end
	end
end

function M:appendFriendQueryAttributes(attributesList)
	M.appendAttributesUnique(attributesList, M.platformAttributes)
end

function M:FriendService_onSpecialFriendSet(specialFriendId)
	local oldUid = pg.game.chat.specialFriendUId

	if pg.global and pg.global.eventEmitter then
		pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_VARIANT_TRIGGERED, {
			oldUid = oldUid or "",
			newUid = specialFriendId
		})
	end
end

function M:inviteEnterPhotoWorldByShellActivity(uid)
	local targetPlayerInfo = pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(uid) or nil
	local handled = PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.InviteEnterPhotoWorld, targetPlayerInfo) == true

	print(string.format("[PHOTO_SHELL] invite hook uid=%s hasTargetInfo=%s handled(shellPath)=%s", tostring(uid), tostring(targetPlayerInfo ~= nil), tostring(handled)))

	return handled
end

function M:onInit(avtDict)
	if not pg.me or self.uid ~= pg.me.uid then
		return
	end

	fetchAndSyncPsnAuthCode(self)
end

function M:RPC_SC_PsnAuthCodeRequired()
	if not pg.me or self.uid ~= pg.me.uid then
		return
	end

	fetchAndSyncPsnAuthCode(self)
end

function M:onPsnBlockStatesUpdated()
	local ImpPlatformSpeechSystem = require("SDK.Platform.UIBridge.ImpPlatformSpeechSystem")

	ImpPlatformSpeechSystem.syncCurrentSpeechRoomVoicePolicy()
end

return M
