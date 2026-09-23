-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerMain\\TowerMainView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerMainView = Class.LightClass("TowerMainView", UIView)

function TowerMainView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.btnGoinUButton = self.objectReference:GetRefValue("btnGoinUButton")
	self.txtScoreUText = self.objectReference:GetRefValue("txtScoreUText")
	self.btnShopUButton = self.objectReference:GetRefValue("btnShopUButton")
	self.btnResetUButton = self.objectReference:GetRefValue("btnResetUButton")
	self.panelBtnUComponent = self.objectReference:GetRefValue("panelBtnUComponent")
	self.difficultyUSelector = self.objectReference:GetRefValue("difficultyUSelector")
	self.selectedStarNumUBaseText = self.objectReference:GetRefValue("selectedStarNumUBaseText")
	self.lockBarUWidget = self.objectReference:GetRefValue("lockBarUWidget")
	self.rewardUList = self.objectReference:GetRefValue("rewardUList")
	self.rewardUWidget = self.objectReference:GetRefValue("rewardUWidget")
end

function TowerMainView:registerObjects()
	return
end

function TowerMainView:initView()
	return
end

return TowerMainView
