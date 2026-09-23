-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPlayerChatComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoPlayerChatComponent")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local ChatBubbleData = require("Data.chat_bubble_data")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TopLogoPlayerChatComponent = Class.LightClass("TopLogoPlayerChatComponent", TopLogoItemComponent)
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local TopLogoConst = require("Const.TopLogoConst")
local MAX_BUBBLES = 3
local BUBBLE_LIFETIME = 10

function TopLogoPlayerChatComponent:ctor(refUContainer, topLogoItem)
	TopLogoPlayerChatComponent.super.ctor(self, refUContainer, topLogoItem)

	self.textList = {}
	self.tyingVisible = false
	self.forcedVisible = false
	self.m_cbCachePlayerChatInfos = {}
	self.m_cbCachePlayerChatFunc = nil
end

function TopLogoPlayerChatComponent:onCtor()
	self.m_pendingPlayerChat = false

	self:refreshVisible()
end

function TopLogoPlayerChatComponent:shouldBeActive()
	if self.m_pendingPlayerChat then
		return true
	end

	return self.forcedVisible or self.tyingVisible or #self.textList > 0
end

function TopLogoPlayerChatComponent:onDestroy()
	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_PLAYER_CHAT_BUBBLE, self.onShowPlayerChatBubble)
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_PLAYER_CHAT_TYPING, self.onShowPlayerTyping)
	end

	self.m_pendingPlayerChat = false

	TopLogoPlayerChatComponent.super.onDestroy(self)

	for i, txt in ipairs(self.textList) do
		if txt.timer then
			self:killTimer(txt.timer)

			txt.timer = nil
		end
	end

	self.textList = {}
	self.m_cbCachePlayerChatInfos = {}
	self.m_cbCachePlayerChatFunc = nil
end

function TopLogoPlayerChatComponent:resetRender()
	for _, txt in ipairs(self.textList) do
		if txt.timer then
			self:killTimer(txt.timer)

			txt.timer = nil
		end
	end

	self.textList = {}
	self.forcedVisible = false
	self.tyingVisible = false
	self.m_pendingPlayerChat = false
	self.objectReference = nil
	self.listBubbleUList = nil
	self.playerChatBubbleUComponent = nil
	self.imageBgUImage = nil

	TopLogoPlayerChatComponent.super.resetRender(self)
end

function TopLogoPlayerChatComponent:findObjects()
	local objectReference = self.refUContainer.content:GetComponent("ObjectReference")

	self.listBubbleUList = objectReference:GetRefValue("listBubbleUList")
	self.playerChatBubbleUComponent = objectReference:GetRefValue("playerChatBubbleUComponent")
	self.imageBgUImage = objectReference:GetRefValue("imageBgUImage")
	self.text1USDFText = objectReference:GetRefValue("text1USDFText")
	self.text2USDFText = objectReference:GetRefValue("text2USDFText")
	self.text3USDFText = objectReference:GetRefValue("text3USDFText")
	self.waitUImage = objectReference:GetRefValue("waitUImage")

	ClientTextUtils.setText(self.text1USDFText, ".")
	ClientTextUtils.setText(self.text2USDFText, ".")
	ClientTextUtils.setText(self.text3USDFText, ".")
end

function TopLogoPlayerChatComponent:checkChatBubbleVisible()
	if not self:checkFinalVisible() then
		return false
	end

	return self.forcedVisible or self.tyingVisible
end

function TopLogoPlayerChatComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoPlayerChatComponent:addListener()
	local curId = self.entity.master and self.entity.master.uid or self.entity.uid

	self.playerChatBubbleUComponent:TryChangePage("TextColour", curId == pg.me.uid and 0 or 1)

	function self.listBubbleUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local imageBgUImage = objectReference:GetRefValue("imageBgUImage")

		ClientTextUtils.setText(textUSDFText, data.text)

		local chatBubble = curId == pg.me.uid and pg.me.chatBubble or data.chatBubble

		imageBgUImage.url = pg.game.chat:GetChatBubbleRes(chatBubble, nil, true)
	end
end

function TopLogoPlayerChatComponent:initUI()
	local isVisible = self:checkChatBubbleVisible()

	self.playerChatBubbleUComponent:SetActive(isVisible)
	self.imageBgUImage:SetActive(self.tyingVisible)
end

function TopLogoPlayerChatComponent:addEntityListener()
	if self.entity ~= nil then
		function self.onShowPlayerChatBubble(isVisible, text, isArkFont, chatBubble)
			self.forcedVisible = isVisible

			if self.forcedVisible ~= true then
				self:clearAllText()
			end

			self:handleTextUpdate(text, isArkFont, chatBubble)
			self:_updateComponent()
		end

		function self.onShowPlayerTyping(typeType)
			self.tyingVisible = typeType == ClientConst.PlayerTyping.Typing

			self:_updateComponent()
		end

		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_PLAYER_CHAT_BUBBLE, self.onShowPlayerChatBubble)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_PLAYER_CHAT_TYPING, self.onShowPlayerTyping)
	end
end

function TopLogoPlayerChatComponent:handleTextUpdate(newText, isArkFont, chatBubble)
	if string.isNilOrEmpty(newText) then
		return
	end

	local textData = {
		text = newText,
		isArkFont = isArkFont == true,
		chatBubble = chatBubble
	}

	table.insert(self.textList, textData)

	if #self.textList > MAX_BUBBLES then
		local oldTextData = table.remove(self.textList, 1)

		if oldTextData and oldTextData.timer then
			self:killTimer(oldTextData.timer)

			oldTextData.timer = nil
		end
	end

	textData.timer = self:startTimer(function()
		textData.timer = nil

		if lume.remove(self.textList, textData) then
			self:_updateComponent()
		end
	end, BUBBLE_LIFETIME)
end

function TopLogoPlayerChatComponent:clearAllText()
	for i, txt in ipairs(self.textList) do
		if txt.timer then
			self:killTimer(txt.timer)

			txt.timer = nil
		end
	end

	self.textList = {}
end

function TopLogoPlayerChatComponent:_updateComponent()
	self.m_pendingPlayerChat = self.forcedVisible or self.tyingVisible or #self.textList > 0

	self:notifyActiveStateChanged(self:shouldBeActive())

	if not self.topLogoItem:isTopLogoPrefabReady() then
		return
	end

	self.m_pendingPlayerChat = false
	self.m_cbCachePlayerChatInfos = {
		isVisible = self:checkChatBubbleVisible(),
		isTyingVisible = self.tyingVisible
	}

	if not self.m_cbCachePlayerChatFunc then
		function self.m_cbCachePlayerChatFunc(isSuccess)
			if isSuccess == false then
				return
			end

			if IsNil(self.playerChatBubbleUComponent) then
				return
			end

			self.playerChatBubbleUComponent:SetActive(self.m_cbCachePlayerChatInfos.isVisible)

			if self.m_cbCachePlayerChatInfos.isVisible then
				if NotNil(self.imageBgUImage) then
					local isVisible = self.m_cbCachePlayerChatInfos.isTyingVisible

					if isVisible == true then
						self:SetWaitBubbleImage(self.imageBgUImage)
					end

					self.imageBgUImage:SetActive(isVisible)
				end

				self:refreshBubbleList()
			end
		end
	end

	if self:checkContainerLoaded() then
		self.m_cbCachePlayerChatFunc()
	else
		self:checkAndLoadUContainerUrlSupportAsync(self.m_cbCachePlayerChatFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	end

	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoPlayerChatComponent:SetWaitBubbleImage(uImage)
	local curId = self.entity.master and self.entity.master.uid or self.entity.uid
	local chatBubbleId = pg.me.chatBubble

	if curId ~= pg.me.uid then
		chatBubbleId = pg.game.chat:getPlayerLatestChatBubbleId(curId)
	end

	local defaultChatBubbleId = pg.game.chat:GetDefaultChatBubbleId()

	if chatBubbleId == nil or chatBubbleId == 0 then
		chatBubbleId = defaultChatBubbleId
	end

	local bubbleRes

	if chatBubbleId == defaultChatBubbleId then
		bubbleRes = "$UI_Img_InfoPlayer_BubbleFrame.png"
	else
		local chatBubbleCfg = ChatBubbleData[chatBubbleId]

		bubbleRes = chatBubbleCfg.res
	end

	self.waitUImage.url = bubbleRes
end

function TopLogoPlayerChatComponent:refreshBubbleList()
	if IsNil(self.listBubbleUList) then
		return
	end

	self.listBubbleUList:SetList(self.textList)
end

function TopLogoPlayerChatComponent:removeChatBubble()
	self:hideChatBubble()
end

function TopLogoPlayerChatComponent:hideChatBubble()
	return
end

function TopLogoPlayerChatComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingPlayerChat then
		self.m_pendingPlayerChat = false

		self:_updateComponent()

		return
	end

	if not self:checkChatBubbleVisible() then
		return
	end

	self:_updateComponent()
end

function TopLogoPlayerChatComponent:getInitMaxDistance()
	return SysConfigData.playerSignatureMaxLen
end

return TopLogoPlayerChatComponent
