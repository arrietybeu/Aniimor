-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\ChatBulletUIComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local MessageName = require("Const.MessageName")
local AddressDataConst = require("Const.AddressDataConst")
local UIObjectPool = require("Utils.UIObjectPool")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ChatBulletUIComponent = Class.LightClass("ChatBulletUIComponent", HudBaseComponent)

ChatBulletUIComponent.messages = {
	[MessageName.ADD_NEW_CHAT_MESSAGE] = {
		"addNewChatMessage",
		true
	}
}

function ChatBulletUIComponent:initView()
	self._chatMsgQueue = {}
	self._isPlayingChatMsg = false
	self.chatMessageId = 1
	self.curBulletRow = 0
	self.chatMessagePool = UIObjectPool.new(AddressDataConst.UI_CHAT_HUD_TEXT, self.transform, 3, 1, 1, 1)
end

function ChatBulletUIComponent:addNewChatMessage(info)
	local messageData = info.messageData

	if info.isHistory or not messageData then
		return
	end

	local channelMuted = pg.game.chat:checkChannelSettingStateById(messageData.channelId, pg.game.chat.settingType.Mute)
	local channelBulletEnabled = pg.game.chat:checkChannelSettingStateById(messageData.channelId, pg.game.chat.settingType.Bullet)
	local typeBulletEnabled = pg.game.chat:checkChatSettingState(messageData.channelType, pg.game.chat.settingType.Bullet, messageData.channelId)

	if info.isCommonBullet or not channelMuted and channelBulletEnabled or typeBulletEnabled then
		self:enqueueChatMessage(info)
	end
end

function ChatBulletUIComponent:enqueueChatMessage(info)
	table.insert(self._chatMsgQueue, {
		chatMessageId = self.chatMessageId,
		messageData = info.messageData,
		icon = info.icon,
		speed = info.speed,
		isCommonBullet = info.isCommonBullet
	})

	self.chatMessageId = self.chatMessageId + 1

	self:_tryPlayNextChatMessage()
end

function ChatBulletUIComponent:_tryPlayNextChatMessage()
	if self._isPlayingChatMsg or #self._chatMsgQueue == 0 then
		return
	end

	self._isPlayingChatMsg = true

	local msg = table.remove(self._chatMsgQueue, 1)

	self:_playChatMessage(msg)
end

function ChatBulletUIComponent:_playChatMessage(msg)
	local chatMessageId = msg.chatMessageId
	local playerId = msg.messageData.playerId
	local message = pg.game.chat:getTextContentFromExtraInfo(msg.messageData.extraInfo) or msg.messageData.textContent
	local isCommonBullet = msg.isCommonBullet

	self.chatMessagePool:createFromPool(nil, chatMessageId, function(objInfo)
		local startPosX = 3200

		self.curBulletRow = self.curBulletRow == 1 and 2 or 1

		local bulletHeight = (self.curBulletRow - 1) * 150
		local parentRect = self.transform:GetComponent("RectTransform")
		local bulletPosY = -parentRect.rect.height * 0.25 - bulletHeight
		local rect = objInfo.gameObject:GetComponent("RectTransform")

		rect.anchorMin = Vector2(0.5, 1)
		rect.anchorMax = Vector2(0.5, 1)
		rect.pivot = Vector2(0.5, 1)
		rect.anchoredPosition = Vector2(startPosX, bulletPosY)

		local button = objInfo.gameObject:GetComponent("UButton")
		local objectReference = button:GetComponent("ObjectReference")
		local chatText = objectReference:GetRefValue("txtDetailsUBaseText")

		if isCommonBullet then
			button:TryChangePage("Avatar", 2)

			local iconCommon = objectReference:GetRefValue("iconUImage")

			iconCommon.url = msg.icon or ""

			ClientTextUtils.setText(chatText, message)
		else
			button:TryChangePage("Avatar", 1)

			local avatarUButton = objectReference:GetRefValue("avatarUButton")
			local playerInfo = pg.game.chat:getPlayerInfo(playerId)

			if playerInfo then
				local displayName = LuaUIUtils.getPlayerDisplayName(playerId, playerInfo.playerName, true)
				local prefix = not string.isNilOrEmpty(displayName) and displayName .. ": " or ""

				LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
					playerId = playerId,
					playerInfo = playerInfo
				})
				ClientTextUtils.setText(chatText, prefix, message)
			end
		end

		local bulletSpeed = msg.speed or pg.game.chat:getChatSettingState(pg.game.chat.settingType.BulletSetSpeed)
		local bulletSize = pg.game.chat:getChatSettingState(pg.game.chat.settingType.BulletSetSize)
		local initTextFontSize = 56

		chatText.fontSize = initTextFontSize * bulletSize / 5

		local triggered = false

		DoTweenAnimMgr.AnchorPositionMove(rect, LuaUIUtils.TweenId("anchorPositionMove"), Vector3(-startPosX, bulletPosY, 0), 50 / bulletSpeed, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			self.chatMessagePool:recycleToPool(chatMessageId)
		end, false, function()
			if not triggered and rect.anchoredPosition.x < startPosX - button.transform.sizeDelta.x then
				triggered = true
				self._isPlayingChatMsg = false

				self:_tryPlayNextChatMessage()
			end
		end)
	end)
end

function ChatBulletUIComponent:onDestroy()
	if self.chatMessagePool then
		self.chatMessagePool:destroy()

		self.chatMessagePool = nil
	end

	HudBaseComponent.onDestroy(self)
end

return ChatBulletUIComponent
