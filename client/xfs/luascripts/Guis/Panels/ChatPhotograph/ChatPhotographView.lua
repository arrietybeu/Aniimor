-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChatPhotograph\\ChatPhotographView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ChatPhotographView = Class.LightClass("ChatPhotographView", UIView)

function ChatPhotographView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.photoUImage = objectReference:GetRefValue("photoUImage")
	self.adaptationBoxUXAdaptionRect = objectReference:GetRefValue("adaptationBoxUXAdaptionRect")
	self.textUidUBaseText = objectReference:GetRefValue("textUidUBaseText")
	self.textCreatorUBaseText = objectReference:GetRefValue("textCreatorUBaseText")
	self.widgetRectTransform = objectReference:GetRefValue("widgetRectTransform")
	self.textPosUBaseText = objectReference:GetRefValue("textPosUBaseText")
	self.bgURound = objectReference:GetRefValue("bgURound")
	self.btnCheckUButton = objectReference:GetRefValue("btnCheckUButton")
	self.btnLikeUButton = objectReference:GetRefValue("btnLikeUButton")
	self.likeCountUSDFText = objectReference:GetRefValue("likeCountUSDFText")
	self.btnLeftUButton = objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = objectReference:GetRefValue("btnRightUButton")
	self.btnSendUButton = objectReference:GetRefValue("btnSendUButton")
	self.btnSendUSDFText = objectReference:GetRefValue("btnSendUSDFText")
end

function ChatPhotographView:registerObjects()
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function ChatPhotographView:initView()
	return
end

return ChatPhotographView
