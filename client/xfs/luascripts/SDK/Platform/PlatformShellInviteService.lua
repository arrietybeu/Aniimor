-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformShellInviteService.lua

local IDManager = require("Core.Common.IDManager")
local logger = require("SDK.Platform.PlatformLogger")
local Const = require("Common.Const.Const")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformShellTokenUtils = require("SDK.Platform.PlatformShellTokenUtils")
local PlatformInviteTokenService = require("SDK.Platform.PlatformInviteTokenService")
local PlatformShellConst = require("Common.Const.PlatformShellConst")
local ClientConst = require("Const.ClientConst")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformShellInviteService = {}

PlatformShellInviteService.state = {
	ownerUserId = "",
	initialized = false,
	inFlightShellInvitesByTokenType = {}
}

function PlatformShellInviteService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported()
end

function PlatformShellInviteService.supportsMultiplayerActivity()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsMultiplayerActivity and PlatformBridgeLuaFacade.SupportsMultiplayerActivity() == true
end

function PlatformShellInviteService.isRuntimeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsRuntimeInitialized and PlatformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformShellInviteService.getSignedInUserId()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformShellInviteService.resetPendingStateInternal(clearOwner)
	if clearOwner ~= false then
		PlatformShellInviteService.state.ownerUserId = ""
	end
end

function PlatformShellInviteService.bindSignedInUser()
	local ownerUserId = PlatformShellInviteService.getSignedInUserId()

	if string.isNilOrEmpty(ownerUserId) then
		PlatformShellInviteService.resetPendingStateInternal()

		return false
	end

	if PlatformShellInviteService.state.ownerUserId ~= ownerUserId then
		PlatformShellInviteService.resetPendingStateInternal(false)

		PlatformShellInviteService.state.ownerUserId = ownerUserId
	end

	return true
end

function PlatformShellInviteService.showNoticeTip(noticeId)
	PlatformNoticeUtils.showTextTipById(noticeId)
end

function PlatformShellInviteService._logShellInviteIdentity(level, message, tokenType, playerInfo, targetKey)
	local logFunc = logger[level] or logger.info

	logFunc(logger, message .. " tokenType=%s targetKey=%s uid=%s playerId=%s hasMappedGameUid=%s platformFamily=%s platformUserId=%s isPlatformFriend=%s source=%s", tostring(tokenType or ""), tostring(targetKey or ""), tostring(type(playerInfo) == "table" and playerInfo.uid or ""), tostring(type(playerInfo) == "table" and playerInfo.playerId or ""), tostring(type(playerInfo) == "table" and playerInfo.hasMappedGameUid == true), tostring(PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo) or ""), tostring(PlatformIdentityUtils.resolvePlatformUserId(playerInfo) or ""), tostring(type(playerInfo) == "table" and playerInfo.isPlatformFriend == true), tostring(type(playerInfo) == "table" and playerInfo.source or ""))
end

function PlatformShellInviteService.isShellActivityInviteDisabledByGm()
	local prefsCacheUtils = pg and pg.global and pg.global.prefsCacheUtils

	if not prefsCacheUtils or type(prefsCacheUtils.getBool) ~= "function" then
		return false
	end

	return prefsCacheUtils:getBool(ClientConst.PrefKey.GmDisableShellActivityInvite, false) == true
end

function PlatformShellInviteService.resolveIdentity(playerInfo)
	if type(playerInfo) ~= "table" then
		return nil
	end

	local platformFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)
	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(platformFamily) and string.isNilOrEmpty(platformUserId) then
		return nil
	end

	return {
		platformFamily = platformFamily,
		platformUserId = platformUserId
	}
end

function PlatformShellInviteService.buildNormalizedPlayerInfo(playerInfo)
	if type(playerInfo) ~= "table" then
		return playerInfo
	end

	local identity = PlatformShellInviteService.resolveIdentity(playerInfo)

	if not identity then
		return playerInfo
	end

	return {
		platformFamily = identity.platformFamily or "",
		platform = playerInfo.platform or "",
		os = playerInfo.os or "",
		isAllowedCrossPlatform = playerInfo.isAllowedCrossPlatform,
		platformUserId = identity.platformUserId or "",
		uid = playerInfo.uid or playerInfo.playerId or "",
		playerId = playerInfo.playerId or playerInfo.uid or "",
		hasMappedGameUid = playerInfo.hasMappedGameUid,
		isPlatformFriend = playerInfo.isPlatformFriend
	}
end

function PlatformShellInviteService.resolveGameUid(playerInfo)
	if type(playerInfo) ~= "table" then
		return ""
	end

	if playerInfo.hasMappedGameUid ~= true then
		return ""
	end

	return tostring(playerInfo.uid or playerInfo.playerId or "")
end

function PlatformShellInviteService.resolveTargetKey(playerInfo, targetGameUid)
	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if not string.isNilOrEmpty(platformUserId) then
		local platformFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo) or PlatformIdentityUtils.UnknownFamily
		local gameUid = not string.isNilOrEmpty(targetGameUid) and tostring(targetGameUid) or PlatformShellInviteService.resolveGameUid(playerInfo)

		if not string.isNilOrEmpty(gameUid) then
			return string.format("p:%s:%s:g:%s", tostring(platformFamily or ""), tostring(platformUserId or ""), gameUid)
		end

		return string.format("p:%s:%s", tostring(platformFamily or ""), tostring(platformUserId or ""))
	end

	return ""
end

function PlatformShellInviteService:isSupported()
	return PlatformShellInviteService.isPlatformSupported() and PlatformShellInviteService.supportsMultiplayerActivity()
end

function PlatformShellInviteService:init(runtimeReady)
	if PlatformShellInviteService.state.initialized then
		return true
	end

	if not self:isSupported() then
		return false
	end

	if runtimeReady ~= true and not PlatformShellInviteService.isRuntimeReady() then
		return false
	end

	if not PlatformShellInviteService.bindSignedInUser() then
		return false
	end

	PlatformShellInviteService.state.initialized = true

	logger:info("PlatformShellInviteService 已启动。")

	return true
end

function PlatformShellInviteService:shutdown()
	PlatformShellInviteService.state.initialized = false

	self:resetPendingState()
end

function PlatformShellInviteService:resetPendingState()
	PlatformShellInviteService.resetPendingStateInternal()
end

function PlatformShellInviteService.isKnownPlatformFamily(family)
	return not string.isNilOrEmpty(family) and family ~= PlatformIdentityUtils.UnknownFamily and family ~= (PlatformIdentityUtils.Family and PlatformIdentityUtils.Family.Other)
end

function PlatformShellInviteService.isSamePlatformFamilyShellTarget(normalizedPlayerInfo)
	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	local targetFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(normalizedPlayerInfo) or PlatformIdentityUtils.UnknownFamily
	local targetPlatformUserId = PlatformIdentityUtils.resolvePlatformUserId(normalizedPlayerInfo)
	local hasPlatformUserId = not string.isNilOrEmpty(targetPlatformUserId)
	local sameFamily = PlatformShellInviteService.isKnownPlatformFamily(currentFamily) and PlatformShellInviteService.isKnownPlatformFamily(targetFamily) and currentFamily == targetFamily

	return sameFamily == true, {
		currentFamily = currentFamily,
		targetFamily = targetFamily,
		targetPlatformUserId = targetPlatformUserId,
		hasPlatformUserId = hasPlatformUserId
	}
end

function PlatformShellInviteService.sendShellActivityInviteWithToken(tokenType, targetPlatformUserId, inviteToken, targetKey, options)
	local inflight = tokenType ~= nil and PlatformShellInviteService.state.inFlightShellInvitesByTokenType[tokenType] or nil

	if not PlatformShellTokenUtils.canBuildConnectionString(tokenType) then
		logger:warn("sendShellActivityInviteWithToken 未知 tokenType=%s", tostring(tokenType))

		if inflight then
			inflight[targetPlatformUserId] = nil
		end

		return
	end

	local inviterPlatformUserId = PlatformShellInviteService.getSignedInUserId()

	if string.isNilOrEmpty(inviterPlatformUserId) then
		logger:warn("dispatchShellActivityPublish 缺少 inviter platformUserId tokenType=%s", tostring(tokenType))

		if inflight then
			inflight[targetPlatformUserId] = nil
		end

		return
	end

	options = type(options) == "table" and options or nil

	local inviteId = IDManager.genStrID()
	local connectionString = PlatformShellTokenUtils.buildConnectionString(tokenType, {
		inviteId = inviteId,
		inviterPlatformUserId = inviterPlatformUserId,
		inviterGameUid = tostring(pg and pg.me and pg.me.uid or ""),
		inviteToken = inviteToken,
		invitedPlatformUserId = targetPlatformUserId,
		targetKey = targetKey,
		inviteWorldType = options and options.inviteWorldType or "",
		homeCampInviteId = options and options.homeCampInviteId or ""
	})

	if string.isNilOrEmpty(connectionString) then
		logger:warn("Shell invite connectionString 为空 tokenType=%s", tostring(tokenType))

		if inflight then
			inflight[targetPlatformUserId] = nil
		end

		return
	end

	PlatformBridgeLuaFacade.SendMultiplayerActivityInvite(targetPlatformUserId, connectionString, true, tokenType, 0, function(success, result, message)
		if inflight then
			inflight[targetPlatformUserId] = nil
		end

		if tokenType == PlatformShellConst.TokenType.InviteEnterPhotoWorld then
			logger:info("[PHOTO_SHELL] MPA send result success=%s result=%s message=%s target=%s", tostring(success), tostring(result), tostring(message), tostring(targetPlatformUserId))
		end

		if not success then
			logger:warn("Shell invite 发送失败 tokenType=%s result=%s message=%s", tostring(tokenType), tostring(result), tostring(message))

			return
		end

		if pg and pg.global and pg.global.ui and pg.global.ui.tips then
			pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))
		end
	end)
end

function PlatformShellInviteService.dispatchShellActivityPublish(tokenType, targetPlatformUserId, targetKey, options)
	PlatformInviteTokenService:ensureToken(tokenType, targetKey, function(inviteToken, errCode)
		if errCode ~= PlatformInviteTokenService.ErrorCode.SUCCESS or string.isNilOrEmpty(inviteToken) then
			local inflight = PlatformShellInviteService.state.inFlightShellInvitesByTokenType[tokenType]

			if inflight then
				inflight[targetPlatformUserId] = nil
			end

			logger:warn("Shell invite token 为空 tokenType=%s targetKey=%s errCode=%s", tostring(tokenType), tostring(targetKey), tostring(errCode or "empty_token"))

			return
		end

		PlatformShellInviteService.sendShellActivityInviteWithToken(tokenType, targetPlatformUserId, inviteToken, targetKey, options)
	end, options and options.forceTokenRenew == true)
end

function PlatformShellInviteService:sendShellActivityInvite(tokenType, playerInfo, options)
	if not PlatformShellInviteService.isPlatformSupported() or not PlatformShellInviteService.supportsMultiplayerActivity() then
		return false
	end

	if PlatformShellInviteService.isShellActivityInviteDisabledByGm() then
		logger:info("sendShellActivityInvite GM disabled, fallback to game invite tokenType=%s", tostring(tokenType))

		return false
	end

	if not PlatformShellTokenUtils.canBuildConnectionString(tokenType) then
		logger:warn("sendShellActivityInvite 未知 tokenType=%s", tostring(tokenType))

		return false
	end

	if PlatformShellConst.isOpenTargetTokenType(tokenType) then
		logger:warn("sendShellActivityInvite 不支持 open target tokenType=%s", tostring(tokenType))

		return false
	end

	local normalizedPlayerInfo = PlatformShellInviteService.buildNormalizedPlayerInfo(playerInfo)
	local sameFamily, familyContext = PlatformShellInviteService.isSamePlatformFamilyShellTarget(normalizedPlayerInfo)
	local targetGameUid = type(options) == "table" and options.targetGameUid or nil
	local targetKey = PlatformShellInviteService.resolveTargetKey(normalizedPlayerInfo, targetGameUid)

	if tokenType == PlatformShellConst.TokenType.InviteEnterPhotoWorld then
		logger:info("[PHOTO_SHELL] sendShellActivityInvite sameFamily=%s currentFamily=%s targetFamily=%s hasPlatformUserId=%s targetKey=%s", tostring(sameFamily), tostring(familyContext.currentFamily), tostring(familyContext.targetFamily), tostring(familyContext.hasPlatformUserId == true), tostring(targetKey))
	end

	if not sameFamily then
		logger:info("Shell invite fallback: tokenType=%s samePlatformFamilyOnly currentFamily=%s targetFamily=%s hasPlatformUserId=%s", tostring(tokenType), tostring(familyContext.currentFamily), tostring(familyContext.targetFamily), tostring(familyContext.hasPlatformUserId == true))

		return false
	end

	local targetPlatformUserId = PlatformIdentityUtils.resolvePlatformUserId(normalizedPlayerInfo)

	if string.isNilOrEmpty(targetPlatformUserId) then
		PlatformShellInviteService._logShellInviteIdentity("error", "Shell invite missing target platformUserId", tokenType, normalizedPlayerInfo, targetKey)

		return true
	end

	if string.isNilOrEmpty(targetKey) then
		PlatformShellInviteService._logShellInviteIdentity("error", "Shell invite missing targetKey", tokenType, normalizedPlayerInfo, targetKey)

		return true
	end

	PlatformShellInviteService._logShellInviteIdentity("info", "Shell invite resolved target", tokenType, normalizedPlayerInfo, targetKey)

	PlatformShellInviteService.state.inFlightShellInvitesByTokenType[tokenType] = PlatformShellInviteService.state.inFlightShellInvitesByTokenType[tokenType] or {}

	if PlatformShellInviteService.state.inFlightShellInvitesByTokenType[tokenType][targetPlatformUserId] then
		logger:debug("Shell invite 已在飞行中,跳过重复触发 tokenType=%s target=%s", tostring(tokenType), tostring(targetPlatformUserId))

		return true
	end

	PlatformShellInviteService.state.inFlightShellInvitesByTokenType[tokenType][targetPlatformUserId] = true

	PlatformShellInviteService.dispatchShellActivityPublish(tokenType, targetPlatformUserId, targetKey, options)

	return true
end

function PlatformShellInviteService:sendHomeCampInvite(playerInfo, homeCampInviteId)
	if string.isNilOrEmpty(homeCampInviteId) then
		return false
	end

	if PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation then
		return false
	end

	return self:sendShellActivityInvite(PlatformShellConst.TokenType.InviteHomeCamp, playerInfo, {
		homeCampInviteId = homeCampInviteId
	})
end

function PlatformShellInviteService:sendPetExchangeInvite(playerInfo, targetGameUid)
	return self:sendShellActivityInvite(PlatformShellConst.TokenType.InviteExchangePet, playerInfo, {
		forceTokenRenew = true,
		inviteWorldType = Const.InviteWorldType.EXCHANGE_PET,
		targetGameUid = targetGameUid
	})
end

return PlatformShellInviteService
