-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareViewSimple\\MarkShareViewSimpleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MarkShareViewSimpleView = Class.LightClass("MarkShareViewSimpleView", UIView)

function MarkShareViewSimpleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.root = self.objectReference:GetRefValue("root")
	self.btnClose1UButton = self.objectReference:GetRefValue("btnClose1UButton")
	self.btnClose2UButton = self.objectReference:GetRefValue("btnClose2UButton")
	self.btnClose3UButton = self.objectReference:GetRefValue("btnClose3UButton")
	self.presetLikeBtn = self.objectReference:GetRefValue("presetLikeBtn")
	self.presetLikeNum = self.objectReference:GetRefValue("presetLikeNum")
	self.concatText = self.objectReference:GetRefValue("concatText")
	self.selfLikeNum = self.objectReference:GetRefValue("selfLikeNum")
	self.otherPlayerLikeBtn = self.objectReference:GetRefValue("otherPlayerLikeBtn")
	self.otherPlayerLikeNum = self.objectReference:GetRefValue("otherPlayerLikeNum")
	self.btnPositionUButton = self.objectReference:GetRefValue("btnPositionUButton")
	self.btnDeleteUButton = self.objectReference:GetRefValue("btnDeleteUButton")
	self.listContentUList = self.objectReference:GetRefValue("listContentUList")
	self.panelAnimation = self.objectReference:GetRefValue("panelAnimation")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.templateUWidget = self.objectReference:GetRefValue("templateUWidget")
	self.txtIDUSDFText = self.objectReference:GetRefValue("txtIDUSDFText")
end

function MarkShareViewSimpleView:initView()
	return
end

return MarkShareViewSimpleView
