-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerStageInfo\\TowerStageInfoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerStageInfoView = Class.LightClass("TowerStageInfoView", UIView)

function TowerStageInfoView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.levelNameUText = objectReference:GetRefValue("levelNameUText")
	self.txtStageNameUText = objectReference:GetRefValue("txtStageNameUText")
	self.recommendEleList = objectReference:GetRefValue("recommendEleList")
	self.selectedPetList = objectReference:GetRefValue("selectedPetList")
	self.btnEditUButton = objectReference:GetRefValue("btnEditUButton")
	self.detailTransform = objectReference:GetRefValue("detailTransform")
	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.battleListPanelUComponent = objectReference:GetRefValue("battleListPanelUComponent")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.propUList = objectReference:GetRefValue("propUList")
	self.btnJumpUButton = objectReference:GetRefValue("btnJumpUButton")
	self.bg1UWidget = objectReference:GetRefValue("bg1UWidget")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.textRecordUSDFText = objectReference:GetRefValue("textRecordUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function TowerStageInfoView:registerObjects()
	self.detailViewRectTransform = self.detailTransform:Find("View"):GetComponent("RectTransform")
	self.detailContentRectTransform = self.detailTransform:Find("View/Content"):GetComponent("RectTransform")
	self.detailContentRef = self.detailContentRectTransform:GetComponent("ObjectReference")
	self.conditionUList = self.detailContentRef:GetRefValue("conditionUList")
	self.environmentEffectUText = self.detailContentRef:GetRefValue("environmentEffectUText")
	self.enemyUList = self.detailContentRef:GetRefValue("enemyUList")
	self.btnSreachUButton = self.detailContentRef:GetRefValue("btnSreachUButton")
	self.conditionEmptyUWidget = self.detailContentRef:GetRefValue("conditionEmptyUWidget")
	self.enemyEmptyUWidget = self.detailContentRef:GetRefValue("enemyEmptyUWidget")
	self.enemyUSDFText = self.detailContentRef:GetRefValue("enemyUSDFText")
	self.taskUSDFText = self.detailContentRef:GetRefValue("taskUSDFText")
	self.buffUWidget = self.detailContentRef:GetRefValue("buffUWidget")
	self.txtNameUBaseText = self.detailContentRef:GetRefValue("txtNameUBaseText")
	self.buffUList = self.detailContentRef:GetRefValue("buffUList")
end

function TowerStageInfoView:initView()
	return
end

return TowerStageInfoView
