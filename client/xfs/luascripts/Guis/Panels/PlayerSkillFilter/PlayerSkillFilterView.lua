-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerSkillFilter\\PlayerSkillFilterView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerSkillFilterView = Class.LightClass("PlayerSkillFilterView", UIView)

function PlayerSkillFilterView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.filterList = self.objectReference:GetRefValue("filterList")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
end

function PlayerSkillFilterView:registerObjects()
	return
end

function PlayerSkillFilterView:initView()
	return
end

return PlayerSkillFilterView
