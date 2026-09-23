-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonSkip\\CommonSkipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonSkipView = Class.LightClass("CommonSkipView", UIView)

function CommonSkipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnSpeedUButton = self.objectReference:GetRefValue("btnSpeedUButton")
	self.btnAutoUButton = self.objectReference:GetRefValue("btnAutoUButton")
	self.btnPlayingUButton = self.objectReference:GetRefValue("btnPlayingUButton")
	self.btnSkipUButton = self.objectReference:GetRefValue("btnSkipUButton")
	self.btnLogUButton = self.objectReference:GetRefValue("btnLogUButton")
	self.speedText = self.objectReference:GetRefValue("speedText")
	self.mainCom = self.objectReference:GetRefValue("mainCom")
	self.btnGearUButton = self.objectReference:GetRefValue("btnGearUButton")
end

function CommonSkipView:registerObjects()
	return
end

function CommonSkipView:initView()
	return
end

return CommonSkipView
