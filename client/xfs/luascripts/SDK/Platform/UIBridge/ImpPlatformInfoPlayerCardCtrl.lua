-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformInfoPlayerCardCtrl.lua

local M = {}
local TimerManager = require("Core.Timer.TimerManager")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")

M.DISPLAY_NAME_CONFIG = PlatformDisplayNameConfig.UI_Pb_InfoPlayer_Card

function M:setPlayerBaseInfoName(rawName)
	local view = self.view

	if view then
		PlatformDisplayNameInjector.enableRichText(view.playerNameText)
		PlatformDisplayNameInjector.enableRichText(view.playerNameChangeText)
		PlatformDisplayNameInjector.enableRichText(view.nameCoverText)
	end

	rawName = rawName or self.playerInfo and self.playerInfo.playerName or ""

	local finalName = rawName

	if self.playerInfo and tostring(self.playerInfo.uid) ~= tostring(pg.me and pg.me.uid) then
		finalName = PlatformNameMaskService.getMaskedDisplayName({
			action = PlatformNameMaskService.Action.InfoPlayerCardName,
			uid = self.playerInfo.uid,
			playerInfo = self.playerInfo,
			rawText = rawName
		})
	end

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = self.playerInfo,
		config = M.DISPLAY_NAME_CONFIG,
		rawName = finalName
	})
end

function M:setPlayerBaseInfoSign(rawSign)
	return PlatformNameMaskService:getVisibleProfileSignature(self.playerInfo and self.playerInfo.uid, self.playerInfo, rawSign)
end

function M:setPlayerBaseInfoOnlineID()
	return PlatformDisplayNameInjector.applyOnlineID({
		objectReference = self.view and self.view.infoPlayerPanelObjectReference,
		playerInfo = self.playerInfo,
		config = M.DISPLAY_NAME_CONFIG
	})
end

function M:setInteractIconColor(button, data)
	if not data.iconColor then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconImagePro = objectReference:GetRefValue("iconImagePro")

	if not iconImagePro then
		return
	end

	local color = data.iconColor

	local function applyColor()
		iconImagePro:SetColorWithHtmlString(color)
	end

	applyColor()
	TimerManager.addNextFrameCb(function()
		if not self.view then
			return
		end

		applyColor()
		TimerManager.addNextFrameCb(function()
			if not self.view then
				return
			end

			applyColor()
		end)
	end)

	button.luaNavFocused = applyColor
	button.luaNavUnfocused = applyColor
	button.luaPress = applyColor
	button.luaRelease = applyColor
end

function M:visitHome(playerId)
	self:_visitHomeImpl(playerId)
end

return M
