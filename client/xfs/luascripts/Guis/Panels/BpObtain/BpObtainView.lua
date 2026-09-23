-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpObtain\\BpObtainView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpObtainView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BpObtainView = Class.LightClass("BpObtainView", UIView)

function BpObtainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.listItem = objectReference:GetRefValue("listItem")
	self.txtExtra = objectReference:GetRefValue("txtExtra")
	self.listItemExtra = objectReference:GetRefValue("listItemExtra")
	self.btnGoTo = objectReference:GetRefValue("btnGoTo")
	self.btnGoToName = objectReference:GetRefValue("btnGoToName")
	self.txtCloseTitle = objectReference:GetRefValue("txtCloseTitle")
	self.btnBGClose = objectReference:GetRefValue("btnBGClose")
end

function BpObtainView:registerObjects()
	return
end

function BpObtainView:initView()
	return
end

return BpObtainView
