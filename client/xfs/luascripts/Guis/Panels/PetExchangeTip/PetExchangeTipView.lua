-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeTip\\PetExchangeTipView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetExchangeTipView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetExchangeTipView = Class.LightClass("PetExchangeTipView", UIView)

function PetExchangeTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtContentUBaseText = self.objectReference:GetRefValue("txtContentUBaseText")
	self.btnTipsUButton = self.objectReference:GetRefValue("btnTipsUButton")
	self.rootUPopupForm = self.objectReference:GetRefValue("rootUPopupForm")
end

function PetExchangeTipView:registerObjects()
	return
end

function PetExchangeTipView:initView()
	return
end

return PetExchangeTipView
