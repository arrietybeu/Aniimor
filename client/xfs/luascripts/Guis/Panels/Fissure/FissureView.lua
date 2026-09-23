-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Fissure\\FissureView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FissureView = Class.LightClass("FissureView", UIView)

function FissureView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.objectReference = objectReference
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listNewUList = objectReference:GetRefValue("listNewUList")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.rightPanelObjectReference = objectReference:GetRefValue("rightPanelObjectReference")

	local rightOR = self.rightPanelObjectReference

	if NotNil(rightOR) then
		self.txtTitleUSDFText = rightOR:GetRefValue("txtTitleUSDFText")
		self.txtNumUSDFText = rightOR:GetRefValue("txtNumUSDFText")
		self.txtDetailUSDFText = rightOR:GetRefValue("txtDetailUSDFText")
		self.scrollRectUScrollRect = rightOR:GetRefValue("scrollRectUScrollRect")
		self.txtReWardNameUSDFText = rightOR:GetRefValue("txtReWardNameUSDFText")
		self.rewardUList = rightOR:GetRefValue("listUList")
		self.btnConfirmObjectReference = rightOR:GetRefValue("btnConfirmObjectReference")
		self.btnConfirmUButton = rightOR:GetRefValue("btnConfirmUButton")
		self.btnConfirmText = self.btnConfirmObjectReference:GetRefValue("txtNameUText")
		self.rightPanelAnimation = rightOR:GetRefValue("rightPanelAnimation")
	end
end

function FissureView:registerObjects()
	self.infoObjectReference = self.scrollRectUScrollRect.transform:Find("View/Content"):GetComponent("ObjectReference")

	local infoOR = self.infoObjectReference

	if NotNil(infoOR) then
		self.txtLevelUBaseText = infoOR:GetRefValue("txtLevelUBaseText")
		self.txtLevelNumUSDFText = infoOR:GetRefValue("txtLevelNumUSDFText")
		self.txtElementUBaseText = infoOR:GetRefValue("txtElementUBaseText")
		self.elementListUList = infoOR:GetRefValue("elementListUList")
		self.txtVictoryUSDFText = infoOR:GetRefValue("txtVictoryUSDFText")
		self.txtVictoryInfoUBaseText = infoOR:GetRefValue("txtVictoryInfoUBaseText")
		self.txtBuffUBaseText = infoOR:GetRefValue("txtBuffUBaseText")
		self.listBuffUList = infoOR:GetRefValue("listBuffUList")
	end
end

function FissureView:initView()
	return
end

return FissureView
