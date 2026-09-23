-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelectBox\\PetSelectBoxView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetSelectBoxView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetSelectBoxView = Class.LightClass("PetSelectBoxView", UIView)

function PetSelectBoxView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.petList = self.objectReference:GetRefValue("petList")
	self.btnSelect = self.objectReference:GetRefValue("btnSelect")
	self.petInfo = self.objectReference:GetRefValue("petInfo")
	self.btnDetails = self.objectReference:GetRefValue("btnDetails")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function PetSelectBoxView:registerObjects()
	return
end

function PetSelectBoxView:initView()
	return
end

return PetSelectBoxView
