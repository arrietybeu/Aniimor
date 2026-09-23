-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\MarkShare\\Helper\\MarkShareSystemBubbleHelper.lua

local Class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local EventConst = require("Const.EventConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MarkShareSystemBubbleHelper = Class.LiteClass("MarkShareSystemBubbleHelper")

function MarkShareSystemBubbleHelper:ctor()
	return
end

function MarkShareSystemBubbleHelper:init(gameObject)
	self.bubbleViewGameObject = gameObject
	self.bubbleViewGameObjectRectTransform = self.bubbleViewGameObject:GetComponent("RectTransform")

	self:enableBubble(false)
	self:listenRefreshPlaceHolderTextEvent()
end

function MarkShareSystemBubbleHelper:listenRefreshPlaceHolderTextEvent()
	if not self.bubbleViewGameObject then
		return
	end

	function self.onLanguageChanged(data)
		local inputField = self:getInputField()

		if inputField then
			inputField.placeHolder:RefreshLocalization()
		end
	end

	pg.global.eventEmitter:removeEventListener(EventConst.ON_LANGUAGE_CHANGED, self.onLanguageChanged)
	pg.global.eventEmitter:addEventListener(EventConst.ON_LANGUAGE_CHANGED, self.onLanguageChanged)
end

function MarkShareSystemBubbleHelper:enableBubble(enable, isEditing)
	if not self.bubbleViewGameObject then
		return
	end

	if enable then
		TimerManager.addTimer(0.25, function()
			self.bubbleViewGameObject:SetActiveEx(enable)
			self:refreshLimit()
		end)
	else
		self.bubbleViewGameObject:SetActiveEx(enable)
	end

	self:setPosOffset(isEditing)
end

function MarkShareSystemBubbleHelper:setPos(pos, tickUpdate)
	if not self.bubbleViewGameObject then
		return
	end

	self.tickUpdate = tickUpdate
	self.entPos = pos

	local uiPos = UIUtils.WorldToUIPosition(self.entPos)

	self.bubbleViewGameObjectRectTransform.position = uiPos
end

function MarkShareSystemBubbleHelper:onTick()
	if not self.bubbleViewGameObject then
		return
	end

	if not self.tickUpdate then
		return
	end

	if not self.bubbleViewGameObjectRectTransform then
		return
	end

	if not self.entPos then
		return
	end

	local uiPos = UIUtils.WorldToUIPosition(self.entPos)

	self.bubbleViewGameObjectRectTransform.position = uiPos
end

function MarkShareSystemBubbleHelper:setPosOffset(isEditing)
	if not self.bubbleViewGameObject then
		return
	end

	if isEditing == nil then
		return
	end

	local objectReference = self.bubbleViewGameObject:GetComponent("ObjectReference")
	local bubbleViewRectTransform = objectReference:GetRefValue("windowRectTransform")

	if isEditing then
		bubbleViewRectTransform.anchoredPosition = Vector3(SysConfigData.INFO_STAMP_BUBBLE_EDIT_OFFSET[1], SysConfigData.INFO_STAMP_BUBBLE_EDIT_OFFSET[2], SysConfigData.INFO_STAMP_BUBBLE_EDIT_OFFSET[3])
		bubbleViewRectTransform.localScale = Vector3(SysConfigData.INFO_STAMP_BUBBLE_EDIT_OFFSET[4], SysConfigData.INFO_STAMP_BUBBLE_EDIT_OFFSET[5], SysConfigData.INFO_STAMP_BUBBLE_EDIT_OFFSET[6])
	else
		bubbleViewRectTransform.anchoredPosition = Vector3(SysConfigData.INFO_STAMP_BUBBLE_VIEW_OFFSET[1], SysConfigData.INFO_STAMP_BUBBLE_VIEW_OFFSET[2], SysConfigData.INFO_STAMP_BUBBLE_VIEW_OFFSET[3])
		bubbleViewRectTransform.localScale = Vector3(SysConfigData.INFO_STAMP_BUBBLE_VIEW_OFFSET[4], SysConfigData.INFO_STAMP_BUBBLE_VIEW_OFFSET[5], SysConfigData.INFO_STAMP_BUBBLE_VIEW_OFFSET[6])
	end
end

function MarkShareSystemBubbleHelper:changeType(isInput)
	if not self.bubbleViewGameObject then
		return
	end

	local objectReference = self.bubbleViewGameObject:GetComponent("ObjectReference")
	local txtContentTransform = objectReference:GetRefValue("txtContentTransform")
	local inputTransform = objectReference:GetRefValue("inputTransform")

	if isInput then
		txtContentTransform.gameObject:SetActiveEx(false)
		inputTransform.gameObject:SetActiveEx(true)
	else
		txtContentTransform.gameObject:SetActiveEx(true)
		inputTransform.gameObject:SetActiveEx(false)
	end
end

function MarkShareSystemBubbleHelper:changeImageUrl(url)
	if not self.bubbleViewGameObject then
		return
	end

	local objectReference = self.bubbleViewGameObject:GetComponent("ObjectReference")
	local imgBubbleUImage = objectReference:GetRefValue("imgBubbleUImage")

	imgBubbleUImage.url = url
end

function MarkShareSystemBubbleHelper:playSwitchAni()
	if not self.bubbleViewGameObject then
		return
	end

	local objectReference = self.bubbleViewGameObject:GetComponent("ObjectReference")
	local bubbleViewUComponent = objectReference:GetRefValue("bubbleViewUComponent")

	bubbleViewUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
end

function MarkShareSystemBubbleHelper:changeViewText(text)
	if not self.bubbleViewGameObject then
		return
	end

	local objectReference = self.bubbleViewGameObject:GetComponent("ObjectReference")
	local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")

	ClientTextUtils.setText(txtContentUSDFText, text)
end

function MarkShareSystemBubbleHelper:getInputField()
	if not self.bubbleViewGameObject then
		return
	end

	local objectReference = self.bubbleViewGameObject:GetComponent("ObjectReference")
	local inputFieldUInputField = objectReference:GetRefValue("inputFieldUInputField")

	return inputFieldUInputField
end

function MarkShareSystemBubbleHelper:isBubbleActivated()
	return self.bubbleViewGameObject.activeSelf
end

function MarkShareSystemBubbleHelper:getInputFieldLimitText()
	if not self.bubbleViewGameObject then
		return
	end

	local objectReference = self.bubbleViewGameObject:GetComponent("ObjectReference")
	local limitUSDFText = objectReference:GetRefValue("limitUSDFText")

	return limitUSDFText
end

function MarkShareSystemBubbleHelper:refreshLimit()
	if not self.bubbleViewGameObject then
		return
	end

	local curLength = self:getInputField():GetTextLength()
	local limit = self:getInputField().characterLimit

	if limit <= curLength then
		ClientTextUtils.setText(self:getInputFieldLimitText(), string.format("<color=red>%s</color>/%s", curLength, limit))
	else
		ClientTextUtils.setText(self:getInputFieldLimitText(), string.format("%s/%s", curLength, limit))
	end
end

function MarkShareSystemBubbleHelper:allowInputField(allow)
	if not self.bubbleViewGameObject then
		return
	end

	self:getInputField().readOnly = not allow
end

function MarkShareSystemBubbleHelper:destroyBubble()
	self.bubbleViewGameObject = nil
	self.bubbleViewGameObjectRectTransform = nil
end

return MarkShareSystemBubbleHelper
