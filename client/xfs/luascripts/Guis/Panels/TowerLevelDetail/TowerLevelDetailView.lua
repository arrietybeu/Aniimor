-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerLevelDetail\\TowerLevelDetailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerLevelDetailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerLevelDetailView = Class.LightClass("TowerLevelDetailView", UIView)
local ElementType2PropertyValue = {
	nil,
	0,
	1,
	[11] = 2
}
local ElementType2StartAnimName = {
	nil,
	"VX_Ani_Pb_Tower_LevelDetails_Fire_In",
	"VX_Ani_Pb_Tower_LevelDetails_Glass_In",
	[11] = "VX_Ani_Pb_Tower_LevelDetails_Water_In"
}
local ElementType2StartEndName = {
	nil,
	"VX_Ani_Pb_Tower_LevelDetails_Fire_Out",
	"VX_Ani_Pb_Tower_LevelDetails_Glass_Out",
	[11] = "VX_Ani_Pb_Tower_LevelDetails_Water_Out"
}

function TowerLevelDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.levelTitleUBaseText = objectReference:GetRefValue("levelTitleUBaseText")
	self.levelLvUBaseText = objectReference:GetRefValue("levelLvUBaseText")
	self.listElementUList = objectReference:GetRefValue("listElementUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.rootAnimation = objectReference:GetRefValue("rootAnimation")
	self.bossImagePro = objectReference:GetRefValue("bossImagePro")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.iconUp3UContainer = objectReference:GetRefValue("iconUp3UContainer")
	self.btnCombatStyleUButton = objectReference:GetRefValue("btnCombatStyleUButton")
	self.startUWidget = objectReference:GetRefValue("startUWidget")
	self.listPetNewUList = objectReference:GetRefValue("listPetNewUList")
	self.btnStartUButton = objectReference:GetRefValue("btnStartUButton")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.listRewardItemUList = objectReference:GetRefValue("listRewardItemUList")
	self.itemObjectReference = objectReference:GetRefValue("itemObjectReference")
	self.safeBoxMobileAnimation = objectReference:GetRefValue("safeBoxMobileAnimation")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.levelUBaseText = objectReference:GetRefValue("levelUBaseText")
	self.btnLevelUButton = objectReference:GetRefValue("btnLevelUButton")
	self.btnStarUButton = objectReference:GetRefValue("btnStarUButton")
	self.levelUList = objectReference:GetRefValue("levelUList")
	self.bgButtonUButton = objectReference:GetRefValue("bgButtonUButton")
	self.firstUWidget = objectReference:GetRefValue("firstUWidget")
	self.listFirstRewardUList = objectReference:GetRefValue("listFirstRewardUList")
	self.layoutBoxAnimation = objectReference:GetRefValue("layoutBoxAnimation")
	self.doubleRewardUWidget = objectReference:GetRefValue("doubleRewardUWidget")
	self.startDoubleRewardUWidget = objectReference:GetRefValue("startDoubleRewardUWidget")
	self.recommendPetBtn = objectReference:GetRefValue("recommendPetBtn")
	self.popUpObjectReference = objectReference:GetRefValue("popUpObjectReference")
	self.btnfastTrainUButton = objectReference:GetRefValue("btnfastTrainUButton")
	self.btnSwitchUSelector = objectReference:GetRefValue("btnSwitchUSelector")
	self.btnPetManageUButton = objectReference:GetRefValue("btnPetManageUButton")
	self.noticeToastObjectReference = objectReference:GetRefValue("noticeToastObjectReference")
	self.buttonUButton = objectReference:GetRefValue("buttonUButton")
end

function TowerLevelDetailView:registerObjects()
	local objectReference = self.btnStartUButton:GetComponent("ObjectReference")

	self.startCombatNameUBaseText = objectReference:GetRefValue("txtNameUText")
	self.styleIconUComponent = self.itemObjectReference:GetRefValue("styleIconUComponent")
	self.styleIconUImage = self.itemObjectReference:GetRefValue("styleIconUImage")
	self.styleNameUBaseText = self.itemObjectReference:GetRefValue("styleNameUBaseText")
	self.styleDescriptionUBaseText = self.itemObjectReference:GetRefValue("styleDescriptionUBaseText")
	self.styleItemUList = self.itemObjectReference:GetRefValue("styleItemUList")
	self.styleMainBuffUBaseText = self.itemObjectReference:GetRefValue("styleMainBuffUBaseText")
	self.randomAnimation = self.itemObjectReference:GetRefValue("randomAnimation")
	self.equipmentAnimation = self.itemObjectReference:GetRefValue("equipmentAnimation")
	self.styleIcon1UImage = self.itemObjectReference:GetRefValue("styleIcon1UImage")
	self.tooltipUButton = self.itemObjectReference:GetRefValue("tooltipUButton")
	self.styleMainUBaseText = self.itemObjectReference:GetRefValue("styleMainUBaseText")

	local fastTrainObjectReference = self.btnfastTrainUButton:GetComponent("ObjectReference")

	self.fastTrainBtnUText = fastTrainObjectReference:GetRefValue("txtNameUText")

	local objectReference = self.noticeToastObjectReference

	self.toastUComponent = objectReference:GetRefValue("toastUComponent")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.text2USDFText = objectReference:GetRefValue("text2USDFText")
	self.longTrm = self.text2USDFText.transform.parent.parent
end

function TowerLevelDetailView:initView()
	return
end

function TowerLevelDetailView:getPropertyValue(elementType)
	return ElementType2PropertyValue[elementType] or 0
end

function TowerLevelDetailView:getStartAnimName(elementType)
	return ElementType2StartAnimName[elementType] or "VX_Ani_Pb_Tower_LevelDetails_Fire_In"
end

function TowerLevelDetailView:getEndAnimName(elementType)
	return ElementType2StartEndName[elementType] or "VX_Ani_Pb_Tower_LevelDetails_Fire_Out"
end

return TowerLevelDetailView
