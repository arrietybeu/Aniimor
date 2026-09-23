-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FuncMenuUnlock\\FuncMenuUnlockView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FuncMenuUnlockView = Class.LightClass("FuncMenuUnlockView", UIView)

function FuncMenuUnlockView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.uIPbFunctionUnlockUComponent = self.objectReference:GetRefValue("uIPbFunctionUnlockUComponent")
	self.nameUBaseText = self.objectReference:GetRefValue("nameUBaseText")
	self.btnBgUButton = self.objectReference:GetRefValue("btnBgUButton")
	self.guideUImage = self.objectReference:GetRefValue("guideUImage")
	self.guideUVideoPlayer = self.objectReference:GetRefValue("guideUVideoPlayer")
	self.funcMenuDetailUButton = self.objectReference:GetRefValue("funcMenuDetailUButton")
	self.funcDetailNameUBaseText = self.objectReference:GetRefValue("funcDetailNameUBaseText")
	self.funcDetailContentUBaseText = self.objectReference:GetRefValue("funcDetailContentUBaseText")
	self.previousUButton = self.objectReference:GetRefValue("previousUButton")
	self.nextUButton = self.objectReference:GetRefValue("nextUButton")
	self.detailUList = self.objectReference:GetRefValue("detailUList")
	self.btnSaveUButton = self.objectReference:GetRefValue("btnSaveUButton")
	self.newAnimation = self.objectReference:GetRefValue("newAnimation")
	self.funMenuItemUComponent = self.objectReference:GetRefValue("funMenuItemUComponent")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.bigIconUImage = self.objectReference:GetRefValue("bigIconUImage")

	local btnOC = self.btnSaveUButton:GetComponent("ObjectReference")

	self.btnSaveNameUText = btnOC:GetRefValue("txtNameUText")
end

function FuncMenuUnlockView:registerObjects()
	return
end

function FuncMenuUnlockView:initView()
	return
end

return FuncMenuUnlockView
