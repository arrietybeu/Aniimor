-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamRoomChatBarrageComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MessageName = require("Const.MessageName")
local AddressDataConst = require("Const.AddressDataConst")
local UIObjectPool = require("Utils.UIObjectPool")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TeamRoomChatBarrageComponent = Class.LightClass("TeamRoomChatBarrageComponent", UIComponent)

TeamRoomChatBarrageComponent.START_POS_X = 3200
TeamRoomChatBarrageComponent.ROW_HEIGHT = 150
TeamRoomChatBarrageComponent.FONT_SIZE = 56
TeamRoomChatBarrageComponent.DEFAULT_BULLET_SPEED = 5
TeamRoomChatBarrageComponent.messages = {
	[MessageName.ADD_NEW_CHAT_MESSAGE] = {
		"addNewChatMessage",
		true
	}
}

function TeamRoomChatBarrageComponent:initView()
	self._chatMsgQueue = {}
	self._isPlayingChatMsg = false
	self.chatMessageId = 1
	self.curBulletRow = 0
	self.chatMessagePool = UIObjectPool.new(AddressDataConst.UI_CHAT_HUD_TEXT, self.transform, 3, 1, 1, 1)
end

function TeamRoomChatBarrageComponent:addNewChatMessage(info)
	if self:checkCanPlayChatMessage(info) then
		self:enqueueChatMessage(info)
	end
end

function TeamRoomChatBarrageComponent:checkCanPlayChatMessage(info)
	local messageData = info and info.messageData

	if not messageData or info.isHistory then
		return false
	end

	if not pg.me then
		return false
	end

	return messageData.channelType == pg.game.chat.channelType.Team
end

function TeamRoomChatBarrageComponent:enqueueChatMessage(info)
	self._chatMsgQueue[#self._chatMsgQueue + 1] = {
		chatMessageId = self.chatMessageId,
		messageData = info.messageData
	}
	self.chatMessageId = self.chatMessageId + 1

	self:_tryPlayNextChatMessage()
end

function TeamRoomChatBarrageComponent:_tryPlayNextChatMessage()
	if self._isPlayingChatMsg or #self._chatMsgQueue == 0 then
		return
	end

	self._isPlayingChatMsg = true

	local msg = table.remove(self._chatMsgQueue, 1)

	self:_playChatMessage(msg)
end

function TeamRoomChatBarrageComponent:getMessageText(messageData)
	return pg.game.chat:getTextContentFromExtraInfo(messageData.extraInfo) or messageData.textContent or ""
end

function TeamRoomChatBarrageComponent:getPlayerInfo(playerId)
	if not playerId then
		return nil
	end

	local teamInfo = pg.me and pg.me:getShowTeamInfo() or nil
	local memberInfo = teamInfo and teamInfo.membersInfo and teamInfo.membersInfo[playerId] or nil

	return memberInfo or pg.game.chat:getPlayerInfo(playerId)
end

function TeamRoomChatBarrageComponent:_playChatMessage(msg)
	local chatMessageId = msg.chatMessageId
	local messageData = msg.messageData
	local playerId = messageData.playerId
	local message = self:getMessageText(messageData)

	self.chatMessagePool:createFromPool(nil, chatMessageId, function(objInfo)
		if not self.chatMessagePool or not objInfo or not objInfo.gameObject or IsNil(objInfo.gameObject) then
			return
		end

		self.curBulletRow = self.curBulletRow == 1 and 2 or 1

		local bulletHeight = (self.curBulletRow - 1) * TeamRoomChatBarrageComponent.ROW_HEIGHT
		local parentRect = self.transform:GetComponent("RectTransform")
		local bulletPosY = -parentRect.rect.height * 0.25 - bulletHeight
		local rect = objInfo.gameObject:GetComponent("RectTransform")

		rect.anchorMin = Vector2(0.5, 1)
		rect.anchorMax = Vector2(0.5, 1)
		rect.pivot = Vector2(0.5, 1)
		rect.anchoredPosition = Vector2(TeamRoomChatBarrageComponent.START_POS_X, bulletPosY)

		local button = objInfo.gameObject:GetComponent("UButton")
		local objectReference = button:GetComponent("ObjectReference")
		local chatText = objectReference:GetRefValue("txtDetailsUBaseText")
		local avatarUButton = objectReference:GetRefValue("avatarUButton")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local playerInfo = self:getPlayerInfo(playerId)
		local displayName = playerInfo and LuaUIUtils.getPlayerDisplayName(playerId, playerInfo.playerName, true) or ""
		local prefix = not string.isNilOrEmpty(displayName) and displayName .. ": " or ""

		if playerInfo then
			button:TryChangePage("Avatar", 1)
			LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
				playerId = playerId,
				playerInfo = playerInfo
			})
		else
			button:TryChangePage("Avatar", 2)

			if iconUImage then
				iconUImage.url = ""
			end
		end

		if avatarUButton then
			avatarUButton.luaClick = nil
			avatarUButton.tooltipMode = 0
		end

		ClientTextUtils.setText(chatText, prefix, message)

		chatText.fontSize = TeamRoomChatBarrageComponent.FONT_SIZE

		local triggered = false
		local bulletSpeed = pg.game.chat:getChatSettingState(pg.game.chat.settingType.BulletSetSpeed) or TeamRoomChatBarrageComponent.DEFAULT_BULLET_SPEED

		if bulletSpeed <= 0 then
			bulletSpeed = TeamRoomChatBarrageComponent.DEFAULT_BULLET_SPEED
		end

		DoTweenAnimMgr.AnchorPositionMove(rect, LuaUIUtils.TweenId("anchorPositionMove"), Vector3(-TeamRoomChatBarrageComponent.START_POS_X, bulletPosY, 0), 50 / bulletSpeed, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			if self.chatMessagePool then
				self.chatMessagePool:recycleToPool(chatMessageId)
			end
		end, false, function()
			if not triggered and rect.anchoredPosition.x < TeamRoomChatBarrageComponent.START_POS_X - button.transform.sizeDelta.x then
				triggered = true
				self._isPlayingChatMsg = false

				self:_tryPlayNextChatMessage()
			end
		end)
	end)
end

function TeamRoomChatBarrageComponent:onDestroy()
	if self.chatMessagePool then
		self.chatMessagePool:destroy()

		self.chatMessagePool = nil
	end

	UIComponent.onDestroy(self)
end

return TeamRoomChatBarrageComponent
