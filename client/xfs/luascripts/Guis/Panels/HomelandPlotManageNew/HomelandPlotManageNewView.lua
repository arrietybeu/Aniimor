-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlotManageNew\\HomelandPlotManageNewView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandPlotManageNewView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandPlotManageNewView = Class.LightClass("HomelandPlotManageNewView", UIView)

function HomelandPlotManageNewView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.sliderFakeUSlider = objectReference:GetRefValue("sliderFakeUSlider")
	self.btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	self.addKeyUSDFText = objectReference:GetRefValue("addKeyUSDFText")
	self.btnReduceUButton = objectReference:GetRefValue("btnReduceUButton")
	self.reduceKeyUSDFText = objectReference:GetRefValue("reduceKeyUSDFText")
	self.listPlotUList = objectReference:GetRefValue("listPlotUList")
	self.quickActionsUWidget = objectReference:GetRefValue("quickActionsUWidget")
	self.btnBatchUpgradeUButton = objectReference:GetRefValue("btnBatchUpgradeUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnAllocationUButton = objectReference:GetRefValue("btnAllocationUButton")
	self.txtNameUSDFText2 = objectReference:GetRefValue("txtNameUSDFText2")
	self.plotPanelUContainer = objectReference:GetRefValue("plotPanelUContainer")
	self.plotManageUContainer = objectReference:GetRefValue("plotManageUContainer")
	self.batchUpgradeUContainer = objectReference:GetRefValue("batchUpgradeUContainer")
	self.plotCellPoolUWidget = objectReference:GetRefValue("plotCellPoolUWidget")
	self.viewCtrlSimpleViewCtrl = objectReference:GetRefValue("viewCtrlSimpleViewCtrl")
	self.ornamentUWidget = objectReference:GetRefValue("ornamentUWidget")
	self.borderUWidget = objectReference:GetRefValue("borderUWidget")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.environmentRangeUButton = objectReference:GetRefValue("environmentRangeUButton")
	self.formulaTrackTipsUContainer = objectReference:GetRefValue("formulaTrackTipsUContainer")
	self.virtualMouseField = objectReference:GetRefValue("virtualMouseFieldUVirtualMouseField")
	self.btnOverViewUButton = objectReference:GetRefValue("btnOverViewUButton")
	self.btnSpeedUpUButton = objectReference:GetRefValue("btnSpeedUpUButton")
	self.speedUpUSDFText = objectReference:GetRefValue("speedUpUSDFText")
	self.plotSpeedUpUContainer = objectReference:GetRefValue("plotSpeedUpUContainer")
	self.scaleUWidget = objectReference:GetRefValue("scaleUWidget")
end

function HomelandPlotManageNewView:registerObjects()
	return
end

function HomelandPlotManageNewView:initView()
	return
end

return HomelandPlotManageNewView
