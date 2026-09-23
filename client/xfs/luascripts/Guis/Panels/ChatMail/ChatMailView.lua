-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChatMail\\ChatMailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("ChatMailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ChatMailView = Class.LightClass("ChatMailView", UIView)

function ChatMailView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.mailTransform = self.objectReference:GetRefValue("mailTransform")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.infoUButton = self.objectReference:GetRefValue("infoUButton")
end

function ChatMailView:registerObjects()
	return
end

function ChatMailView:initView()
	return
end

return ChatMailView
