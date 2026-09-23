-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryAssistStrengthResult\\PetCarryAssistStrengthResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryAssistStrengthResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetCarryAssistStrengthResultView = Class.LightClass("PetCarryAssistStrengthResultView", UIView)

function PetCarryAssistStrengthResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.jewelUImage = objectReference:GetRefValue("jewelUImage")
	self.jewelUComponent = objectReference:GetRefValue("jewelUComponent")
	self.listBaseUList = objectReference:GetRefValue("listBaseUList")
	self.listRandomUList = objectReference:GetRefValue("listRandomUList")
	self.txtCpUBaseText = objectReference:GetRefValue("txtCpUBaseText")
	self.txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
end

function PetCarryAssistStrengthResultView:registerObjects()
	return
end

function PetCarryAssistStrengthResultView:initView()
	return
end

return PetCarryAssistStrengthResultView
