-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChatPhotograph\\ChatPhotographCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local ChatPhotographCtrl = Class.LightClass("ChatPhotographCtrl", UICtrl)

ChatPhotographCtrl.Mode = {
	Normal = 0,
	Send = 1
}
ChatPhotographCtrl.messages = {
	[MessageName.CHAT_MESSAGE_UPDATE_ITEM] = {
		"onChatMessageUpdateItem",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function ChatPhotographCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.ossPhotoSpriteMap = {}
	self.ossPhotoLoadingMap = {}
	self.needDestroyOSSPhotoSprites = {}
end

function ChatPhotographCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnLikeUButton.luaClick()
		self:onButtonClick()
	end

	function self.view.btnSendUButton.luaClick()
		self:onButtonClick()
	end

	function self.view.btnLeftUButton.luaClick()
		self:showNextPhoto(-1)
	end

	function self.view.btnRightUButton.luaClick()
		self:showNextPhoto(1)
	end
end

function ChatPhotographCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.photoInfo = info and info.photoInfo or {}
	self.spriteInfos = info and info.spriteInfos or nil
	self.photoIdx = info and info.photoIdx or nil
	self.isPhotoSelected = info and info.isPhotoSelected or nil
	self.isPhotoSelectable = info and info.isPhotoSelectable or nil
	self.mode = info and info.mode or ChatPhotographCtrl.Mode.Normal
	self.playerName = info and info.playerName or ""
	self.likeCount = info and info.likeCount or 0
	self.chatLikeInfo = info and info.chatLikeInfo or nil
	self.sendCallback = info and info.sendCallback or nil
	self.checkSelected = info and info.checkSelected == true
	self.checkCallback = info and info.checkCallback or nil
	self.selectedCount = info and info.selectedCount or nil

	if self.selectedCount == nil then
		self.selectedCount = self.checkSelected and 1 or 0
	end

	self.maxSelectableCount = info and info.maxSelectableCount or 1

	self:initCurPhotoIdx()
	self:refreshUI()
end

function ChatPhotographCtrl:onChatMessageUpdateItem(info)
	if not info or not self.chatLikeInfo then
		return
	end

	if self.chatLikeInfo.SourceMsgId ~= info.msgId then
		return
	end

	local messageData = pg.game.chat:getMessageInfo(info.channelId, info.msgId)

	if not messageData then
		return
	end

	self.likeCount = messageData.likeCount
	self.chatLikeInfo.likeCount = self.likeCount
	self.chatLikeInfo.likedByMe = messageData.likedByMe == true

	if self.photoInfo and self.photoInfo.chatLikeInfo then
		self.photoInfo.chatLikeInfo.likeCount = self.likeCount
		self.photoInfo.chatLikeInfo.likedByMe = self.chatLikeInfo.likedByMe
	end

	self:refreshLikeCount()
	self:refreshLikeButton()
end

function ChatPhotographCtrl:refreshUI()
	self:refreshButtonType()
	self:refreshPhoto()
	self:refreshInfo()
	self:refreshLikeCount()
	self:refreshLikeButton()
	self:refreshCheckButton()
	self:refreshSendText()
	self:refreshPageButton()
end

function ChatPhotographCtrl:refreshPhoto()
	local photoInfo = self.photoInfo or {}

	self.view.photoUImage.url = nil
	self.view.photoUImage.sprite = nil

	if not string.isNilOrEmpty(photoInfo.localPhotoPath) then
		pg.global.mobileCameraMgr:SetTextureToUImage(photoInfo.localPhotoPath, self.view.photoUImage, function(texture)
			if self.photoInfo == photoInfo then
				self:updateAdaptation(texture)
			end
		end)
	elseif photoInfo.sprite then
		self.view.photoUImage.sprite = photoInfo.sprite

		self:updateAdaptation(photoInfo.sprite.texture)
	elseif photoInfo.isOSS and not string.isNilOrEmpty(photoInfo.ossPhotoKey) then
		local photoKey = photoInfo.ossPhotoKey
		local cachedSprite = self.ossPhotoSpriteMap[photoKey]

		if cachedSprite then
			self.view.photoUImage.sprite = cachedSprite

			self:updateAdaptation(cachedSprite.texture)
		elseif not self.ossPhotoLoadingMap[photoKey] then
			self.ossPhotoLoadingMap[photoKey] = true

			pg.me:pullOSSPhoto(photoKey, function(sprite)
				self.ossPhotoLoadingMap[photoKey] = nil

				if not sprite then
					return
				end

				if not self:checkUIOpen() then
					pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

					return
				end

				self.ossPhotoSpriteMap[photoKey] = sprite
				self.needDestroyOSSPhotoSprites[#self.needDestroyOSSPhotoSprites + 1] = sprite

				if self.photoInfo and self.photoInfo.ossPhotoKey == photoKey then
					self.view.photoUImage.sprite = sprite

					self:updateAdaptation(sprite.texture)
				end
			end)
		end
	elseif photoInfo.imgKey and pg.global.ui.photo and pg.global.ui.photo.model then
		local ownerView = self.view
		local imgKey = photoInfo.imgKey

		local function onPresetImgLoaded(sprite, callbackImgKey)
			if self.view ~= ownerView or not self:checkUIOpen() then
				return
			end

			if callbackImgKey ~= self.photoInfo.imgKey then
				return
			end

			if not sprite then
				return
			end

			self.view.photoUImage.sprite = sprite

			self:updateAdaptation(sprite.texture)
		end

		pg.global.ui.photo.model:queryPresetImg(imgKey, onPresetImgLoaded, imgKey)
	elseif photoInfo.isInRes and not string.isNilOrEmpty(photoInfo.resId) then
		self.view.photoUImage.url = photoInfo.resId
	elseif not string.isNilOrEmpty(photoInfo.url) then
		self.view.photoUImage.url = photoInfo.url
	elseif not string.isNilOrEmpty(photoInfo.path) then
		local function onTextureLoaded(texture)
			self:updateAdaptation(texture)
		end

		pg.global.mobileCameraMgr:SetTextureToUImage(photoInfo.path, self.view.photoUImage, onTextureLoaded)
	end
end

function ChatPhotographCtrl:refreshInfo()
	ClientTextUtils.setText(self.view.textCreatorUBaseText, self.playerName or "")
	ClientTextUtils.setText(self.view.textUidUBaseText, self:getPositionText())
	ClientTextUtils.setText(self.view.textPosUBaseText, self:getPhotoTimeText())
end

function ChatPhotographCtrl:refreshButtonType()
	local rootComponent = self.view.rootComponent

	if not rootComponent and self.view.widgetRectTransform then
		rootComponent = self.view.widgetRectTransform:GetComponent("UComponent")
	end

	if rootComponent then
		rootComponent:TryChangePage("ButtonType", self.mode)
	end
end

function ChatPhotographCtrl:refreshLikeCount()
	if self.mode == ChatPhotographCtrl.Mode.Normal then
		ClientTextUtils.setText(self.view.likeCountUSDFText, self.likeCount or 0)
	else
		ClientTextUtils.setText(self.view.likeCountUSDFText, "")
	end
end

function ChatPhotographCtrl:refreshLikeButton()
	local likedByMe = self.chatLikeInfo and self.chatLikeInfo.likedByMe == true

	self.view.btnLikeUButton:TryChangePage("Like", likedByMe and 1 or 0)
end

function ChatPhotographCtrl:refreshCheckButton()
	local checkButton = self.view.btnCheckUButton

	checkButton.luaClick = nil

	checkButton:RemoveLuaGamepadHotkey()

	if self.mode == ChatPhotographCtrl.Mode.Normal or not self:canSelectCurrentPhoto() then
		checkButton:SetActive(false)

		return
	end

	checkButton:SetActive(true)
	checkButton:TryChangePage("State", self.checkSelected and 1 or 0)

	local function togglePhotoSelected()
		self.checkSelected = not self.checkSelected
		self.selectedCount = self.checkSelected and 1 or 0

		checkButton:TryChangePage("State", self.checkSelected and 1 or 0)

		if self.checkCallback then
			local selectedCount = self.checkCallback(self.photoInfo, self.checkSelected)

			if selectedCount ~= nil then
				self.selectedCount = selectedCount
			end
		end

		self:refreshSendText()

		return false
	end

	checkButton.luaClick = togglePhotoSelected

	checkButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, togglePhotoSelected)
	checkButton:SetHotkeyConsoleBar("CONSOLE_BAR_SELECT_DESELECT", 0)
end

function ChatPhotographCtrl:onInputDeviceChanged()
	self:refreshCheckButton()
end

function ChatPhotographCtrl:refreshPageButton()
	if not self.spriteInfos or not self.photoIdx then
		self.view.btnLeftUButton:SetActiveFastest(false)
		self.view.btnRightUButton:SetActiveFastest(false)

		return
	end

	self.view.btnLeftUButton:SetActiveFastest(self:getNextPhotoIndex(-1) ~= nil)
	self.view.btnRightUButton:SetActiveFastest(self:getNextPhotoIndex(1) ~= nil)
end

function ChatPhotographCtrl:refreshSendText()
	if self.mode ~= ChatPhotographCtrl.Mode.Send then
		ClientTextUtils.setText(self.view.btnSendUSDFText, "")

		return
	end

	ClientTextUtils.setText(self.view.btnSendUSDFText, pg.getFormatText(pg.getGameString("CHAT_PHOTO_SEND"), self.selectedCount or 0, self.maxSelectableCount or 1))
end

function ChatPhotographCtrl:onButtonClick()
	if self.mode == ChatPhotographCtrl.Mode.Send then
		if not self.checkSelected or not self:canSelectCurrentPhoto() then
			return
		end

		if self.sendCallback then
			self.sendCallback(self.photoInfo)
		end

		self:close()

		return
	end

	if not self.chatLikeInfo or self.chatLikeInfo.likedByMe == true then
		return
	end

	pg.me:likeChatMessage(self.chatLikeInfo)
end

function ChatPhotographCtrl:showNextPhoto(step)
	local index = self:getNextPhotoIndex(step)

	if not index then
		return
	end

	self.photoIdx = index
	self.photoInfo = self.spriteInfos[index]
	self.checkSelected = self:getCurrentPhotoSelected()

	self:refreshUI()
end

function ChatPhotographCtrl:getNextPhotoIndex(step)
	if not self.spriteInfos or not self.photoIdx then
		return nil
	end

	if step > 0 then
		for idx = self.photoIdx + 1, #self.spriteInfos do
			if self.spriteInfos[idx] and not self.spriteInfos[idx].isDeleted then
				return idx
			end
		end
	else
		for idx = self.photoIdx - 1, 1, -1 do
			if self.spriteInfos[idx] and not self.spriteInfos[idx].isDeleted then
				return idx
			end
		end
	end

	return nil
end

function ChatPhotographCtrl:initCurPhotoIdx()
	if self.photoIdx or not self.spriteInfos then
		return
	end

	for idx, photoInfo in pairs(self.spriteInfos) do
		if self:isSamePhoto(photoInfo, self.photoInfo) then
			self.photoIdx = idx

			return
		end
	end
end

function ChatPhotographCtrl:getCurrentPhotoSelected()
	if self.isPhotoSelected then
		return self.isPhotoSelected(self.photoInfo) == true
	end

	return self.checkSelected
end

function ChatPhotographCtrl:canSelectCurrentPhoto()
	if self.isPhotoSelectable then
		return self.isPhotoSelectable(self.photoInfo) == true
	end

	return true
end

function ChatPhotographCtrl:isSamePhoto(leftPhotoInfo, rightPhotoInfo)
	if not leftPhotoInfo or not rightPhotoInfo then
		return false
	end

	if leftPhotoInfo.ossPhotoKey and rightPhotoInfo.ossPhotoKey then
		return leftPhotoInfo.ossPhotoKey == rightPhotoInfo.ossPhotoKey
	end

	if leftPhotoInfo.path and rightPhotoInfo.path then
		return leftPhotoInfo.path == rightPhotoInfo.path
	end

	if leftPhotoInfo.photoId and rightPhotoInfo.photoId then
		return leftPhotoInfo.photoId == rightPhotoInfo.photoId
	end

	if leftPhotoInfo.resId and rightPhotoInfo.resId then
		return leftPhotoInfo.resId == rightPhotoInfo.resId
	end

	return leftPhotoInfo == rightPhotoInfo
end

function ChatPhotographCtrl:getPhotoTimeText()
	local photoInfo = self.photoInfo or {}

	if not photoInfo.timeStamp then
		return ""
	end

	return pg.getLocalizationTimeYMD(photoInfo.timeStamp)
end

function ChatPhotographCtrl:getPositionText()
	local photoInfo = self.photoInfo or {}
	local pos = photoInfo.position

	if not photoInfo.sceneId or not pos then
		return ""
	end

	local pointName = self.model:getPointNameByPos(photoInfo.sceneId, pos)

	return pg.getFormatText(pg.getGameString("CHAT_PHOTO_POSITION"), pointName or "")
end

function ChatPhotographCtrl:updateAdaptation(texture)
	if not texture then
		return
	end

	self.view.adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

	self.view.adaptationBoxUXAdaptionRect:UpdateAdaptation()
end

function ChatPhotographCtrl:onShow()
	return
end

function ChatPhotographCtrl:onHide()
	return
end

function ChatPhotographCtrl:onDestroy()
	for _, sprite in ipairs(self.needDestroyOSSPhotoSprites) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	UICtrl.onDestroy(self)
end

return ChatPhotographCtrl
