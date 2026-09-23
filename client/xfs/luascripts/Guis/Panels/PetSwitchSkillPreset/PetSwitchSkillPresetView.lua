-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSwitchSkillPreset\\PetSwitchSkillPresetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetSwitchSkillPresetView = Class.LightClass("PetSwitchSkillPresetView", UIView)

function PetSwitchSkillPresetView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.title = self.objectReference:GetRefValue("title")
	self.listPresetUList = self.objectReference:GetRefValue("listPresetUList")
	self.btnBottomUButton = self.objectReference:GetRefValue("btnBottomUButton")
end

function PetSwitchSkillPresetView:initView()
	return
end

return PetSwitchSkillPresetView
