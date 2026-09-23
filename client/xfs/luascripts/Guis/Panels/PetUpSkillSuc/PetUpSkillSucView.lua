-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetUpSkillSuc\\PetUpSkillSucView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetUpSkillSucView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetUpSkillSucView = Class.LightClass("PetUpSkillSucView", UIView)

function PetUpSkillSucView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.petSkillUButton = objectReference:GetRefValue("petSkillUButton")
end

function PetUpSkillSucView:registerObjects()
	return
end

function PetUpSkillSucView:initView()
	return
end

return PetUpSkillSucView
