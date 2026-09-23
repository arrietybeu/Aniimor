-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeSelect\\PetExchangeSelectView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetExchangeSelectView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetExchangeSelectView = Class.LightClass("PetExchangeSelectView", UIView)

function PetExchangeSelectView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.friendShipLevelUBaseText = objectReference:GetRefValue("friendShipLevelUBaseText")
	self.friendNameUBaseText = objectReference:GetRefValue("friendNameUBaseText")
	self.petListTransform = objectReference:GetRefValue("petListTransform")
	self.petInfoPanelTransform = objectReference:GetRefValue("petInfoPanelTransform")
	self.exchangeNumUBaseText = objectReference:GetRefValue("exchangeNumUBaseText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.imgPetURawImage = objectReference:GetRefValue("imgPetURawImage")
	self.btnRulesUButton = objectReference:GetRefValue("btnRulesUButton")
	self.txtNameChangeUSDFText = objectReference:GetRefValue("txtNameChangeUSDFText")
	self.nameCoverUSDFText = objectReference:GetRefValue("nameCoverUSDFText")
	self.root = objectReference:GetRefValue("root")
	self.likabilityUImage = objectReference:GetRefValue("likabilityUImage")
	self.textWaitCancelUSDFText = objectReference:GetRefValue("textWaitCancelUSDFText")
	self.petHeadObjectReference = objectReference:GetRefValue("petHeadObjectReference")
	self.textSelectUSDFText = objectReference:GetRefValue("textSelectUSDFText")
	self.ischangeUComponent = objectReference:GetRefValue("ischangeUComponent")
	self.btnSelectUButton = objectReference:GetRefValue("btnSelectUButton")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.bgBlurUIBlurEffect = objectReference:GetRefValue("bgBlurUIBlurEffect")
end

function PetExchangeSelectView:registerObjects()
	return
end

function PetExchangeSelectView:initView()
	return
end

return PetExchangeSelectView
