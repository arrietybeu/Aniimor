-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\KnowledgePopup\\KnowledgePopupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local KnowledgePopupView = Class.LightClass("KnowledgePopupView", UIView)

function KnowledgePopupView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.exitButton = objectReference:GetRefValue("exitButton")
	self.photo = objectReference:GetRefValue("photo")
end

function KnowledgePopupView:registerObjects()
	return
end

function KnowledgePopupView:initView()
	return
end

return KnowledgePopupView
