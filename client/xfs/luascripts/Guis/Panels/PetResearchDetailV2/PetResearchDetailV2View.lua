-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\PetResearchDetailV2View.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchDetailV2View = Class.LightClass("PetResearchDetailV2View", UIView)

function PetResearchDetailV2View:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.panelResearchUWidget = self.objectReference:GetRefValue("panelResearchUWidget")
	self.tabDetailBookUWidget = self.objectReference:GetRefValue("tabDetailBookUWidget")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.tabDetailGeneUWidget = self.objectReference:GetRefValue("tabDetailGeneUWidget")
	self.researchPointPageUText = self.objectReference:GetRefValue("researchPointPageUText")
	self.windowsUWidget = self.objectReference:GetRefValue("windowsUWidget")
	self.btnMapUButton = self.objectReference:GetRefValue("btnMapUButton")
	self.btnPieUButton = self.objectReference:GetRefValue("btnPieUButton")
	self.btnBarChartUButton = self.objectReference:GetRefValue("btnBarChartUButton")
	self.tabDetailAbility = self.objectReference:GetRefValue("tabDetailAbility")
	self.btnResearchUButton = self.objectReference:GetRefValue("btnResearchUButton")
	self.btnAbilityUButton = self.objectReference:GetRefValue("btnAbilityUButton")
	self.btnGeneUButton = self.objectReference:GetRefValue("btnGeneUButton")
	self.bottomKeyListUList = self.objectReference:GetRefValue("bottomKeyListUList")
	self.tabDetailLocationUWidget = self.objectReference:GetRefValue("tabDetailLocationUWidget")
	self.arrowUWidget = self.objectReference:GetRefValue("arrowUWidget")
	self.btnExitHideUIUButton = self.objectReference:GetRefValue("btnExitHideUIUButton")
	self.tabPhotoUWidget = self.objectReference:GetRefValue("tabPhotoUWidget")
	self.tabFormPageUContainer = self.objectReference:GetRefValue("tabFormPageUContainer")
	self.tabSurveyFormUContainer = self.objectReference:GetRefValue("tabSurveyFormUContainer")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
end

function PetResearchDetailV2View:registerObjects()
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function PetResearchDetailV2View:initView()
	self.windowsUWidget:SetActiveQuickly(false)
end

return PetResearchDetailV2View
