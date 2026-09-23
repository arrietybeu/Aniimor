-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpReplaceFeature\\PvpReplaceFeatureView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpReplaceFeatureView = Class.LightClass("PvpReplaceFeatureView", UIView)

function PvpReplaceFeatureView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
end

function PvpReplaceFeatureView:registerObjects()
	return
end

function PvpReplaceFeatureView:initView()
	return
end

return PvpReplaceFeatureView
