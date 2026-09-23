-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryStrengthResult\\PetCarryStrengthResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryStrengthResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetCarryStrengthResultView = Class.LightClass("PetCarryStrengthResultView", UIView)

function PetCarryStrengthResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.txtLvNow = self.objectReference:GetRefValue("txtLvNow")
	self.txtLvAfter = self.objectReference:GetRefValue("txtLvAfter")
	self.listAttribute = self.objectReference:GetRefValue("listAttribute")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
end

function PetCarryStrengthResultView:registerObjects()
	return
end

function PetCarryStrengthResultView:initView()
	return
end

return PetCarryStrengthResultView
