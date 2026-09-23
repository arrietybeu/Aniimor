-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarFusion\\AvatarFusionView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AvatarFusionView = Class.LightClass("AvatarFusionView", UIView)

function AvatarFusionView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.joyStickUJoyStick = self.objectReference:GetRefValue("joyStickUJoyStick")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.hairList = self.objectReference:GetRefValue("hairList")
	self.makeUpList = self.objectReference:GetRefValue("makeUpList")
	self.btnAdd1UButton = self.objectReference:GetRefValue("btnAdd1UButton")
	self.btnAdd2UButton = self.objectReference:GetRefValue("btnAdd2UButton")
	self.btnAdd3UButton = self.objectReference:GetRefValue("btnAdd3UButton")
	self.btnDiceUButton = self.objectReference:GetRefValue("btnDiceUButton")
	self.btnUseUButton = self.objectReference:GetRefValue("btnUseUButton")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.text1USDFText = self.objectReference:GetRefValue("text1USDFText")
	self.handleRectTransform = self.objectReference:GetRefValue("handleRectTransform")
	self.text2USDFText = self.objectReference:GetRefValue("text2USDFText")
	self.closeListUButton = self.objectReference:GetRefValue("closeListUButton")
	self.rightUWidget = self.objectReference:GetRefValue("rightUWidget")
	self.rayBoxURayBox = self.objectReference:GetRefValue("rayBoxURayBox")
	self.text3USDFText = self.objectReference:GetRefValue("text3USDFText")
end

function AvatarFusionView:registerObjects()
	return
end

function AvatarFusionView:initView()
	return
end

return AvatarFusionView
