-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTeamQuickSwitch\\PetTeamQuickSwitchView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetTeamQuickSwitchView = Class.LightClass("PetTeamQuickSwitchView", UIView)

function PetTeamQuickSwitchView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.cell1UComponent = self.objectReference:GetRefValue("cell1UComponent")
	self.cell2UComponent = self.objectReference:GetRefValue("cell2UComponent")
	self.cell3UComponent = self.objectReference:GetRefValue("cell3UComponent")
	self.cell4UComponent = self.objectReference:GetRefValue("cell4UComponent")
	self.cell5UComponent = self.objectReference:GetRefValue("cell5UComponent")
	self.cell6UComponent = self.objectReference:GetRefValue("cell6UComponent")
	self.teamNumTextPlus = self.objectReference:GetRefValue("teamNumTextPlus")
	self.teamNameTextPlus = self.objectReference:GetRefValue("teamNameTextPlus")
	self.petTeamUList = self.objectReference:GetRefValue("petTeamUList")
	self.inBattleULayoutBox = self.objectReference:GetRefValue("inBattleULayoutBox")
	self.hintKeyUList = self.objectReference:GetRefValue("hintKeyUList")
	self.panelTransform = self.objectReference:GetRefValue("panelTransform")
end

function PetTeamQuickSwitchView:registerObjects()
	return
end

function PetTeamQuickSwitchView:initView()
	return
end

return PetTeamQuickSwitchView
