-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerFinal\\TowerFinalView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerFinalView = Class.LightClass("TowerFinalView", UIView)

function TowerFinalView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtNumUText = self.objectReference:GetRefValue("txtNumUText")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.detailObjectReference = self.objectReference:GetRefValue("detailObjectReference")
	self.uIPbTowerFinalUComponent = self.objectReference:GetRefValue("uIPbTowerFinalUComponent")
end

function TowerFinalView:registerObjects()
	self.listPetUList = self.detailObjectReference:GetRefValue("listPetUList")
	self.listBuffUList = self.detailObjectReference:GetRefValue("listBuffUList")
	self.listItemUList = self.detailObjectReference:GetRefValue("listItemUList")
end

function TowerFinalView:initView()
	return
end

return TowerFinalView
