-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolveBranchSelect\\PetEvolveBranchSelectView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetEvolveBranchSelectView = Class.LightClass("PetEvolveBranchSelectView", UIView)

function PetEvolveBranchSelectView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.root = self.transform:GetComponent("UComponent")
	self.tabDetailGeneUWidget = self.objectReference:GetRefValue("tabDetailGeneUWidget")
	self.windowsUWidget = self.objectReference:GetRefValue("windowsUWidget")
	self.qualityUButton = self.objectReference:GetRefValue("qualityUButton")
	self.conditionList = self.objectReference:GetRefValue("conditionList")
	self.itemList = self.objectReference:GetRefValue("itemList")
	self.btnEvolveUButton = self.objectReference:GetRefValue("btnEvolveUButton")
	self.titleUText = self.objectReference:GetRefValue("titleUText")
	self.descText = self.objectReference:GetRefValue("descText")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.clickObject = self.objectReference:GetRefValue("clickObject")
	self.selected = self.objectReference:GetRefValue("selected")
	self.condtionConsoleSelected = self.objectReference:GetRefValue("CondtionConsoleSelected")
	self.branchInfoUWidget = self.objectReference:GetRefValue("branchInfoUWidget")
	self.branchConsoleSelected = self.objectReference:GetRefValue("BranchConsoleSelected")
	self.consoleKeyUList = self.objectReference:GetRefValue("keyListUList")
	self.detailInfoListChar = self.objectReference:GetRefValue("detailInfoListChar")
end

function PetEvolveBranchSelectView:registerObjects()
	return
end

function PetEvolveBranchSelectView:initView()
	return
end

return PetEvolveBranchSelectView
