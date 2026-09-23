-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkillLearn\\PetSkillLearnView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetSkillLearnView = Class.LightClass("PetSkillLearnView", UIView)

function PetSkillLearnView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.keyListUList = self.objectReference:GetRefValue("keyListUList")
	self.root = self.objectReference:GetRefValue("root")
end

return PetSkillLearnView
