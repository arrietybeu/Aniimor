-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueSkip\\DialogueSkipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DialogueSkipView = Class.LightClass("DialogueSkipView", UIView)

function DialogueSkipView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleText = objectReference:GetRefValue("titleText")
	self.scrollRectRectTransform = objectReference:GetRefValue("scrollRectRectTransform")
	self.scrollContent = objectReference:GetRefValue("scrollContent")
	self.btnGoonUButton = objectReference:GetRefValue("btnGoonUButton")
	self.btnSkipUButton = objectReference:GetRefValue("btnSkipUButton")
	self.leftBtnUImage = objectReference:GetRefValue("leftBtnUImage")
	self.rightBtnUImage = objectReference:GetRefValue("rightBtnUImage")
	self.bgBlurUWidget = objectReference:GetRefValue("bgBlurUWidget")
	self.btnGoonText = objectReference:GetRefValue("btnGoonText")
	self.btnSkipText = objectReference:GetRefValue("btnSkipText")
end

return DialogueSkipView
