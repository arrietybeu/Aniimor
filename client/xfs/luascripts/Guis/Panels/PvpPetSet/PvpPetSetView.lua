-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpPetSet\\PvpPetSetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpPetSetView = Class.LightClass("PvpPetSetView", UIView)

function PvpPetSetView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.root = self.objectReference:GetRefValue("root")
	self.closeBtn = self.objectReference:GetRefValue("closeBtn")
	self.boxPetList = self.objectReference:GetRefValue("boxPetList")
	self.attributeBtn = self.objectReference:GetRefValue("attributeBtn")
	self.skillBtn = self.objectReference:GetRefValue("skillBtn")
	self.infoBtn = self.objectReference:GetRefValue("infoBtn")
	self.rightPanelUComponent = self.objectReference:GetRefValue("rightPanelUComponent")
	self.btnEvolutionUButton = self.objectReference:GetRefValue("btnEvolutionUButton")
	self.pvpUList = self.objectReference:GetRefValue("pvpUList")
	self.rogueSelectPetUButton = self.objectReference:GetRefValue("rogueSelectPetUButton")
	self.switchSkillBtn = self.objectReference:GetRefValue("switchSkillBtn")
end

function PvpPetSetView:registerObjects()
	return
end

function PvpPetSetView:initView()
	return
end

return PvpPetSetView
