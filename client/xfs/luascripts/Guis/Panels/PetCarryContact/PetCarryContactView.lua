-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryContact\\PetCarryContactView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryContactView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetCarryContactView = Class.LightClass("PetCarryContactView", UIView)

function PetCarryContactView:findObjects()
	return
end

function PetCarryContactView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.infoTxtTipsUSDFText = objectReference:GetRefValue("infoTxtTipsUSDFText")
	self.skillBeforeUComponent = objectReference:GetRefValue("skillBeforeUComponent")
	self.skillAfterUComponent = objectReference:GetRefValue("skillAfterUComponent")
	self.btnConsumeUButton = objectReference:GetRefValue("btnConsumeUButton")
	self.lockUImage = objectReference:GetRefValue("lockUImage")
	self.iconConsumeUImage = objectReference:GetRefValue("iconConsumeUImage")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnNoneCostUButton = objectReference:GetRefValue("btnNoneCostUButton")
	self.btnConsumeTxt = objectReference:GetRefValue("btnConsumeTxt")
	self.leftPetIconUImage = objectReference:GetRefValue("leftPetIconUImage")
	self.txtPetNameUSDFText = objectReference:GetRefValue("txtPetNameUSDFText")
	self.iconCarryUImage = objectReference:GetRefValue("iconCarryUImage")
	self.txtCarryNameUSDFText = objectReference:GetRefValue("txtCarryNameUSDFText")
	self.carryQualityUWidget = objectReference:GetRefValue("carryQualityUWidget")
	self.leftTipsBtnInfoUButton = objectReference:GetRefValue("leftTipsBtnInfoUButton")
	self.leftTipsBtnInfoUSDFText = objectReference:GetRefValue("leftTipsBtnInfoUSDFText")
	self.txtExclusiveUSDFText = objectReference:GetRefValue("txtExclusiveUSDFText")

	local carryTs = self.transform:Find("SafeBoxMobile/Window/Left/Carry")

	self.carryUComponent = carryTs:GetComponent("UComponent")
end

function PetCarryContactView:initView()
	return
end

return PetCarryContactView
