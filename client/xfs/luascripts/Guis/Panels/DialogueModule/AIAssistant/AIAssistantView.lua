-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\AIAssistant\\AIAssistantView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AIAssistantView = Class.LightClass("AIAssistantView", UIView)

function AIAssistantView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.contentTxt = self.objectReference:GetRefValue("contentTxt")
	self.mainCom = self.objectReference:GetRefValue("mainCom")
	self.titleNameText = self.objectReference:GetRefValue("titleNameText")
	self.contentAnimation = self.objectReference:GetRefValue("contentAnimation")
	self.nextBtn = self.objectReference:GetRefValue("nextBtn")
	self.keyHotKeyContent = self.objectReference:GetRefValue("keyHotKeyContent")
end

function AIAssistantView:registerObjects()
	return
end

function AIAssistantView:initView()
	return
end

return AIAssistantView
