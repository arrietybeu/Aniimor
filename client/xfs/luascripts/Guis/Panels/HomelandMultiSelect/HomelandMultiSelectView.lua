-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMultiSelect\\HomelandMultiSelectView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandMultiSelectView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandMultiSelectView = Class.LightClass("HomelandMultiSelectView", UIView)

function HomelandMultiSelectView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.globalEditingUWidget = objectReference:GetRefValue("globalEditingUWidget")
	self.viewCtrl = objectReference:GetRefValue("viewCtrl")
	self.selectedPanelUComponent = objectReference:GetRefValue("selectedPanelUComponent")
	self.btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	self.btnRemoveUButton = objectReference:GetRefValue("btnRemoveUButton")
	self.btnRecycleUButton = objectReference:GetRefValue("btnRecycleUButton")
	self.btnSaveUButton = objectReference:GetRefValue("btnSaveUButton")
	self.btnEditUButton = objectReference:GetRefValue("btnEditUButton")
	self.areaRangeText = objectReference:GetRefValue("areaRangeText")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.titleText = objectReference:GetRefValue("titleText")
	self.warningUContainer = objectReference:GetRefValue("warningUContainer")
	self.operateMobileUContainer = objectReference:GetRefValue("operateMobileUContainer")
	self.boxSelectTitle = objectReference:GetRefValue("boxSelectTitle")
	self.boxSelectToggleUButton = objectReference:GetRefValue("boxSelectToggleUButton")
	self.toggleTabUWidget = objectReference:GetRefValue("toggleTabUWidget")
	self.boxSelectToggleText = objectReference:GetRefValue("boxSelectToggleText")
	self.selectBoxRect = objectReference:GetRefValue("selectBox")
	self.btnDisplayUButton = objectReference:GetRefValue("btnDisplayUButton")
	self.selectorMetreUSelector = objectReference:GetRefValue("selectorMetreUSelector")
	self.txtCameraHeightUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.txtMUSDFText = objectReference:GetRefValue("txtMUSDFText")
	self.txtDisplayUSDFText = objectReference:GetRefValue("txtDisplayUSDFText")
	self.txtMetreUSDFText = objectReference:GetRefValue("txtMetreUSDFText")
end

function HomelandMultiSelectView:registerObjects()
	local selectBoxRectObjRef = self.selectBoxRect:GetComponent("ObjectReference")

	self.selectBoxIconTrans = selectBoxRectObjRef:GetRefValue("iconRectTransform")
end

function HomelandMultiSelectView:initView()
	return
end

return HomelandMultiSelectView
