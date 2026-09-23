-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryDecompose\\InventoryDecomposeView.lua

local logger = require("Core.Log.LoggerManager").getLogger("InventoryDecomposeView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local InventoryDecomposeView = Class.LightClass("InventoryDecomposeView", UIView)

function InventoryDecomposeView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.listProp = self.objectReference:GetRefValue("listProp")
	self.listReward = self.objectReference:GetRefValue("listReward")
	self.btnClose1 = self.objectReference:GetRefValue("btnClose1")
	self.btnClose2 = self.objectReference:GetRefValue("btnClose2")
end

function InventoryDecomposeView:registerObjects()
	return
end

function InventoryDecomposeView:initView()
	return
end

return InventoryDecomposeView
