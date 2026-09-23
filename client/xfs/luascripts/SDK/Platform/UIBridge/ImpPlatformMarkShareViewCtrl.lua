-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformMarkShareViewCtrl.lua

local M = {}
local PlatformImageMaskService = require("SDK.Platform.PlatformImageMaskService")
local PlatformTextMaskService = require("SDK.Platform.PlatformTextMaskService")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local UGCContentPlaceholder = require("Utils.UGCContentPlaceholder")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")

M.UGC_BLOCKED_PAGE = "UGCBlocked"
M.DISPLAY_NAME_CONFIG = PlatformDisplayNameConfig.UI_Pb_MarkShare_View

function M.isSelfUid(uid)
	return not string.isNilOrEmpty(uid) and tostring(uid) == tostring(pg.me.uid)
end

function M.getMarkShareTargetUid(ctrl)
	if ctrl == nil or ctrl.model == nil or ctrl.model.getOtherPlayerUId == nil then
		return nil
	end

	return ctrl.model:getOtherPlayerUId(ctrl.infoStampId)
end

function M.getChatPlayerInfo(uid)
	if string.isNilOrEmpty(uid) or pg.game.chat == nil or pg.game.chat.getPlayerInfo == nil then
		return nil
	end

	return pg.game.chat:getPlayerInfo(uid)
end

function M:initOnlineID(parsedInfo)
	if not pg.global.platform:isPS() then
		return
	end

	local playerId = self.model and self.model.getOtherPlayerUId and self.model:getOtherPlayerUId(self.infoStampId) or nil

	if string.isNilOrEmpty(playerId) then
		PlatformDisplayNameInjector.setNodeActive(self.view and self.view.onlineIDImage, false)

		return
	end

	local function applyWithPlayerInfo(playerInfo)
		if not self.view then
			return
		end

		PlatformDisplayNameInjector.applyOnlineID({
			objectReference = self.view.objectReference,
			playerInfo = playerInfo,
			config = M.DISPLAY_NAME_CONFIG
		})
	end

	local cachedInfo = pg.game.chat:getPlayerInfo(playerId)

	if cachedInfo then
		applyWithPlayerInfo(cachedInfo)
	else
		PlatformDisplayNameInjector.setNodeActive(self.view and self.view.onlineIDImage, false)
		pg.game.chat:getPlayerInfoFromServer(playerId, nil, function(playerInfo)
			applyWithPlayerInfo(playerInfo)
		end)
	end
end

function M:clearOnlineID()
	if not pg.global.platform:isPS() then
		return
	end

	PlatformDisplayNameInjector.setNodeActive(self.view and self.view.onlineIDImage, false)
end

function M:applyMarkShareImage(requestKey, imageWidget, containerWidget, onVisible)
	local uid = M.getMarkShareTargetUid(self)

	if string.isNilOrEmpty(uid) or M.isSelfUid(uid) then
		if type(onVisible) == "function" then
			onVisible(true)
		end

		return true
	end

	return PlatformImageMaskService:bindImage({
		action = "ugc_mark_share_view_image",
		uid = uid,
		playerInfo = M.getChatPlayerInfo(uid),
		requestState = self,
		requestKey = requestKey,
		isAlive = function()
			return self.view ~= nil
		end,
		apply = function(isVisible)
			if type(onVisible) == "function" then
				onVisible(isVisible)
			end
		end,
		onBlocked = function()
			if containerWidget then
				containerWidget:SetActiveEx(true)
			end

			UGCContentPlaceholder.applyToImage(imageWidget, containerWidget, {
				placeholderPage = M.UGC_BLOCKED_PAGE
			})
		end
	})
end

function M:applyMarkShareText(requestKey, rawText, onResolved)
	local uid = M.getMarkShareTargetUid(self)
	local normalizedText = rawText or ""

	if string.isNilOrEmpty(uid) or M.isSelfUid(uid) then
		if type(onResolved) == "function" then
			onResolved(normalizedText)
		end

		return normalizedText
	end

	return PlatformTextMaskService:bindText({
		action = "ugc_mark_share_view_text",
		uid = uid,
		playerInfo = M.getChatPlayerInfo(uid),
		rawText = normalizedText,
		hiddenText = PlatformTextMaskService:getBlockedContentText(),
		pendingText = normalizedText,
		requestState = self,
		requestKey = requestKey,
		isAlive = function()
			return self.view ~= nil
		end,
		apply = function(displayText)
			if type(onResolved) == "function" then
				onResolved(displayText)
			end
		end
	})
end

function M:applyMarkShareName(requestKey, rawText, onResolved)
	local uid = M.getMarkShareTargetUid(self)
	local normalizedText = rawText or ""

	if string.isNilOrEmpty(uid) or M.isSelfUid(uid) then
		if type(onResolved) == "function" then
			onResolved(normalizedText)
		end

		return normalizedText
	end

	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.MarkShareViewName,
		uid = uid,
		playerInfo = M.getChatPlayerInfo(uid),
		rawText = normalizedText
	})

	if type(onResolved) == "function" then
		onResolved(displayText)
	end

	return displayText
end

function M:initCloseButtons()
	local view = self.view

	if not view then
		return
	end

	view.btnClose1UButton.visibility = CS.XGUI.EVisibility.Collapsed
	view.btnClose2UButton.visibility = CS.XGUI.EVisibility.Collapsed
	view.btnClose3UButton.visibility = CS.XGUI.EVisibility.Collapsed

	if view.keyEscHotKeyContent then
		local keyEscWidget = view.keyEscHotKeyContent.transform:GetComponent("UWidget")

		if keyEscWidget then
			keyEscWidget:SetForceTransparent(CS.XGUI.ForceTransparentSource.HotkeyExternal, true, 0)
		end
	end
end

return M
