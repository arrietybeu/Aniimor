-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerDefeat\\TowerDefeatView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerDefeatView = Class.LightClass("TowerDefeatView", UIView)

function TowerDefeatView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listMissionUList = self.objectReference:GetRefValue("listMissionUList")
	self.btnExitUButton = self.objectReference:GetRefValue("btnExitUButton")
	self.btnGoinUButton = self.objectReference:GetRefValue("btnGoinUButton")
	self.listTipsUList = self.objectReference:GetRefValue("listTipsUList")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.btnAddUWidget = self.objectReference:GetRefValue("btnAddUWidget")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.costIcon = self.objectReference:GetRefValue("costIcon")
	self.costNum = self.objectReference:GetRefValue("costNum")
	self.costTips = self.objectReference:GetRefValue("costTips")
	self.failSubTitle = self.objectReference:GetRefValue("failSubTitle")
	self.subTitleUWidget = self.objectReference:GetRefValue("subTitleUWidget")
end

function TowerDefeatView:registerObjects()
	return
end

function TowerDefeatView:initView()
	return
end

return TowerDefeatView
