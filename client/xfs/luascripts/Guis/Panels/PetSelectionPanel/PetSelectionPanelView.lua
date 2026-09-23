-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelectionPanel\\PetSelectionPanelView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetSelectionPanelView = Class.LightClass("PetSelectionPanelView", UIView)

function PetSelectionPanelView:findObjects()
	return
end

function PetSelectionPanelView:registerObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.leftDetailSR = self.objectReference:GetRefValue("leftDetailSR")
	self.rightNameTxt = self.objectReference:GetRefValue("rightNameTxt")
	self.leftNameTxt = self.objectReference:GetRefValue("leftNameTxt")
	self.leftBtn = self.objectReference:GetRefValue("leftBtn")
	self.rightBtn = self.objectReference:GetRefValue("rightBtn")
	self.mainCom = self.objectReference:GetRefValue("mainCom")
	self.rightDetailSR = self.objectReference:GetRefValue("rightDetailSR")
	self.leftJobTxt = self.objectReference:GetRefValue("leftJobTxt")
	self.leftElementList = self.objectReference:GetRefValue("leftElementList")
	self.rightJobTxt = self.objectReference:GetRefValue("rightJobTxt")
	self.rightElementList = self.objectReference:GetRefValue("rightElementList")
	self.leftConfirmBtn = self.objectReference:GetRefValue("leftConfirmBtn")
	self.rightConfirmBtn = self.objectReference:GetRefValue("rightConfirmBtn")
	self.txtTips = self.objectReference:GetRefValue("txtTipsUBaseText")
	self.leftRecommend = self.objectReference:GetRefValue("leftRecommend")
	self.rightRecommend = self.objectReference:GetRefValue("rightRecommend")
	self.btnBothUButton = self.objectReference:GetRefValue("btnBothUButton")
	self.boxDialogueUWidget = self.objectReference:GetRefValue("boxDialogueUWidget")
	self.btnNextUButton = self.objectReference:GetRefValue("btnNextUButton")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.dialogueTxt = self.objectReference:GetRefValue("dialogueTxt")
	self.hintUWidget = self.objectReference:GetRefValue("hintUWidget")
	self.leftBtnText = self.objectReference:GetRefValue("leftBtnText")
	self.rightBtnText = self.objectReference:GetRefValue("rightBtnText")
	self.dialogueBtnNext = self.objectReference:GetRefValue("dialogueBtnNext")
	self.bottomHotKey = self.objectReference:GetRefValue("bottomHotKey")
	self.leftHotKey = self.objectReference:GetRefValue("leftHotKey")
	self.rightHotKey = self.objectReference:GetRefValue("rightHotKey")
	self.bothHotKey = self.objectReference:GetRefValue("bothHotKey")
end

function PetSelectionPanelView:initView()
	return
end

return PetSelectionPanelView
