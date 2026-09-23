-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpGet\\BpGetView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpGetView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BpGetView = Class.LightClass("BpGetView", UIView)

function BpGetView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.nameTxt = objectReference:GetRefValue("nameTxt")
	self.InfoText = objectReference:GetRefValue("InfoText")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnNext = objectReference:GetRefValue("btnNext")
end

function BpGetView:registerObjects()
	return
end

function BpGetView:initView()
	return
end

return BpGetView
