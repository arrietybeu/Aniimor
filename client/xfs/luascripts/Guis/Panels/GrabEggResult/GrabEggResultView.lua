-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggResult\\GrabEggResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggResultView = Class.LightClass("GrabEggResultView", UIView)

function GrabEggResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.txtEarnings = self.objectReference:GetRefValue("txtEarnings")
	self.rootUWidget = self.transform:GetComponent("UComponent")
end

function GrabEggResultView:registerObjects()
	return
end

function GrabEggResultView:initView()
	return
end

return GrabEggResultView
