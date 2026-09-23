-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookCropDetail\\HomeBookCropDetailView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeBookCropDetailView = Class.LightClass("HomeBookCropDetailView", UIView)

function HomeBookCropDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnPrevUButton = objectReference:GetRefValue("btnPrevUButton")
	self.btnNextUButton = objectReference:GetRefValue("btnNextUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.iconCropUImage = objectReference:GetRefValue("iconCropUImage")
	self.modelURawImage = objectReference:GetRefValue("modelURawImage")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.addUWidget = objectReference:GetRefValue("addUWidget")
	self.txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")
	self.txtTagUSDFText = objectReference:GetRefValue("txtTagUSDFText")
	self.txtLockTagUSDFText = objectReference:GetRefValue("txtLockTagUSDFText")
	self.txtDescUSDFText = objectReference:GetRefValue("txtDescUSDFText")
	self.listInfoUList = objectReference:GetRefValue("listInfoUList")
	self.autoHarvestUWidget = objectReference:GetRefValue("autoHarvestUWidget")
	self.btnAutoCollectSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	objectReference = self.btnAutoCollectSwitchUButton.transform:GetComponent("ObjectReference")
	self.txtSwitchNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function HomeBookCropDetailView:registerObjects()
	return
end

function HomeBookCropDetailView:initView()
	return
end

return HomeBookCropDetailView
