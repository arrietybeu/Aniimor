-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FissureInfo\\FissureInfoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FissureInfoView = Class.LightClass("FissureInfoView", UIView)

function FissureInfoView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.objectReference = objectReference
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")
end

function FissureInfoView:initView()
	return
end

return FissureInfoView
