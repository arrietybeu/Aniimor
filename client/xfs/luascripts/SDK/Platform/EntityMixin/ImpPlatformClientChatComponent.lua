-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientChatComponent.lua

local M = {}
local Const = require("Common.Const.Const")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSendMessageService = require("SDK.Platform.PlatformSendMessageService")
local PlatformStringVerificationService = require("SDK.Platform.PlatformStringVerificationService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local logger = require("SDK.Platform.PlatformLogger")

function M:enrichSenderInfo(senderInfo)
	if type(senderInfo) ~= "table" then
		return
	end

	local rawPlatform = PlatformIdentityUtils.getCurrentRawPlatform()

	if not string.isNilOrEmpty(rawPlatform) then
		rawPlatform = tostring(rawPlatform)
		senderInfo.platform = rawPlatform
		senderInfo.os = rawPlatform
	end

	local platformFamily = PlatformIdentityUtils.getCurrentPlatformFamily()

	if PlatformIdentityUtils.isConsoleFamily(platformFamily) then
		senderInfo.platformFamily = platformFamily
	end

	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.GetSignedInUserId then
		local platformUserId = PlatformBridgeLuaFacade.GetSignedInUserId()

		if not string.isNilOrEmpty(platformUserId) then
			senderInfo.platformUserId = tostring(platformUserId)
		end
	end

	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.GetSignedInDisplayName then
		local platformDisplayName = PlatformBridgeLuaFacade.GetSignedInDisplayName()

		if not string.isNilOrEmpty(platformDisplayName) then
			senderInfo.platformDisplayName = tostring(platformDisplayName)
		end
	end
end

function M:checkSendMessagePolicy(context)
	context = context or {}
	context.channelId = context.channelId or context.targetId
	context.chatSystem = context.chatSystem or pg and pg.game and pg.game.chat

	return PlatformSendMessageService:canSendMessage(context)
end

function M:createChatGroup(members, chatGroupName)
	local policy = PlatformUGCService:peekLocalPolicy()
	local Policy = PlatformUGCService and PlatformUGCService.LocalPolicy or {}

	if policy == Policy.Blocked or policy == "blocked" then
		PlatformNoticeUtils.showTextTipById(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	self:_createChatGroupImpl(members, chatGroupName)
end

function M:setChatGroupStatus(groupId, chatGroupName)
	local policy = PlatformUGCService:peekLocalPolicy()
	local Policy = PlatformUGCService and PlatformUGCService.LocalPolicy or {}

	if policy == Policy.Blocked or policy == "blocked" then
		PlatformNoticeUtils.showTextTipById(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	self:_setChatGroupStatusImpl(groupId, chatGroupName)
end

function M:sensitiveWordsCheck(text, success, failure, extraInfo)
	if not PlatformStringVerificationService:isSupported() then
		self:_sensitiveWordsCheckImpl(text, success, failure, extraInfo)

		return
	end

	local selfRef = self

	PlatformStringVerificationService:verifyString(text, function(shouldProceed, decision, result, reason)
		if shouldProceed == true then
			selfRef:_sensitiveWordsCheckImpl(text, success, failure, extraInfo)

			return
		end

		logger:warn("ClientChatComponent sensitiveWordsCheck blocked by platform verification uid=%s decision=%s result=%s reason=%s", tostring(selfRef.uid), tostring(decision), tostring(result), tostring(reason or ""))
		pg.global.showBubbleMessageRaw(pg.getGameString("INPUT_TEXT_CONTAINS_SENSITIVE"), 2)

		if failure then
			failure(Const.RISK_LEVEL.MUTE, text)
		end
	end)
end

return M
