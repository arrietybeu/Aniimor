-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandCollectionCropDecompose\\HomelandCollectionCropDecomposeView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandCollectionCropDecomposeView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandCollectionCropDecomposeView = Class.LightClass("HomelandCollectionCropDecomposeView", UIView)

function HomelandCollectionCropDecomposeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCancel = objectReference:GetRefValue("btnCancel")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.listProp = objectReference:GetRefValue("listProp")
	self.listReward = objectReference:GetRefValue("listReward")
	self.btnClose1 = objectReference:GetRefValue("btnClose1")
	self.btnClose2 = objectReference:GetRefValue("btnClose2")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtLeftUSDFText = objectReference:GetRefValue("txtLeftUSDFText")
	self.txtRightUSDFText = objectReference:GetRefValue("txtRightUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.selectorUWidget = objectReference:GetRefValue("selectorUWidget")
	self.btnMinUButton = objectReference:GetRefValue("btnMinUButton")
	self.btnDecUButton = objectReference:GetRefValue("btnDecUButton")
	self.btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	self.btnMaxUButton = objectReference:GetRefValue("btnMaxUButton")
	self.btnInputUButton = objectReference:GetRefValue("btnInputUButton")
	self.inputTextUSDFText = objectReference:GetRefValue("inputTextUSDFText")
	self.btnAllSelectedUButton = objectReference:GetRefValue("btnAllSelectedUButton")
	self.txtAllUSDFText = objectReference:GetRefValue("txtAllUSDFText")
end

function HomelandCollectionCropDecomposeView:registerObjects()
	return
end

function HomelandCollectionCropDecomposeView:initView()
	return
end

return HomelandCollectionCropDecomposeView
