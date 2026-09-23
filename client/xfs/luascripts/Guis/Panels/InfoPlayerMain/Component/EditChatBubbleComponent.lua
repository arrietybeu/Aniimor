-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\Component\\EditChatBubbleComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EditChatBubbleComponent = Class.LightClass("EditChatBubbleComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local ChatBubbleData = require("Data.chat_bubble_data")
local ItemSourceData = require("Data.item_source_data")

EditChatBubbleComponent.messages = {
	[MessageName.PLAYER_CHAT_BUBBLE_CHANGE] = {
		"updateCurrentChatBubble",
		true
	},
	[MessageName.PLAYER_CHAT_BUBBLE_DICTS_CHANGE] = {
		"refreshEditChatBubblePanel",
		true
	}
}

function EditChatBubbleComponent:onCtor(info)
	self.playerInfo = info.playerInfo
	self.btnConfirm = info.btnConfirm
	self.getWayBottomText = info.getWayBottomText
	self.usingUWidget = info.usingUWidget

	local btnConfirmObjectReference = self.btnConfirm:GetComponent("ObjectReference")

	self.btnConfirmText = btnConfirmObjectReference:GetRefValue("txtNameUText")

	function self.confirmHandler()
		self:onConfirmBtnClick()
	end

	function self.refreshPanelHandler(order)
		self.order = order

		self:refreshEditChatBubblePanel()
	end
end

function EditChatBubbleComponent:initView()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listChatBubbleUList = objectReference:GetRefValue("listChatBubbleUList")
	self.bubbleNameText = objectReference:GetRefValue("bubbleNameText")
	self.bubbleDescribeUSDFText = objectReference:GetRefValue("bubbleDescribeUSDFText")
	self.backgroundDescribeUSDFText = objectReference:GetRefValue("backgroundDescribeUSDFText")
	self.chatButtleBgUImage = objectReference:GetRefValue("chatButtleBgUImage")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	function self.listChatBubbleUList.luaRenderItem(button, index, data)
		self:renderChatBubbleItem(button, index, data)
	end

	self.nowBubbleId = self:getCurChatBubbleId()
end

function EditChatBubbleComponent:refreshEditChatBubblePanel()
	self.chatBubbleList = self.model:getChatBubbleList()
	self.oldClickButton = nil

	local curBubbleId = self:getCurChatBubbleId()

	if curBubbleId == 0 then
		curBubbleId = next(self.chatBubbleList) ~= nil and self.chatBubbleList[1].id or nil
	end

	self.curSelectedBubbleId = curBubbleId

	self.listChatBubbleUList:SetList(self.chatBubbleList)

	if curBubbleId == nil then
		self:refreshSelectedChatBubble(nil)

		return
	end

	local selectIndex = 0

	for i, data in ipairs(self.chatBubbleList) do
		if data.id == curBubbleId then
			selectIndex = i - 1

			break
		end
	end

	self.listChatBubbleUList:GoToIndex(selectIndex)
	self:refreshSelectedChatBubble(self.chatBubbleList[selectIndex + 1])
end

function EditChatBubbleComponent:getFirstValidSourceData(id)
	local config = id and ChatBubbleData[id]

	if not config or not config.source then
		return nil
	end

	for _, sourceId in ipairs(config.source) do
		local sourceData = ItemSourceData[sourceId]

		if sourceData then
			return sourceData, sourceId
		end
	end

	return nil
end

function EditChatBubbleComponent:getSourceDescText(sourceList)
	if not sourceList then
		return ""
	end

	for _, sourceId in ipairs(sourceList) do
		local sourceData = ItemSourceData[sourceId]
		local desc = sourceData and sourceData.desc

		if desc then
			return pg.getLocalizationText(desc)
		end
	end

	return ""
end

function EditChatBubbleComponent:renderChatBubbleItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local chatButtleBgUImage = objectReference:GetRefValue("chatButtleBgUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	chatButtleBgUImage.url = data.res

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("CHAT_BUBBLE_TEST_TEXT"))

	local curChatBubbleId = self:getCurChatBubbleId()

	if data.id == curChatBubbleId then
		button:TryChangePage("State", 2)
	else
		button:TryChangePage("State", data.isLock and 1 or 0)
	end

	local isSelected = self.curSelectedBubbleId == data.id

	button.isSelected = isSelected

	if isSelected then
		self.oldClickButton = button
	end

	function button.luaClick()
		self:selectChatBubble(button, data)
	end

	function button.luaNavFocused()
		self:selectChatBubble(button, data)
	end
end

function EditChatBubbleComponent:selectChatBubble(button, data)
	self.curSelectedBubbleId = data.id

	if self.oldClickButton ~= nil and self.oldClickButton ~= button then
		self.oldClickButton.isSelected = false
	end

	self.oldClickButton = button
	button.isSelected = true

	self:refreshSelectedChatBubble(data)
end

function EditChatBubbleComponent:refreshConfirmButtonState(id)
	self:resetConfirmButtonState()

	if not id then
		self:showNoSelectedButton()

		return
	end

	if self.model:isChatBubbleLock(id) then
		self:showGoGetButton(id)

		return
	end

	if self:isCurrentChatBubble(id) then
		self:showUsingButton()

		return
	end

	self:showUseButton()
end

function EditChatBubbleComponent:resetConfirmButtonState()
	self.usingUWidget:SetActive(false)
	self.btnConfirm:SetActive(true)
	self.getWayBottomText:SetActive(false)
	self.btnConfirm:TryChangePage("IconState", 0)
	self.btnConfirm:TryChangePage("button", 0)
end

function EditChatBubbleComponent:showNoSelectedButton()
	ClientTextUtils.setText(self.btnConfirmText, "")
	self.btnConfirm:TryChangePage("button", 4)

	self.btnConfirm.interactable = false
end

function EditChatBubbleComponent:showGoGetButton(id)
	ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GO_GET_ITEM"))

	self.btnConfirm.interactable = true

	local sourceData = self:getFirstValidSourceData(id)

	if sourceData then
		self.btnConfirm:TryChangePage("IconState", 1)
		self:refreshGetWayText(ChatBubbleData[id].source)
	end
end

function EditChatBubbleComponent:showUsingButton()
	ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GRAB_EGG_USE_LOADING"))

	self.btnConfirm.interactable = false

	self.usingUWidget:SetActive(true)
	self.btnConfirm:SetActive(false)
end

function EditChatBubbleComponent:showUseButton()
	ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("USE"))

	self.btnConfirm.interactable = true
end

function EditChatBubbleComponent:refreshGetWayText(sourceList)
	local sourceText = self:getSourceDescText(sourceList)

	ClientTextUtils.setText(self.getWayBottomText, sourceText)
	self.getWayBottomText:SetActive(sourceText ~= "")
end

function EditChatBubbleComponent:isCurrentChatBubble(id)
	return id == self:getCurChatBubbleId()
end

function EditChatBubbleComponent:refreshSelectedChatBubble(data)
	if not data then
		ClientTextUtils.setText(self.bubbleNameText, "")
		ClientTextUtils.setText(self.bubbleDescribeUSDFText, "")
		ClientTextUtils.setText(self.backgroundDescribeUSDFText, "")
		ClientTextUtils.setText(self.txtNameUSDFText, "")

		self.chatButtleBgUImage.url = ""

		self:refreshConfirmButtonState(nil)
		self:refreshGetWayText(nil)

		return
	end

	ClientTextUtils.setText(self.bubbleNameText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(self.bubbleDescribeUSDFText, pg.getGameString("CHAT_BUBBLE_DETAIL"))
	ClientTextUtils.setText(self.backgroundDescribeUSDFText, "")
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("CHAT_BUBBLE_TEST_TEXT"))

	self.chatButtleBgUImage.url = data.res or ""

	self:refreshConfirmButtonState(data.id)
end

function EditChatBubbleComponent:getCurChatBubbleId()
	if pg.me.chatBubble == nil or pg.me.chatBubble == 0 then
		return pg.game.chat:GetDefaultChatBubbleId()
	end

	return pg.me.chatBubble
end

function EditChatBubbleComponent:onConfirmBtnClick()
	local id = self.curSelectedBubbleId

	if not id then
		return
	end

	if self.model:isChatBubbleLock(id) then
		local sourceData, sourceId = self:getFirstValidSourceData(id)

		if sourceData then
			local clueSeekData = {
				clueSeekID = sourceId
			}

			table.merge(clueSeekData, sourceData)
			LuaUIUtils.clueSeek(clueSeekData, nil, self.btnConfirm, sourceId)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("NO_GET_CHANNEL"))
		end
	elseif id ~= self:getCurChatBubbleId() then
		pg.me:serverMsg("RPC_CS_SetChatBubble", id)
	end
end

function EditChatBubbleComponent:updateCurrentChatBubble(newBubbleId)
	local oldBubbleId = self.nowBubbleId

	for i, data in ipairs(self.chatBubbleList) do
		if data.id == oldBubbleId or data.id == newBubbleId then
			self.listChatBubbleUList:RefreshElement(i - 1)
		end
	end

	self.nowBubbleId = newBubbleId

	self:refreshConfirmButtonState(newBubbleId)
end

return EditChatBubbleComponent
